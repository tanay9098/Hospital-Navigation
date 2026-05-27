import 'package:hospital_nav/models/navigation_instruction.dart';
import 'package:hospital_nav/models/node.dart';
import 'package:hospital_nav/services/path_analyzer.dart';
import 'package:hospital_nav/services/instruction_formatter.dart';

/// Generates navigation instructions from a computed path + analysis.
///
/// Pipeline: Path → PathAnalysis → SemanticIntents → InstructionFormatter → NavigationInstructions
///
/// This class produces ONLY semantic intent data (ManeuverType, distance,
/// landmark keys). All user-facing string generation is delegated to
/// [InstructionFormatter].
class DirectionGenerator {
  final InstructionFormatter _formatter;

  DirectionGenerator(this._formatter);

  /// Generate fully-localized navigation instructions for a route.
  List<NavigationInstruction> generate({
    required List<Node> path,
    required PathAnalysis analysis,
  }) {
    if (path.isEmpty) return const [];

    final intents = _buildSemanticIntents(path, analysis);
    return _formatter.format(intents);
  }

  /// Build raw semantic intents from path analysis — NO strings generated here.
  List<SemanticIntent> _buildSemanticIntents(List<Node> path, PathAnalysis analysis) {
    final intents = <SemanticIntent>[
      // Start intent
      SemanticIntent(
        maneuver: ManeuverType.start,
        pathIndex: 0,
        targetLabelKey: path.first.label,
      ),
    ];

    final turnByIndex = <int, TurnEvent>{
      for (final turn in analysis.turnEvents) turn.pathIndex: turn,
    };

    for (int i = 0; i < analysis.segments.length; i++) {
      final segment = analysis.segments[i];
      final turn = turnByIndex[segment.endPathIndex];
      final isLastSegment = i == analysis.segments.length - 1;

      if (turn != null) {
        intents.add(SemanticIntent(
          maneuver: _getManeuver(turn.turnType),
          distanceMeters: segment.distanceMeters,
          pathIndex: segment.startPathIndex,
          landmarkLabelKey: turn.landmark,
          targetFloor: turn.turnType == TurnType.floorChange
              ? _getNextFloor(turn.pathIndex, path)
              : null,
        ));
      } else if (isLastSegment && segment.distanceMeters > 5.0) {
        // Pre-arrival approach
        intents.add(SemanticIntent(
          maneuver: ManeuverType.arrive,
          distanceMeters: segment.distanceMeters,
          pathIndex: segment.startPathIndex,
          targetLabelKey: path.last.label,
        ));
      }
    }

    // Final arrival
    intents.add(SemanticIntent(
      maneuver: ManeuverType.arrive,
      pathIndex: path.length - 1,
      targetLabelKey: path.last.label,
    ));

    return intents;
  }

  int _getNextFloor(int turnIndex, List<Node> path) {
    return (turnIndex + 1 < path.length) ? path[turnIndex + 1].floor : path[turnIndex].floor;
  }

  ManeuverType _getManeuver(TurnType type) {
    switch (type) {
      case TurnType.right: return ManeuverType.right;
      case TurnType.left: return ManeuverType.left;
      case TurnType.slightRight: return ManeuverType.slightRight;
      case TurnType.slightLeft: return ManeuverType.slightLeft;
      case TurnType.floorChange: return ManeuverType.floorChange;
      case TurnType.straight: return ManeuverType.straight;
    }
  }
}

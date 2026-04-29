import 'package:hospital_nav/models/navigation_instruction.dart';
import 'package:hospital_nav/models/node.dart';
import 'package:hospital_nav/services/path_analyzer.dart';

class DirectionGenerator {
  List<NavigationInstruction> generate({
    required List<Node> path,
    required PathAnalysis analysis,
  }) {
    if (path.isEmpty) {
      return const [];
    }

    final instructions = <NavigationInstruction>[
      NavigationInstruction(
        maneuver: ManeuverType.start,
        text: 'Start at ${_displayName(path.first)}',
        pathIndex: 0,
      ),
    ];

    final turnByIndex = <int, TurnEvent>{
      for (final turn in analysis.turnEvents) turn.pathIndex: turn,
    };

    for (int i = 0; i < analysis.segments.length; i++) {
      final segment = analysis.segments[i];
      final turn = turnByIndex[segment.endPathIndex];
      final isLastSegment = i == analysis.segments.length - 1;
      
      final distStr = segment.distanceMeters.toStringAsFixed(0);
      
      if (turn != null) {
        String text;
        if (segment.distanceMeters > 5.0) {
          text = 'In $distStr meters, ${_turnActionText(turn, path)}';
        } else {
          // Capitalize first letter if it's immediate
          final action = _turnActionText(turn, path);
          text = '${action[0].toUpperCase()}${action.substring(1)}';
        }
        
        instructions.add(
          NavigationInstruction(
            maneuver: _getManeuver(turn.turnType),
            text: text,
            distanceMeters: segment.distanceMeters,
            pathIndex: segment.startPathIndex,
          ),
        );
      } else if (isLastSegment) {
        if (segment.distanceMeters > 5.0) {
          instructions.add(
            NavigationInstruction(
              maneuver: ManeuverType.arrive,
              text: 'In $distStr meters, arrive at ${_displayName(path.last)}',
              distanceMeters: segment.distanceMeters,
              pathIndex: segment.startPathIndex,
            ),
          );
        }
      }
    }

    // Always ensure the final arrival step exists exactly at the end node
    instructions.add(
      NavigationInstruction(
        maneuver: ManeuverType.arrive,
        text: 'You have arrived at ${_displayName(path.last)}',
        pathIndex: path.length - 1,
      ),
    );

    return _dedupeInstructions(instructions);
  }

  String _turnActionText(TurnEvent turn, List<Node> path) {
    final landmarkSuffix = (turn.landmark != null && turn.landmark!.isNotEmpty)
        ? ' near ${turn.landmark}'
        : '';

    switch (turn.turnType) {
      case TurnType.right:
        return 'turn right$landmarkSuffix';
      case TurnType.left:
        return 'turn left$landmarkSuffix';
      case TurnType.slightRight:
        return 'bear right$landmarkSuffix';
      case TurnType.slightLeft:
        return 'bear left$landmarkSuffix';
      case TurnType.floorChange:
        final nextFloor = (turn.pathIndex + 1 < path.length) ? path[turn.pathIndex + 1].floor : path[turn.pathIndex].floor;
        return 'go to Floor $nextFloor$landmarkSuffix';
      case TurnType.straight:
        return 'continue straight$landmarkSuffix';
    }
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

  List<NavigationInstruction> _dedupeInstructions(List<NavigationInstruction> instructions) {
    if (instructions.length < 2) return instructions;

    final result = <NavigationInstruction>[];
    for (final step in instructions) {
      if (result.isEmpty || result.last.text != step.text) {
        result.add(step);
      }
    }
    return result;
  }

  String _displayName(Node node) {
    final name = node.name.trim();
    if (name.isEmpty) return 'your location';
    return name.replaceAll('_', ' ');
  }
}

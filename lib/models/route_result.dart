import 'package:hospital_nav/models/node.dart';
import 'package:hospital_nav/models/navigation_instruction.dart';
import 'package:hospital_nav/services/path_analyzer.dart';

class RouteResult {
  final List<Node> path;
  final double totalDistance;
  final Set<int> floorsVisited;
  final List<NavigationInstruction> steps;
  final List<int> turnPointIndices;
  final PathAnalysis? analysis;

  RouteResult({
    required this.path,
    required this.totalDistance,
    required this.floorsVisited,
    required this.steps,
    this.turnPointIndices = const [],
    this.analysis,
  });
}

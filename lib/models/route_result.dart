import 'package:hospital_nav/models/node.dart';
import 'package:hospital_nav/models/navigation_instruction.dart';

class RouteResult {
  final List<Node> path;
  final double totalDistance;
  final Set<int> floorsVisited;
  final List<NavigationInstruction> steps;
  final List<int> turnPointIndices;

  RouteResult({
    required this.path,
    required this.totalDistance,
    required this.floorsVisited,
    required this.steps,
    this.turnPointIndices = const [],
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hospital_nav/models/nav_graph.dart';
import 'package:hospital_nav/services/pathfinding_service.dart';

void main() async {
  // Read the JSON file
  final file = File('assets/data/ground_floor.json');
  final jsonStr = await file.readAsString();
  final data = jsonDecode(jsonStr);

  // Parse the graph
  final Map<String, dynamic> graphData = data;
  final NavGraph graph = NavGraph.fromJson(graphData);

  debugPrint('Graph loaded: ${graph.nodes.length} nodes, ${graph.edges.length} edges.');

  // Try to find a path between F0_N1 (MAIN ENTRANCE) and F0_N5 (PHARMACY)
  final pathfinder = PathfindingService();
  final result = pathfinder.findPath(graph, 'F0_N1', 'F0_N5');

  if (result == null) {
     debugPrint('PATHFINDING FAILED: returned null.');
  } else {
     debugPrint('PATHFINDING SUCCESS! ${result.path.length} nodes, total distance: ${result.totalDistance}');
  }
}

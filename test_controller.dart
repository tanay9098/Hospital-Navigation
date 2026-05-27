import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hospital_nav/models/nav_graph.dart';
import 'package:hospital_nav/models/node.dart';
import 'package:hospital_nav/services/floor_manager.dart';
import 'package:hospital_nav/controllers/navigation_controller.dart';

void main() async {
  final gfFile = File('assets/data/ground_floor.json');
  final gfGraph = NavGraph.fromJson(jsonDecode(await gfFile.readAsString()));

  final f1File = File('assets/data/first_floor.json');
  final f1Graph = NavGraph.fromJson(jsonDecode(await f1File.readAsString()));

  final floorManager = FloorManager();
  // We mock the graphs to avoid async load plugin issues
  floorManager.floorGraphs[0] = gfGraph;
  floorManager.floorGraphs[1] = f1Graph;

  final controller = NavigationController();

  Node start = gfGraph.nodes.values.firstWhere((n) => n.label == 'MAIN ENTRANCE');
  Node dest = f1Graph.nodes.values.firstWhere((n) => n.label == 'medicine_opd');

  final multi = controller.computeRoute(
      startNode: start,
      destNode: dest,
      floorManager: floorManager,
      currentFloor: 0,
  );

  debugPrint('Multi.currentSegment null? ${multi.currentSegment == null}');
  debugPrint('Multi.nextSegment null? ${multi.nextSegment == null}');
  if (multi.currentSegment != null) {
      debugPrint('Current segment path length: ${multi.currentSegment!.path.length}');
  }
}

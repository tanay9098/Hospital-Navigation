import 'dart:math';
import 'package:collection/collection.dart';
import 'package:hospital_nav/models/nav_graph.dart';
import 'package:hospital_nav/models/node.dart';
import 'package:hospital_nav/models/route_result.dart';
import 'package:hospital_nav/services/path_analyzer.dart';

class PathfindingService {
  static const double floorPenalty = 500.0;
  static const double _epsilon = 1e-9;
  final PathAnalyzer _pathAnalyzer = PathAnalyzer();

  RouteResult? findPath(NavGraph graph, String startId, String endId) {
    if (!graph.nodes.containsKey(startId) || !graph.nodes.containsKey(endId)) return null;

    final double ppm = graph.pixelsPerMeter;

    final startNode = graph.nodes[startId]!;
    final endNode = graph.nodes[endId]!;

    final openSet = PriorityQueue<_AStarNode>((a, b) => a.fScore.compareTo(b.fScore));
    final closedSet = <String>{};
    final cameFrom = <String, String>{};

    final gScore = <String, double>{startId: 0.0};
    
    final startAStarNode = _AStarNode(
      id: startId,
      fScore: _heuristic(startNode, endNode, ppm),
    );
    
    openSet.add(startAStarNode);

    while (openSet.isNotEmpty) {
      final current = openSet.removeFirst();
      final currentNode = graph.nodes[current.id]!;

      // Skip stale queue entries that no longer represent the best known path.
      final expectedFScore = (gScore[current.id] ?? double.infinity) + _heuristic(currentNode, endNode, ppm);
      if ((current.fScore - expectedFScore).abs() > _epsilon && current.fScore > expectedFScore) {
        continue;
      }

      if (closedSet.contains(current.id)) {
        continue;
      }
      closedSet.add(current.id);

      if (current.id == endId) {
        return _reconstructPath(cameFrom, current.id, graph);
      }

      final neighbors = graph.adjacencyList[current.id] ?? [];

      for (var edge in neighbors) {
        final neighborNode = graph.nodes[edge.toNode]!;

        final currentGScore = gScore[current.id];
        if (currentGScore == null) continue;

        double tentativeGScore = currentGScore + edge.distance;
        
        if (currentNode.floor != neighborNode.floor) {
             tentativeGScore += floorPenalty;
        }

        if (tentativeGScore < (gScore[edge.toNode] ?? double.infinity)) {
          cameFrom[edge.toNode] = current.id;
          gScore[edge.toNode] = tentativeGScore;
          
          final fScore = tentativeGScore + _heuristic(neighborNode, endNode, ppm);
          // In Dart's PriorityQueue, key updates are emulated by pushing a new entry.
          // Stale entries are skipped when popped.
          openSet.add(_AStarNode(id: edge.toNode, fScore: fScore));
        }
      }
    }

    return null; // No path found
  }

  /// Heuristic: straight-line pixel distance converted to meters.
  /// Must be in the same unit as edge weights (meters) for A* to be consistent.
  double _heuristic(Node a, Node b, double ppm) {
    final pixelDist = sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));
    final meterDist = pixelDist / ppm;
    if (a.floor != b.floor) {
       return meterDist + floorPenalty;
    }
    return meterDist;
  }

  RouteResult _reconstructPath(Map<String, String> cameFrom, String currentId, NavGraph graph) {
    var path = <Node>[];
    var curr = currentId;
    
    path.add(graph.nodes[curr]!);
    while (cameFrom.containsKey(curr)) {
      curr = cameFrom[curr]!;
      path.add(graph.nodes[curr]!);
    }
    
    path = path.reversed.toList();
    
    final floors = <int>{};
    for (var n in path) {
      floors.add(n.floor);
    }
    
    final analysis = _pathAnalyzer.analyze(path, graph);

    return RouteResult(
      path: path,
      totalDistance: analysis.totalDistanceMeters,
      floorsVisited: floors,
      steps: const [], // Directions generated later via DirectionGenerator + SettingsProvider
      turnPointIndices: analysis.turnEvents.map((e) => e.pathIndex).toList(),
      analysis: analysis,
    );
  }

}

class _AStarNode {
  final String id;
  final double fScore;
  _AStarNode({required this.id, required this.fScore});
}

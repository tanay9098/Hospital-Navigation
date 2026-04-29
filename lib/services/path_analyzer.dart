import 'dart:math';
import 'package:collection/collection.dart';
import 'package:hospital_nav/models/nav_graph.dart';
import 'package:hospital_nav/models/node.dart';

enum TurnType {
  straight,
  slightLeft,
  left,
  slightRight,
  right,
  floorChange,
}

class TurnEvent {
  final int pathIndex;
  final TurnType turnType;
  final String? landmark;

  const TurnEvent({
    required this.pathIndex,
    required this.turnType,
    this.landmark,
  });
}

class PathSegment {
  final int startPathIndex;
  final int endPathIndex;
  final double distanceMeters;

  const PathSegment({
    required this.startPathIndex,
    required this.endPathIndex,
    required this.distanceMeters,
  });
}

class PathAnalysis {
  final List<PathSegment> segments;
  final List<TurnEvent> turnEvents;
  final double totalDistanceMeters;

  const PathAnalysis({
    required this.segments,
    required this.turnEvents,
    required this.totalDistanceMeters,
  });
}

class PathAnalyzer {
  static const double _turnThreshold = 0.04; // dot > 0.96 ≈ ~16° is straight
  static const double _slightTurnThreshold = 0.70; // dot > 0.70 ≈ ~45° is a slight turn

  PathAnalysis analyze(List<Node> path, NavGraph graph) {
    if (path.length < 2) {
      return const PathAnalysis(segments: [], turnEvents: [], totalDistanceMeters: 0);
    }

    final edgeDistances = <double>[];
    for (int i = 0; i < path.length - 1; i++) {
      final edge = graph.adjacencyList[path[i].id]?.firstWhereOrNull((e) => e.toNode == path[i + 1].id);
      edgeDistances.add(edge?.distance ?? 0.0);
    }

    final turnEvents = <TurnEvent>[];
    for (int i = 1; i < path.length - 1; i++) {
      final prev = path[i - 1];
      final curr = path[i];
      final next = path[i + 1];

      final turnType = _classifyTurn(prev, curr, next);
      if (turnType == TurnType.straight) {
        continue;
      }

      turnEvents.add(TurnEvent(
        pathIndex: i,
        turnType: turnType,
        landmark: _findClosestLandmark(curr, graph),
      ));
    }

    // Simplify path by creating long walk segments between turn events.
    final segmentBreaks = <int>{0, path.length - 1};
    for (final turn in turnEvents) {
      segmentBreaks.add(turn.pathIndex);
    }
    final sortedBreaks = segmentBreaks.toList()..sort();

    final segments = <PathSegment>[];
    for (int i = 0; i < sortedBreaks.length - 1; i++) {
      final startIndex = sortedBreaks[i];
      final endIndex = sortedBreaks[i + 1];
      if (endIndex <= startIndex) continue;

      double distance = 0.0;
      for (int edgeIndex = startIndex; edgeIndex < endIndex; edgeIndex++) {
        distance += edgeDistances[edgeIndex];
      }
      segments.add(PathSegment(
        startPathIndex: startIndex,
        endPathIndex: endIndex,
        distanceMeters: distance,
      ));
    }

    final totalDistance = edgeDistances.fold<double>(0.0, (sum, d) => sum + d);

    return PathAnalysis(
      segments: segments,
      turnEvents: turnEvents,
      totalDistanceMeters: totalDistance,
    );
  }

  TurnType _classifyTurn(Node a, Node b, Node c) {
    if (a.floor != b.floor || b.floor != c.floor) {
      return TurnType.floorChange;
    }

    final v1x = b.x - a.x;
    final v1y = b.y - a.y;
    final v2x = c.x - b.x;
    final v2y = c.y - b.y;

    final mag1 = sqrt(v1x * v1x + v1y * v1y);
    final mag2 = sqrt(v2x * v2x + v2y * v2y);
    if (mag1 == 0 || mag2 == 0) return TurnType.straight;

    final dot = (v1x * v2x + v1y * v2y) / (mag1 * mag2);
    final cross = v1x * v2y - v1y * v2x;

    if (dot > 1 - _turnThreshold) {
      return TurnType.straight;
    }

    // Screen Y-axis grows downward, so sign is inverted vs Cartesian convention.
    final isRight = cross > 0;
    final isSlight = dot > _slightTurnThreshold;

    if (isRight) {
      return isSlight ? TurnType.slightRight : TurnType.right;
    }
    return isSlight ? TurnType.slightLeft : TurnType.left;
  }

  String? _findClosestLandmark(Node pivot, NavGraph graph) {
    const maxPixelRadius = 340.0;
    final genericNodePattern = RegExp(r'^N\d+$');

    Node? bestNode;
    double bestDistSq = double.infinity;

    for (final candidate in graph.nodes.values) {
      if (candidate.floor != pivot.floor || candidate.id == pivot.id) continue;
      if (genericNodePattern.hasMatch(candidate.name)) continue;
      if (candidate.name.trim().isEmpty) continue;
      if (candidate.type != 'room' && candidate.type != 'lift' && candidate.type != 'stairs') continue;

      final dx = candidate.x - pivot.x;
      final dy = candidate.y - pivot.y;
      final distSq = dx * dx + dy * dy;
      if (distSq < bestDistSq) {
        bestDistSq = distSq;
        bestNode = candidate;
      }
    }

    if (bestNode == null || sqrt(bestDistSq) > maxPixelRadius) {
      return null;
    }
    return bestNode.name.replaceAll('_', ' ');
  }
}

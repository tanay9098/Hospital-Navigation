import 'package:collection/collection.dart';
import 'package:hospital_nav/models/node.dart';
import 'package:hospital_nav/models/route_result.dart';
import 'package:hospital_nav/services/floor_manager.dart';
import 'package:hospital_nav/services/pathfinding_service.dart';

class MultiFloorRoute {
  final RouteResult? currentSegment;
  final RouteResult? nextSegment;
  final Node? transitionNode;
  final int? nextFloor;

  MultiFloorRoute({
    this.currentSegment,
    this.nextSegment,
    this.transitionNode,
    this.nextFloor,
  });
}

class NavigationController {
  final PathfindingService _pathfinder = PathfindingService();

  bool _isMatchingVertical(String? v1, String? v2) {
    if (v1 == null || v2 == null) return false;
    
    String normalize(String id) {
      final vIndex = id.indexOf('V_');
      if (vIndex != -1) {
        return id.substring(vIndex);
      }
      return id;
    }
    
    return normalize(v1) == normalize(v2);
  }

  List<String> _transitOrder(String preferred) {
    const all = ['lift', 'stairs', 'ramp'];
    final ordered = <String>[preferred, ...all.where((t) => t != preferred)];
    return ordered;
  }

  MultiFloorRoute computeRoute({
    required Node startNode,
    required Node destNode,
    required FloorManager floorManager,
    required int currentFloor,
    String transitPreference = 'lift',
  }) {
    final startFloorGraph = floorManager.floorGraphs[startNode.floor];
    final destFloorGraph = floorManager.floorGraphs[destNode.floor];

    if (startFloorGraph == null || destFloorGraph == null) {
      return MultiFloorRoute();
    }

    if (startNode.floor == destNode.floor) {
      // Single floor routing
      final result = _pathfinder.findPath(
        startFloorGraph,
        startNode.id,
        destNode.id,
      );

      // If we are currently on this floor, return it as currentSegment
      if (currentFloor == startNode.floor) {
        return MultiFloorRoute(currentSegment: result);
      } else {
        return MultiFloorRoute(nextSegment: result, nextFloor: startNode.floor);
      }
    }

    // Multi-floor routing:
    // Try preferred transit first, then gracefully fall back if a connector
    // exists but is disconnected on one of the floors.
    Node? bestStartVertical;
    RouteResult? bestStartSegment;
    RouteResult? bestDestSegment;

    for (final transitType in _transitOrder(transitPreference)) {
      final startVerticals = startFloorGraph.nodes.values
          .where((n) => n.verticalId != null && n.verticalId!.isNotEmpty && n.type == transitType)
          .toList();

      final destVerticals = destFloorGraph.nodes.values
          .where((n) => n.verticalId != null && n.verticalId!.isNotEmpty && n.type == transitType)
          .toList();

      Node? candidateVertical;
      RouteResult? candidateStart;
      RouteResult? candidateDest;
      double minTotalDistance = double.infinity;

      for (var sv in startVerticals) {
        final dv = destVerticals.firstWhereOrNull(
          (v) => _isMatchingVertical(v.verticalId, sv.verticalId),
        );
        if (dv == null) continue;

        final startSeg = _pathfinder.findPath(startFloorGraph, startNode.id, sv.id);
        final destSeg = _pathfinder.findPath(destFloorGraph, dv.id, destNode.id);
        if (startSeg == null || destSeg == null) continue;

        final totalDist = startSeg.totalDistance + destSeg.totalDistance;
        if (totalDist < minTotalDistance) {
          minTotalDistance = totalDist;
          candidateVertical = sv;
          candidateStart = startSeg;
          candidateDest = destSeg;
        }
      }

      if (candidateStart != null && candidateDest != null && candidateVertical != null) {
        bestStartVertical = candidateVertical;
        bestStartSegment = candidateStart;
        bestDestSegment = candidateDest;
        break;
      }
    }

    if (currentFloor == startNode.floor) {
        return MultiFloorRoute(
            currentSegment: bestStartSegment,
            nextSegment: bestDestSegment,
            transitionNode: bestStartVertical,
            nextFloor: destNode.floor,
        );
    } else if (currentFloor == destNode.floor) {
        return MultiFloorRoute(
            currentSegment: bestDestSegment,
        );
    } else {
         return MultiFloorRoute();
    }
  }
}

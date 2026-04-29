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
        transitPreference: transitPreference,
      );

      // If we are currently on this floor, return it as currentSegment
      if (currentFloor == startNode.floor) {
        return MultiFloorRoute(currentSegment: result);
      } else {
        return MultiFloorRoute(nextSegment: result, nextFloor: startNode.floor);
      }
    }

    // Multi-floor routing
    // Find matching vertical nodes
    List<Node> startVerticals = startFloorGraph.nodes.values
        .where((n) => n.verticalId != null && n.verticalId!.isNotEmpty)
        .toList();

    List<Node> destVerticals = destFloorGraph.nodes.values
        .where((n) => n.verticalId != null && n.verticalId!.isNotEmpty)
        .toList();
        
    // Filter by transit preference
    startVerticals = startVerticals.where((n) => n.type == transitPreference).toList();
    destVerticals = destVerticals.where((n) => n.type == transitPreference).toList();

    Node? bestStartVertical;
    RouteResult? bestStartSegment;
    RouteResult? bestDestSegment;
    double minTotalDistance = double.infinity;

    for (var sv in startVerticals) {
      // Find matching dest vertical using robust matching
      final dv = destVerticals.firstWhereOrNull(
        (v) => _isMatchingVertical(v.verticalId, sv.verticalId),
      );

      if (dv == null) continue; // No match found for this vertical ID

      // Compute route segments
      final startSeg = _pathfinder.findPath(startFloorGraph, startNode.id, sv.id, transitPreference: transitPreference);
      final destSeg = _pathfinder.findPath(destFloorGraph, dv.id, destNode.id, transitPreference: transitPreference);

      if (startSeg != null && destSeg != null) {
        double totalDist = startSeg.totalDistance + destSeg.totalDistance;
        if (totalDist < minTotalDistance) {
          minTotalDistance = totalDist;
          bestStartVertical = sv;
          bestStartSegment = startSeg;
          bestDestSegment = destSeg;
        }
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

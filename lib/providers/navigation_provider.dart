import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hospital_nav/models/nav_graph.dart';
import 'package:hospital_nav/models/node.dart';
import 'package:hospital_nav/models/route_result.dart';
import 'package:hospital_nav/models/navigation_instruction.dart';
import 'package:hospital_nav/models/user_position.dart';
import 'package:hospital_nav/services/floor_manager.dart';
import 'package:hospital_nav/services/transition_handler.dart';
import 'package:hospital_nav/controllers/navigation_controller.dart';
import 'package:hospital_nav/providers/settings_provider.dart';
import 'package:hospital_nav/services/path_analyzer.dart';

class NavigationProvider extends ChangeNotifier {
  final FloorManager floorManager = FloorManager();
  final TransitionHandler transitionHandler = TransitionHandler();
  final NavigationController _navController = NavigationController();

  String _transitPreference = 'lift';
  Node? _startNode;
  Node? _destinationNode;
  MultiFloorRoute? _activeMultiRoute;
  bool _isCalculatingRoute = false;
  int _rerouteCounter = 0;

  // Proxy getters
  NavGraph? get graph => floorManager.activeGraph; // Kept 'graph' for backward compatibility
  bool get isLoading => floorManager.isLoading;
  int get activeFloor => floorManager.activeFloor;
  String get activeFloorName => floorManager.activeFloorName;
  String get transitPreference => _transitPreference;
  Node? get startNode => _startNode;
  Node? get destinationNode => _destinationNode;
  bool get isCalculatingRoute => _isCalculatingRoute;

  /// Returns the route segment for the currently-viewed floor (used for map overlay).
  RouteResult? get activeRoute {
    if (_activeMultiRoute == null) return null;
    
    // Return whichever segment belongs to the currently-viewed floor.
    if (_startNode != null && _startNode!.floor == activeFloor) {
        return _activeMultiRoute!.currentSegment;
    }
    if (_activeMultiRoute!.nextFloor == activeFloor || (_destinationNode != null && _destinationNode!.floor == activeFloor)) {
        return _activeMultiRoute!.nextSegment ?? _activeMultiRoute!.currentSegment;
    }
    // Fallback: still return it so the overlay is visible when the user navigates back.
    return _activeMultiRoute!.currentSegment;
  }

  /// Returns the full combined route across all floors (used for simulation & directions).
  /// This merges currentSegment + nextSegment into a single continuous route.
  RouteResult? get fullRoute {
    if (_activeMultiRoute == null) return null;
    
    final current = _activeMultiRoute!.currentSegment;
    final next = _activeMultiRoute!.nextSegment;
    
    // Single-floor route or no next segment — just return current
    if (next == null || current == null) return current ?? next;
    
    // Multi-floor: merge both segments into one continuous route
    final mergedPath = <Node>[...current.path, ...next.path];
    final mergedFloors = <int>{...current.floorsVisited, ...next.floorsVisited};
    final mergedSteps = <NavigationInstruction>[...current.steps];
    
    // Offset the next segment's step pathIndices by the current segment's path length
    final offset = current.path.length;
    for (final step in next.steps) {
      mergedSteps.add(NavigationInstruction(
        maneuver: step.maneuver,
        semanticType: step.semanticType,
        localizedInstructions: step.localizedInstructions,
        distanceMeters: step.distanceMeters,
        pathIndex: step.pathIndex + offset,
        landmarkKey: step.landmarkKey,
        targetLabelKey: step.targetLabelKey,
        targetFloor: step.targetFloor,
      ));
    }
    
    final mergedTurnIndices = <int>[
      ...current.turnPointIndices,
      ...next.turnPointIndices.map((i) => i + offset),
    ];
    
    PathAnalysis? mergedAnalysis;
    if (current.analysis != null && next.analysis != null) {
      mergedAnalysis = PathAnalysis(
        segments: [
          ...current.analysis!.segments,
          ...next.analysis!.segments.map((s) => PathSegment(
            startPathIndex: s.startPathIndex + offset,
            endPathIndex: s.endPathIndex + offset,
            distanceMeters: s.distanceMeters,
          )),
        ],
        turnEvents: [
          ...current.analysis!.turnEvents,
          ...next.analysis!.turnEvents.map((t) => TurnEvent(
            pathIndex: t.pathIndex + offset,
            turnType: t.turnType,
            landmark: t.landmark,
          )),
        ],
        totalDistanceMeters: current.analysis!.totalDistanceMeters + next.analysis!.totalDistanceMeters,
      );
    }
    
    return RouteResult(
      path: mergedPath,
      totalDistance: current.totalDistance + next.totalDistance,
      floorsVisited: mergedFloors,
      steps: mergedSteps,
      turnPointIndices: mergedTurnIndices,
      analysis: mergedAnalysis,
    );
  }
  
  NavigationProvider() {
    _init();
  }

  Future<void> _init() async {
    floorManager.addListener(notifyListeners);
    transitionHandler.addListener(notifyListeners);
    await floorManager.loadFloors();
  }

  @override
  void dispose() {
    floorManager.removeListener(notifyListeners);
    transitionHandler.removeListener(notifyListeners);
    floorManager.dispose();
    transitionHandler.dispose();
    super.dispose();
  }

  void setFloor(int floor) {
    floorManager.switchFloor(floor);
  }

  void setTransitPreference(String value) {
    if (_transitPreference != value) {
        _transitPreference = value;
        _calculateRoute();
        notifyListeners();
    }
  }

  void setStartNode(Node node) {
    _startNode = node;
    floorManager.switchFloor(node.floor);
    _calculateRoute();
    notifyListeners();
  }

  void setDestinationNode(Node node) {
    _destinationNode = node;
    _calculateRoute();
    notifyListeners();
  }

  void clearRoute() {
    _startNode = null;
    _destinationNode = null;
    _activeMultiRoute = null;
    transitionHandler.cancelTransition();
    notifyListeners();
  }

  void swapNodes() {
    final temp = _startNode;
    _startNode = _destinationNode;
    _destinationNode = temp;
    if (_startNode != null) {
      floorManager.switchFloor(_startNode!.floor);
    }
    _calculateRoute();
    notifyListeners();
  }

  void clearStart() {
    _startNode = null;
    _activeMultiRoute = null;
    transitionHandler.cancelTransition();
    notifyListeners();
  }

  void clearDestination() {
    _destinationNode = null;
    _activeMultiRoute = null;
    transitionHandler.cancelTransition();
    notifyListeners();
  }

  void _calculateRoute() {
    if (_startNode != null && _destinationNode != null) {
      _isCalculatingRoute = true;
      notifyListeners();

      // Use a microtask to allow the 'loading' state to render before the heavy calculation starts
      Future.microtask(() {
        _activeMultiRoute = _navController.computeRoute(
          startNode: _startNode!,
          destNode: _destinationNode!,
          floorManager: floorManager,
          currentFloor: _startNode!.floor,
          transitPreference: _transitPreference,
        );
        _isCalculatingRoute = false;
        notifyListeners();
      });
    } else {
      _activeMultiRoute = null;
      _isCalculatingRoute = false;
    }
  }

  List<Node> searchRooms(String query, SettingsProvider settingsProvider) {
    if (floorManager.floorGraphs.isEmpty || query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    List<Node> results = [];
    for (var g in floorManager.floorGraphs.values) {
        results.addAll(g.nodes.values.where((n) {
          if (n.label == null) return false;
          final transliterated = settingsProvider.transliterateLabel(n.label!).toLowerCase();
          final fallbackLabel = n.label!.replaceAll('_', ' ').toLowerCase();
          return transliterated.contains(lowerQuery) || fallbackLabel.contains(lowerQuery);
        }));
    }
    return results;
  }
  
  bool checkTransition(Node currentNode) {
      if (_activeMultiRoute?.transitionNode != null && currentNode.id == _activeMultiRoute!.transitionNode!.id) {
          if (!transitionHandler.isTransitionPending && activeFloor == _startNode?.floor) {
              int nextF = _activeMultiRoute!.nextFloor ?? (_destinationNode?.floor ?? 0);
              transitionHandler.triggerTransition(_activeMultiRoute!.transitionNode!, nextF);
              return true;
          }
      }
      return false;
  }
  
  void confirmTransition() {
      if (transitionHandler.targetFloor != null) {
          int nextF = transitionHandler.targetFloor!;
          transitionHandler.completeTransition();
          setFloor(nextF);
      }
  }

  UserPosition processPdrUpdate(UserPosition raw) {
    final route = activeRoute;
    if (route == null || route.path.isEmpty || graph == null) {
      return raw;
    }

    double minDistance = double.infinity;
    double snapX = raw.x;
    double snapY = raw.y;
    int snapFloor = raw.floor;
    bool isOnPath = false;

    for (int i = 0; i < route.path.length - 1; i++) {
      Node a = route.path[i];
      Node b = route.path[i + 1];

      if (a.floor != raw.floor || b.floor != raw.floor) continue;

      double l2 = pow(a.x - b.x, 2).toDouble() + pow(a.y - b.y, 2).toDouble();
      if (l2 == 0) continue;

      double t = ((raw.x - a.x) * (b.x - a.x) + (raw.y - a.y) * (b.y - a.y)) / l2;
      t = max(0, min(1, t));

      double projX = a.x + t * (b.x - a.x);
      double projY = a.y + t * (b.y - a.y);

      double dist = sqrt(pow(raw.x - projX, 2) + pow(raw.y - projY, 2));

      if (dist < minDistance) {
        minDistance = dist;
        snapX = projX;
        snapY = projY;
        snapFloor = a.floor;
        isOnPath = true;
      }
    }

    const double deviationThreshold = 150.0;

    if (isOnPath && minDistance <= deviationThreshold) {
      _rerouteCounter = 0;
      
      // Check for transition nodes nearby while walking
      if (minDistance < 40.0) {
         for (var node in route.path) {
             if (sqrt(pow(raw.x - node.x, 2) + pow(raw.y - node.y, 2)) < 40.0) {
                 checkTransition(node);
                 break;
             }
         }
      }

      return raw.copyWith(x: snapX, y: snapY, floor: snapFloor);
    } else {
      // User is deviated
      _rerouteCounter++;
      if (_rerouteCounter >= 10 && _destinationNode != null) {
        _rerouteCounter = 0;
        _triggerReroute(raw);
      }
      return raw;
    }
  }

  void _triggerReroute(UserPosition pos) {
    final currentGraph = floorManager.floorGraphs[pos.floor];
    if (currentGraph == null) return;
    
    Node? nearest;
    double minDist = double.infinity;
    
    for (var node in currentGraph.nodes.values) {
        double d = sqrt(pow(node.x - pos.x, 2) + pow(node.y - pos.y, 2));
        if (d < minDist) {
            minDist = d;
            nearest = node;
        }
    }
    
    if (nearest != null) {
        debugPrint('[REROUTE] User deviated. Recalculating from ${nearest.label ?? nearest.id}');
        _startNode = nearest;
        _calculateRoute();
        notifyListeners();
    }
  }
}

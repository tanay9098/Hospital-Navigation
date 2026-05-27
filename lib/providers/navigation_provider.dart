import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hospital_nav/models/nav_graph.dart';
import 'package:hospital_nav/models/node.dart';
import 'package:hospital_nav/models/edge.dart';
import 'package:hospital_nav/models/floor_config.dart';
import 'package:hospital_nav/models/route_result.dart';
import 'package:hospital_nav/models/navigation_instruction.dart';
import 'package:hospital_nav/models/user_position.dart';
import 'package:hospital_nav/services/floor_manager.dart';
import 'package:hospital_nav/services/transition_handler.dart';
import 'package:hospital_nav/controllers/navigation_controller.dart';
import 'package:hospital_nav/providers/settings_provider.dart';
import 'package:hospital_nav/services/path_analyzer.dart';
import 'package:hospital_nav/services/path_tracker.dart';

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
  
  final PathTracker _pathTracker = PathTracker();
  UserPosition? _lastRawPos;

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

  void _cleanupAllTempNodes() {
    for (var graph in floorManager.floorGraphs.values) {
      if (graph.nodes.containsKey('TEMP_USER_NODE')) {
        graph.nodes.remove('TEMP_USER_NODE');
        graph.adjacencyList.remove('TEMP_USER_NODE');
        for (var list in graph.adjacencyList.values) {
          list.removeWhere((edge) => edge.toNode == 'TEMP_USER_NODE');
        }
      }
    }
  }

  void setTransitPreference(String value) {
    if (_transitPreference != value) {
        _transitPreference = value;
        _calculateRoute();
        notifyListeners();
    }
  }

  void setStartNode(Node node) {
    _cleanupAllTempNodes();
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
    _cleanupAllTempNodes();
    _startNode = null;
    _destinationNode = null;
    _activeMultiRoute = null;
    _pathTracker.reset();
    _lastRawPos = null;
    transitionHandler.cancelTransition();
    notifyListeners();
  }

  void swapNodes() {
    _cleanupAllTempNodes();
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
    _cleanupAllTempNodes();
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
        
        if (_activeMultiRoute != null) {
          _pathTracker.setRoute(_activeMultiRoute!.currentSegment?.path ?? []);
        } else {
          _pathTracker.reset();
        }
        _lastRawPos = null;

        _isCalculatingRoute = false;
        notifyListeners();
      });
    } else {
      _activeMultiRoute = null;
      _pathTracker.reset();
      _lastRawPos = null;
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
  
  /// Confirms a floor transition: promotes the next-floor route segment to
  /// the active segment, resets the path tracker, switches the viewed floor,
  /// and returns the landing node on the new floor (if any) so the PDR
  /// position can be relocated.
  Node? confirmTransition() {
      if (transitionHandler.targetFloor != null) {
          int nextF = transitionHandler.targetFloor!;
          transitionHandler.completeTransition();

          // Promote the next-floor segment to the active segment.
          Node? landingNode;
          if (_activeMultiRoute != null && _activeMultiRoute!.nextSegment != null) {
            final nextSeg = _activeMultiRoute!.nextSegment!;
            _activeMultiRoute = MultiFloorRoute(
              currentSegment: nextSeg,
            );
            // Reset the path tracker to follow the new floor's path.
            _pathTracker.setRoute(nextSeg.path);
            if (nextSeg.path.isNotEmpty) {
              landingNode = nextSeg.path.first;
            }
          } else {
            _pathTracker.reset();
          }

          setFloor(nextF);
          return landingNode;
      }
      return null;
  }

  UserPosition snapPdrPosition(UserPosition raw, double stepLengthPixels) {
    if (_activeMultiRoute == null || _activeMultiRoute!.currentSegment == null || _activeMultiRoute!.currentSegment!.path.isEmpty) {
      _pathTracker.reset();
      return raw;
    }

    if (!_pathTracker.hasRoute) {
      _pathTracker.setRoute(_activeMultiRoute!.currentSegment!.path);
    }

    if (stepLengthPixels > 0.001) {
      PathTrackerState state = _pathTracker.updateWithStep(stepLengthPixels, raw.heading, raw);
      
      if (state.deviated) {
        _triggerReroute(raw);
        return raw;
      }
      
      if (state.floor == activeFloor) {
        for (var node in _activeMultiRoute!.currentSegment!.path) {
          if (sqrt(pow(state.x - node.x, 2) + pow(state.y - node.y, 2)) < 40.0) {
            checkTransition(node);
            break;
          }
        }
      }
      
      return raw.copyWith(x: state.x, y: state.y, floor: state.floor);
    } else {
      if (_pathTracker.currentState != null) {
        return raw.copyWith(
          x: _pathTracker.currentState!.x,
          y: _pathTracker.currentState!.y,
          floor: _pathTracker.currentState!.floor,
        );
      }
      return raw;
    }
  }

  void _triggerReroute(UserPosition pos) {
    _cleanupAllTempNodes();
    
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
        final tempNode = Node(
          id: 'TEMP_USER_NODE',
          x: pos.x,
          y: pos.y,
          floor: pos.floor,
          type: 'junction',
          accessible: true,
        );
        
        currentGraph.nodes['TEMP_USER_NODE'] = tempNode;
        currentGraph.adjacencyList['TEMP_USER_NODE'] = [
          Edge(
            fromNode: 'TEMP_USER_NODE',
            toNode: nearest.id,
            distance: minDist,
            type: 'corridor',
            bidirectional: true,
          )
        ];
        
        currentGraph.adjacencyList[nearest.id]?.add(
          Edge(
            fromNode: nearest.id,
            toNode: 'TEMP_USER_NODE',
            distance: minDist,
            type: 'corridor',
            bidirectional: true,
          )
        );

        debugPrint('[REROUTE] User deviated. Recalculating from exact coordinates');
        _startNode = tempNode;
        _calculateRoute();
        notifyListeners();
    }
  }
}

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hospital_nav/models/node.dart';
import 'package:hospital_nav/models/route_result.dart';

class SimulationProvider extends ChangeNotifier {
  bool _isSimulating = false;
  bool _isAutoMode = true;
  double _currentX = 0;
  double _currentY = 0;
  int _currentFloor = 0;
  int _currentStepIndex = 0;
  Timer? _timer;
  RouteResult? _currentRoute;
  void Function(Node)? _onNodeReached;
  void Function(int)? _onFloorChanged;
  VoidCallback? _onArrived;

  bool get isSimulating => _isSimulating;
  bool get isAutoMode => _isAutoMode;
  double get currentX => _currentX;
  double get currentY => _currentY;
  int get currentFloor => _currentFloor;
  int get currentStepIndex => _currentStepIndex;
  RouteResult? get currentRoute => _currentRoute;

  void startSimulation(RouteResult route, {
    void Function(Node)? onNodeReached,
    void Function(int)? onFloorChanged,
    VoidCallback? onArrived,
  }) {
    if (route.path.isEmpty) return;
    
    _currentRoute = route;
    _onNodeReached = onNodeReached;
    _onFloorChanged = onFloorChanged;
    _onArrived = onArrived;
    _isSimulating = true;
    _isAutoMode = true;
    _currentStepIndex = 0;
    
    _currentX = route.path.first.x;
    _currentY = route.path.first.y;
    _currentFloor = route.path.first.floor;
    notifyListeners();

    _startTimer();
  }

  void toggleAutoMode() {
    _isAutoMode = !_isAutoMode;
    if (_isAutoMode) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
    notifyListeners();
  }

  void pauseSimulation() {
    _isAutoMode = false;
    _timer?.cancel();
    notifyListeners();
  }

  void resumeSimulation() {
    _isAutoMode = true;
    _startTimer();
    notifyListeners();
  }

  void jumpToInstruction(int pathIndex) {
    if (_currentRoute == null || pathIndex < 0 || pathIndex >= _currentRoute!.path.length) return;
    
    _isAutoMode = false;
    _timer?.cancel();
    
    final targetNode = _currentRoute!.path[pathIndex];
    _currentX = targetNode.x;
    _currentY = targetNode.y;
    
    // Auto-switch floor if the target node is on a different floor
    if (_currentFloor != targetNode.floor) {
      _currentFloor = targetNode.floor;
      if (_onFloorChanged != null) {
        _onFloorChanged!(_currentFloor);
      }
    }
    
    _currentStepIndex = pathIndex;
    notifyListeners();
    
    if (_onNodeReached != null) {
      _onNodeReached!(targetNode);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_currentRoute == null || _currentStepIndex >= _currentRoute!.path.length - 1) {
        _onArrived?.call();
        stopSimulation();
        return;
      }
      
      final route = _currentRoute!;
      double remainingSpeed = 1.2; // pixels per tick (approx 75 px/s)
      Node? nodeJustReached;
      
      while (remainingSpeed > 0 && _currentStepIndex < route.path.length - 1) {
        Node currentTarget = route.path[_currentStepIndex + 1];
        
        // Handle floor jumps — teleport to the new floor's node position
        if (_currentFloor != currentTarget.floor) {
           _currentFloor = currentTarget.floor;
           _currentX = currentTarget.x;
           _currentY = currentTarget.y;
           _currentStepIndex++;
           nodeJustReached = currentTarget;
           // Notify the UI to switch the map floor
           if (_onFloorChanged != null) {
             _onFloorChanged!(_currentFloor);
           }
           notifyListeners();
           return;
        }

        double dx = currentTarget.x - _currentX;
        double dy = currentTarget.y - _currentY;
        double dist = _distance(_currentX, _currentY, currentTarget.x, currentTarget.y);

        if (dist <= remainingSpeed) {
          _currentX = currentTarget.x;
          _currentY = currentTarget.y;
          _currentStepIndex++;
          remainingSpeed -= dist;
          nodeJustReached = currentTarget; // Don't call inside the loop
        } else {
          _currentX += (dx / dist) * remainingSpeed;
          _currentY += (dy / dist) * remainingSpeed;
          remainingSpeed = 0;
        }
      }
      
      notifyListeners();
      
      // Call the callback AFTER the loop and listener notifications
      if (nodeJustReached != null && _onNodeReached != null) {
        _onNodeReached!(nodeJustReached);
      }
    });
  }

  void stopSimulation() {
    _isSimulating = false;
    _currentRoute = null;
    _onNodeReached = null;
    _onFloorChanged = null;
    _onArrived = null;
    _timer?.cancel();
    notifyListeners();
  }

  double _distance(double x1, double y1, double x2, double y2) {
    return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
  }
}

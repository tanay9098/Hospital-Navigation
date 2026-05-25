import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hospital_nav/models/node.dart';
import 'package:hospital_nav/models/user_position.dart';

class PathTrackerState {
  final double x;
  final double y;
  final int floor;
  final bool deviated;

  PathTrackerState(this.x, this.y, this.floor, this.deviated);
}

class PathTracker {
  List<Node> _path = [];
  int _targetIndex = 1;
  double _distanceAlongEdge = 0.0;
  int _deviationCount = 0;
  PathTrackerState? _currentState;
  
  static const int maxDeviations = 4;
  static const double deviationAngleThreshold = pi / 3; // 60 degrees

  PathTrackerState? get currentState => _currentState;

  void setRoute(List<Node> newPath) {
    _path = newPath;
    _targetIndex = 1;
    _distanceAlongEdge = 0.0;
    _deviationCount = 0;
    _currentState = null;
  }

  void reset() {
    _path = [];
    _targetIndex = 1;
    _distanceAlongEdge = 0.0;
    _deviationCount = 0;
    _currentState = null;
  }
  
  bool get hasRoute => _path.isNotEmpty;

  /// Updates the tracker with a new step of length `L` (pixels) in direction `heading` (radians).
  /// Returns the strictly clamped UserPosition or a deviation flag.
  PathTrackerState updateWithStep(double stepLengthPixels, double heading, UserPosition fallbackPosition) {
    if (_path.isEmpty || _targetIndex >= _path.length) {
      // If we finished the path or have no path, we are freely walking.
      return PathTrackerState(
        fallbackPosition.x + stepLengthPixels * sin(heading),
        fallbackPosition.y - stepLengthPixels * cos(heading),
        fallbackPosition.floor,
        false
      );
    }

    Node startNode = _path[_targetIndex - 1];
    Node targetNode = _path[_targetIndex];

    // If floor changes, just stay at the transition node until floor switches
    if (startNode.floor != fallbackPosition.floor) {
      return PathTrackerState(startNode.x, startNode.y, startNode.floor, false);
    }

    // Calculate edge vector and length
    double dx = targetNode.x - startNode.x;
    double dy = targetNode.y - startNode.y;
    double edgeLength = sqrt(dx * dx + dy * dy);

    if (edgeLength == 0) {
      _targetIndex++;
      return updateWithStep(stepLengthPixels, heading, fallbackPosition);
    }

    // Calculate Edge Angle (0 = North/Up, pi/2 = East/Right)
    double edgeAngle = atan2(dx, -dy);

    // Calculate angle difference
    double diff = heading - edgeAngle;
    while (diff > pi) diff -= 2 * pi;
    while (diff < -pi) diff += 2 * pi;

    // Check for deviation
    if (diff.abs() > deviationAngleThreshold) {
      _deviationCount++;
      if (_deviationCount >= maxDeviations) {
        debugPrint('[PathTracker] User deviated from path! Angle diff: ${diff.toStringAsFixed(2)} rad');
        return PathTrackerState(
          fallbackPosition.x + stepLengthPixels * sin(heading),
          fallbackPosition.y - stepLengthPixels * cos(heading),
          fallbackPosition.floor,
          true // DEVIATED
        );
      }
    } else {
      _deviationCount = 0; // Reset on good step
    }

    // Project step along the edge
    double projectedStep = stepLengthPixels * cos(diff);
    _distanceAlongEdge += projectedStep;

    // Constrain backwards walking to the start of the current edge
    if (_distanceAlongEdge < 0) {
      _distanceAlongEdge = 0;
    }

    // Check if we reached the target node
    while (_distanceAlongEdge >= edgeLength) {
      _distanceAlongEdge -= edgeLength;
      _targetIndex++;

      if (_targetIndex >= _path.length) {
        // Reached destination!
        _distanceAlongEdge = 0;
        _targetIndex = _path.length - 1; // Clamp to end
        Node last = _path.last;
        return PathTrackerState(last.x, last.y, last.floor, false);
      }

      // Update to new edge for remaining distance
      startNode = _path[_targetIndex - 1];
      targetNode = _path[_targetIndex];
      dx = targetNode.x - startNode.x;
      dy = targetNode.y - startNode.y;
      edgeLength = sqrt(dx * dx + dy * dy);
    }

    // Interpolate exact position along the edge
    double t = _distanceAlongEdge / edgeLength;
    double newX = startNode.x + t * dx;
    double newY = startNode.y + t * dy;

    _currentState = PathTrackerState(newX, newY, startNode.floor, false);
    return _currentState!;
  }
}

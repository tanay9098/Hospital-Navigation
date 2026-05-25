import 'package:flutter/foundation.dart';
import 'package:hospital_nav/models/node.dart';

class TransitionHandler extends ChangeNotifier {
  bool _isTransitionPending = false;
  Node? _pendingTransitionNode;
  int? _targetFloor;

  bool get isTransitionPending => _isTransitionPending;
  Node? get pendingTransitionNode => _pendingTransitionNode;
  int? get targetFloor => _targetFloor;

  void triggerTransition(Node transitionNode, int target) {
    _isTransitionPending = true;
    _pendingTransitionNode = transitionNode;
    _targetFloor = target;
    notifyListeners();
  }

  void completeTransition() {
    _isTransitionPending = false;
    _pendingTransitionNode = null;
    _targetFloor = null;
    notifyListeners();
  }

  void cancelTransition() {
    _isTransitionPending = false;
    _pendingTransitionNode = null;
    _targetFloor = null;
    notifyListeners();
  }
}

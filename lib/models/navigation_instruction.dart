import 'package:flutter/material.dart';

enum ManeuverType {
  start,
  straight,
  slightLeft,
  left,
  slightRight,
  right,
  floorChange,
  arrive,
}

class NavigationInstruction {
  final ManeuverType maneuver;
  final String text;
  final double distanceMeters;
  final int pathIndex;

  const NavigationInstruction({
    required this.maneuver,
    required this.text,
    this.distanceMeters = 0.0,
    this.pathIndex = 0,
  });

  IconData get icon {
    switch (maneuver) {
      case ManeuverType.start:
        return Icons.play_arrow;
      case ManeuverType.straight:
        return Icons.straight;
      case ManeuverType.slightLeft:
        return Icons.turn_slight_left;
      case ManeuverType.left:
        return Icons.turn_left;
      case ManeuverType.slightRight:
        return Icons.turn_slight_right;
      case ManeuverType.right:
        return Icons.turn_right;
      case ManeuverType.floorChange:
        return Icons.swap_vert;
      case ManeuverType.arrive:
        return Icons.flag;
    }
  }
}

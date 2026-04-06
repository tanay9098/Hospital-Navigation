import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// A single step in a navigation route.
class NavigationStep {
  final int step;
  final String type;         // start | walk | elevator | stairs | transit | arrival
  final String locationCode;
  final String locationName;
  final int floor;
  final String? direction;   // north | south | east | west | up | down | …
  final double distance;     // metres
  final String text;         // human-readable instruction
  final String voice;        // TTS-optimised instruction

  const NavigationStep({
    required this.step,
    required this.type,
    required this.locationCode,
    required this.locationName,
    required this.floor,
    this.direction,
    required this.distance,
    required this.text,
    required this.voice,
  });

  factory NavigationStep.fromJson(Map<String, dynamic> json) {
    return NavigationStep(
      step: (json['step'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? 'walk',
      locationCode: json['locationCode'] as String? ?? '',
      locationName: json['locationName'] as String? ?? '',
      floor: (json['floor'] as num?)?.toInt() ?? 0,
      direction: json['direction'] as String?,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      text: json['text'] as String? ?? '',
      voice: json['voice'] as String? ?? '',
    );
  }

  Color get stepColor {
    switch (type) {
      case 'start':    return AppTheme.stepStart;
      case 'walk':     return AppTheme.stepWalk;
      case 'elevator': return AppTheme.stepElevator;
      case 'stairs':   return AppTheme.stepStairs;
      case 'transit':  return AppTheme.stepTransit;
      case 'arrival':  return AppTheme.stepArrival;
      default:         return AppTheme.stepWalk;
    }
  }

  IconData get stepIcon {
    switch (type) {
      case 'start':    return Icons.my_location;
      case 'walk':     return Icons.directions_walk;
      case 'elevator': return Icons.elevator_outlined;
      case 'stairs':   return Icons.stairs_outlined;
      case 'transit':  return Icons.swap_horiz;
      case 'arrival':  return Icons.place;
      default:         return Icons.directions_walk;
    }
  }

  bool get isVertical => type == 'elevator' || type == 'stairs';
  bool get isArrival  => type == 'arrival';
  bool get isStart    => type == 'start';

  @override
  String toString() => 'Step $step: $text';
}

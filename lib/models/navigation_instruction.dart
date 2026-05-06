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

/// Semantic intent produced by DirectionGenerator.
/// Contains NO user-facing strings — only structured data.
class SemanticIntent {
  final ManeuverType maneuver;
  final double distanceMeters;
  final int pathIndex;
  final String? landmarkLabelKey; // e.g. "pharmacy" — a label key, not display text
  final String? targetLabelKey;   // for start/arrive — label key of the target node
  final int? targetFloor;         // for floor changes

  const SemanticIntent({
    required this.maneuver,
    this.distanceMeters = 0.0,
    this.pathIndex = 0,
    this.landmarkLabelKey,
    this.targetLabelKey,
    this.targetFloor,
  });
}

/// Final rendered instruction containing pre-localized text for all languages.
class NavigationInstruction {
  final ManeuverType maneuver;
  final double distanceMeters;
  final int pathIndex;
  final String semanticType;
  final String? landmarkKey;
  final String? targetLabelKey;
  final int? targetFloor;

  /// Pre-computed localized text for each supported language.
  /// Key is language code (e.g. "en", "kn", "hi").
  final Map<String, String> localizedInstructions;

  const NavigationInstruction({
    required this.maneuver,
    required this.semanticType,
    required this.localizedInstructions,
    this.distanceMeters = 0.0,
    this.pathIndex = 0,
    this.landmarkKey,
    this.targetLabelKey,
    this.targetFloor,
  });

  /// Get the instruction text for a given language, falling back to English.
  String textForLang(String langCode) {
    return localizedInstructions[langCode]
        ?? localizedInstructions['en']
        ?? '';
  }

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

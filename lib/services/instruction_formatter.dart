import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hospital_nav/models/navigation_instruction.dart';
import 'package:hospital_nav/services/transliteration_service.dart';

/// Natural Language Generation (NLG) engine.
/// Converts semantic navigation intents into human-like, context-aware,
/// localized instruction text for all supported languages.
class InstructionFormatter {
  /// Loaded language data: langCode -> { key -> value (String or List<String>) }
  final Map<String, Map<String, dynamic>> _langData = {};

  /// Track last used variation index per key per language to avoid repetition.
  final Map<String, int> _variationCounters = {};

  final TransliterationService _translit = TransliterationService.instance;

  static const List<String> _supportedLangs = ['en', 'kn', 'hi', 'ta', 'te'];

  /// Load all language files. Must be called before formatting.
  Future<void> loadAll() async {
    for (final lang in _supportedLangs) {
      try {
        final jsonStr = await rootBundle.loadString('assets/lang/$lang.json');
        final Map<String, dynamic> raw = json.decode(jsonStr);
        // Flatten nested nav keys but keep arrays intact
        _langData[lang] = _flattenKeepArrays(raw);
      } catch (e) {
        // Silently skip if a language file is missing
      }
    }
  }

  /// Flatten nested JSON but preserve List<dynamic> values as List<String>.
  Map<String, dynamic> _flattenKeepArrays(Map<String, dynamic> json, [String prefix = '']) {
    final Map<String, dynamic> result = {};
    json.forEach((key, value) {
      final newKey = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map<String, dynamic>) {
        result.addAll(_flattenKeepArrays(value, newKey));
      } else if (value is List) {
        result[newKey] = value.map((e) => e.toString()).toList();
      } else {
        result[newKey] = value.toString();
      }
    });
    return result;
  }

  /// Pick a variation from an array key, cycling deterministically
  /// to avoid consecutive repetition.
  String _pickVariation(String lang, String key) {
    final data = _langData[lang];
    if (data == null) return key;

    final value = data[key];
    if (value == null) return key;

    if (value is String) return value;
    if (value is List && value.isNotEmpty) {
      final counterKey = '$lang:$key';
      final idx = (_variationCounters[counterKey] ?? 0) % value.length;
      _variationCounters[counterKey] = idx + 1;
      return value[idx].toString();
    }
    return key;
  }

  /// Substitute {placeholders} in a template string.
  String _applyArgs(String template, Map<String, String> args) {
    var result = template;
    args.forEach((k, v) {
      result = result.replaceAll('{$k}', v);
    });
    return result;
  }

  /// Get label display name using transliteration (NOT translation).
  String _labelName(String? labelKey, String lang) {
    if (labelKey == null || labelKey.isEmpty) {
      return _pickVariation(lang, 'nav.your_location');
    }
    return _translit.transliterate(labelKey, lang);
  }

  /// Determine urgency from distance.
  String _urgency(double meters) {
    if (meters <= 5) return 'immediate';
    if (meters <= 15) return 'near';
    if (meters <= 35) return 'medium';
    return 'far';
  }

  /// Convert a list of SemanticIntents into fully localized NavigationInstructions.
  List<NavigationInstruction> format(List<SemanticIntent> intents) {
    final instructions = <NavigationInstruction>[];

    for (final intent in intents) {
      final localized = <String, String>{};

      for (final lang in _supportedLangs) {
        localized[lang] = _formatOne(intent, lang);
      }

      instructions.add(NavigationInstruction(
        maneuver: intent.maneuver,
        semanticType: _semanticType(intent.maneuver),
        localizedInstructions: localized,
        distanceMeters: intent.distanceMeters,
        pathIndex: intent.pathIndex,
        landmarkKey: intent.landmarkLabelKey,
        targetLabelKey: intent.targetLabelKey,
        targetFloor: intent.targetFloor,
      ));
    }

    return _dedupeInstructions(instructions);
  }

  /// Format a single intent for a single language.
  String _formatOne(SemanticIntent intent, String lang) {
    switch (intent.maneuver) {
      case ManeuverType.start:
        return _formatStart(intent, lang);
      case ManeuverType.arrive:
        return _formatArrive(intent, lang);
      case ManeuverType.floorChange:
        return _formatFloorChange(intent, lang);
      default:
        return _formatTurn(intent, lang);
    }
  }

  String _formatStart(SemanticIntent intent, String lang) {
    final location = _labelName(intent.targetLabelKey, lang);
    final template = _pickVariation(lang, 'nav.start_at');
    return _applyArgs(template, {'location': location});
  }

  String _formatArrive(SemanticIntent intent, String lang) {
    final location = _labelName(intent.targetLabelKey, lang);
    final dist = intent.distanceMeters;

    if (dist > 5.0) {
      final template = _pickVariation(lang, 'nav.arrive_at_dist');
      return _applyArgs(template, {
        'dist': dist.toStringAsFixed(0),
        'location': location,
      });
    } else {
      final template = _pickVariation(lang, 'nav.arrived_at');
      return _applyArgs(template, {'location': location});
    }
  }

  String _formatFloorChange(SemanticIntent intent, String lang) {
    final floor = intent.targetFloor?.toString() ?? '?';
    final template = _pickVariation(lang, 'nav.go_to_floor');
    final landmark = _landmarkSuffix(intent, lang);
    return _applyArgs(template, {'floor': floor}) + landmark;
  }

  String _formatTurn(SemanticIntent intent, String lang) {
    final urgency = _urgency(intent.distanceMeters);
    final actionKey = _turnKey(intent.maneuver);
    final landmark = _landmarkSuffix(intent, lang);
    final action = _pickVariation(lang, actionKey);

    if (action.isEmpty) return action;

    switch (urgency) {
      case 'immediate':
        return '${action[0].toUpperCase()}${action.substring(1)}$landmark';
      case 'near':
        final template = _pickVariation(lang, 'nav.next_action');
        return '${_applyArgs(template, {'action': action})}$landmark';
      case 'medium':
        final template = _pickVariation(lang, 'nav.in_meters_action');
        return '${_applyArgs(template, {
          'dist': intent.distanceMeters.toStringAsFixed(0),
          'action': action,
        })}$landmark';
      case 'far':
      default:
        final template = _pickVariation(lang, 'nav.keep_going_then_action');
        return '${_applyArgs(template, {'action': action})}$landmark';
    }
  }

  String _landmarkSuffix(SemanticIntent intent, String lang) {
    if (intent.landmarkLabelKey == null || intent.landmarkLabelKey!.isEmpty) {
      return '';
    }
    final name = _labelName(intent.landmarkLabelKey, lang);
    final template = _pickVariation(lang, 'nav.near_landmark');
    return _applyArgs(template, {'landmark': name});
  }

  String _turnKey(ManeuverType maneuver) {
    switch (maneuver) {
      case ManeuverType.left: return 'nav.turn_left';
      case ManeuverType.right: return 'nav.turn_right';
      case ManeuverType.slightLeft: return 'nav.bear_left';
      case ManeuverType.slightRight: return 'nav.bear_right';
      case ManeuverType.straight: return 'nav.continue_straight';
      default: return 'nav.continue_straight';
    }
  }

  List<NavigationInstruction> _dedupeInstructions(List<NavigationInstruction> instructions) {
    if (instructions.length < 2) return instructions;
    final result = <NavigationInstruction>[];
    for (final step in instructions) {
      if (result.isEmpty || result.last.textForLang('en') != step.textForLang('en')) {
        result.add(step);
      }
    }
    return result;
  }

  String _semanticType(ManeuverType maneuver) {
    switch (maneuver) {
      case ManeuverType.start:
        return 'start';
      case ManeuverType.straight:
        return 'continue_straight';
      case ManeuverType.slightLeft:
        return 'bear_left';
      case ManeuverType.left:
        return 'turn_left';
      case ManeuverType.slightRight:
        return 'bear_right';
      case ManeuverType.right:
        return 'turn_right';
      case ManeuverType.floorChange:
        return 'floor_change';
      case ManeuverType.arrive:
        return 'arrive';
    }
  }
}

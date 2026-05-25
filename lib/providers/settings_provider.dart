import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hospital_nav/services/audio_service.dart';
import 'package:hospital_nav/services/transliteration_service.dart';
import 'package:hospital_nav/services/instruction_formatter.dart';

class SettingsProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  
  String _selectedLanguageCode = 'en';
  bool _isVoiceEnabled = true;
  bool _isInitialized = false;

  /// Flat key-value strings for simple UI translations (non-array values).
  Map<String, String> _localizedStrings = {};
  final AudioService _audioService = AudioService();
  final TransliterationService _translitService = TransliterationService.instance;
  final InstructionFormatter instructionFormatter = InstructionFormatter();

  String get selectedLanguageCode => _selectedLanguageCode;
  bool get isVoiceEnabled => _isVoiceEnabled;
  bool get isInitialized => _isInitialized;

  final Map<String, String> supportedLanguages = {
    'en': 'English',
    'kn': 'ಕನ್ನಡ',
    'hi': 'हिन्दी',
    'ta': 'தமிழ்',
    'te': 'తెలుగు',
  };

  SettingsProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final savedCode = _prefs?.getString('language_code');
      _selectedLanguageCode = (savedCode != null && supportedLanguages.containsKey(savedCode)) ? savedCode : 'en';
      _isVoiceEnabled = _prefs?.getBool('voice_enabled') ?? true;
      
      try {
        await _audioService.init();
      } catch (e) {
        debugPrint('AudioService init failed: $e');
      }

      // Load instruction formatter language data for NLG
      await instructionFormatter.loadAll();

      if (_selectedLanguageCode.isNotEmpty) {
        await loadLanguage(_selectedLanguageCode);
      }
    } catch (e) {
      debugPrint('SettingsProvider init failed: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> loadLanguage(String languageCode) async {
    try {
      String jsonString = await rootBundle.loadString('assets/lang/$languageCode.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      
      // Flatten, but only keep simple string values (arrays are handled by InstructionFormatter)
      _localizedStrings = _flattenStringsOnly(jsonMap);
      _selectedLanguageCode = languageCode;
      
      await _audioService.setLanguage(languageCode);
      
      if (_prefs != null) {
        await _prefs!.setString('language_code', languageCode);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading language file: $e');
      if (languageCode != 'en') {
        await loadLanguage('en');
      }
    }
  }

  void setVoiceEnabled(bool enabled) {
    _isVoiceEnabled = enabled;
    _prefs?.setBool('voice_enabled', enabled);
    notifyListeners();
  }

  /// Flatten nested JSON, keeping only string values (ignoring arrays).
  Map<String, String> _flattenStringsOnly(Map<String, dynamic> json, [String prefix = '']) {
    final Map<String, String> result = {};
    json.forEach((key, value) {
      final newKey = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map<String, dynamic>) {
        result.addAll(_flattenStringsOnly(value, newKey));
      } else if (value is String) {
        result[newKey] = value;
      }
      // Skip List values — those are handled by InstructionFormatter
    });
    return result;
  }

  /// Translate a simple UI string key.
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  /// Translate with argument substitution for simple UI strings.
  String translateArgs(String key, Map<String, String> args) {
    String text = translate(key);
    args.forEach((argKey, argValue) {
      text = text.replaceAll('{$argKey}', argValue);
    });
    return text;
  }

  /// Transliterate a map/room label key for the current language.
  /// This is the ONLY way to get display text for room labels.
  String transliterateLabel(String labelKey) {
    final lang = _selectedLanguageCode.isEmpty ? 'en' : _selectedLanguageCode;
    return _translitService.transliterate(labelKey, lang);
  }

  void speak(String text) {
    if (_isVoiceEnabled) {
      _audioService.speak(text);
    }
  }
}

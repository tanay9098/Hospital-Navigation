import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> init() async {
    // Default setup
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> setLanguage(String languageCode) async {
    // Mapping our custom short codes to standard TTS language locales
    String ttsLang = 'en-US';
    switch (languageCode) {
      case 'kn': ttsLang = 'kn-IN'; break;
      case 'hi': ttsLang = 'hi-IN'; break;
      case 'ta': ttsLang = 'ta-IN'; break;
      case 'te': ttsLang = 'te-IN'; break;
      default: ttsLang = 'en-US'; break;
    }
    try {
      final dynamic languages = await _flutterTts.getLanguages;
      List<String> availableLanguages = [];
      if (languages is List) {
        availableLanguages = languages.map((e) => e.toString()).toList();
      }

      if (availableLanguages.contains(ttsLang)) {
        await _flutterTts.setLanguage(ttsLang);
      } else if (availableLanguages.contains(ttsLang.split('-')[0])) {
        // Fallback to base language (e.g. 'hi' instead of 'hi-IN')
        await _flutterTts.setLanguage(ttsLang.split('-')[0]);
      } else {
        // Fallback to english
        await _flutterTts.setLanguage('en-US');
      }
    } catch (e) {
      // Ignore if language is not supported on the device
    }
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}

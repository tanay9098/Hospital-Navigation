import 'package:flutter_tts/flutter_tts.dart';

/// Wraps flutter_tts to provide voice navigation playback.
class TtsService {
  final FlutterTts _tts = FlutterTts();

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  /// Call once before first use.
  Future<void> init() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.48);   // slightly slower for clarity
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() => _isPlaying = true);
    _tts.setCompletionHandler(() => _isPlaying = false);
    _tts.setCancelHandler(() => _isPlaying = false);
    _tts.setErrorHandler((_) => _isPlaying = false);
  }

  /// Speak [text] immediately, cancelling anything in progress.
  Future<void> speak(String text) async {
    await stop();
    _isPlaying = true;
    await _tts.speak(text);
  }

  /// Pause current speech.
  Future<void> pause() async {
    await _tts.pause();
    _isPlaying = false;
  }

  /// Stop and clear queue.
  Future<void> stop() async {
    await _tts.stop();
    _isPlaying = false;
  }

  /// Register a callback fired when speech completes.
  void onComplete(void Function() callback) {
    _tts.setCompletionHandler(() {
      _isPlaying = false;
      callback();
    });
  }

  /// Release resources.
  Future<void> dispose() async {
    await _tts.stop();
  }
}

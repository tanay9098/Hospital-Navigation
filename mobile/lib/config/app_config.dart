/// Central configuration for the PES Hospital Navigation app.
/// Update [baseUrl] to point at your backend instance.
class AppConfig {
  AppConfig._();

  // ── API ──────────────────────────────────────────────────────────────
  /// Backend base URL. Override with env / build-flavor as needed.
  static const String baseUrl = 'http://10.0.2.2:5000'; // Android emulator → localhost
  static const String apiPrefix = '/api/v1';
  static const Duration requestTimeout = Duration(seconds: 15);

  // ── Hospital contact ─────────────────────────────────────────────────
  static const String hospitalName = 'PES Hospital Electronic City';
  static const String hospitalAddress =
      'Electronic City Phase 1, Bengaluru – 560 100, Karnataka';
  static const String emergencyNumber = '1800-103-1234';
  static const String ivrNumber = '+91-80-6789-0000';
  static const String receptionNumber = '+91-80-6789-0001';

  // ── IVR keypads ───────────────────────────────────────────────────────
  static const String ivrInstructions =
      'Dial our IVR helpline from any phone.\n'
      'Follow the voice prompts to select your current floor\n'
      'and destination department.\n'
      'The system will guide you step-by-step.';

  // ── Accessibility ─────────────────────────────────────────────────────
  static const String accessibilityPrefKey = 'accessible_only';
  static const String recentLocationsKey = 'recent_locations';
}

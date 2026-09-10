/// Reads secrets from --dart-define, never hardcoded, never logged.
/// Run with: flutter run -d chrome --dart-define=GEMINI_API_KEY=YOUR_KEY
class EnvConfig {
  EnvConfig._();
  static const String geminiApiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;
}

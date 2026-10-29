abstract final class Env {

  static const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl => _apiBaseUrl;

  static bool get isConfigured => _apiBaseUrl.isNotEmpty;

}

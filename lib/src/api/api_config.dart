/// API configuration for different environments
class ApiConfig {
  /// Base URL for development environment
  static const String devBaseUrl = 'https://dev-api.sharemap.live/api';

  /// Base URL for production environment
  static const String prodBaseUrl = 'https://services.sharemap.live/api';

  /// Get the base URL based on the environment
  static String getBaseUrl(Environment environment) {
    switch (environment) {
      case Environment.development:
        return devBaseUrl;
      case Environment.production:
        return prodBaseUrl;
    }
  }
}

/// Environment types
enum Environment {
  /// Development environment
  development,

  /// Production environment
  production,
}
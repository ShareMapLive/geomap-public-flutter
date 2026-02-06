import 'geomap_type.dart';
import '../api/api_config.dart';
import 'font_config.dart';

/// Role of the user viewing the geomap
enum GeoMapRole {
  /// External viewer (e.g., customer, manager) who sees driver status and history
  viewer,

  /// The driver themselves, who only sees the route and stops
  driver,
}

/// Configuration class for the geomap
class GeoMapConfig {
  /// The API key for the map service
  final String apiKey;

  /// The service key for route API requests
  final String? routeServiceKey;

  /// The type of map to use (Google Map or Flutter Map)
  final GeoMapType mapType;

  /// The environment (development or production)
  final Environment environment;

  /// Custom font configuration for the geomap widget
  final FontConfig fontConfig;

  /// The role of the user (affects what data is loaded and displayed)
  final GeoMapRole role;

  /// Optional base URL for development API requests.
  final String? devApiUrl;

  /// Optional base URL for production API requests.
  final String? prodApiUrl;

  /// Creates a new [GeoMapConfig] instance
  ///
  /// [apiKey] is required for accessing map services
  /// [routeServiceKey] is the service key for route API requests
  /// [mapType] determines which map implementation to use
  /// [environment] determines which API environment to use
  /// [role] determines the UI features and data loading (defaults to viewer)
  /// [devApiUrl] allows overriding the default development API base URL
  /// [prodApiUrl] allows overriding the default production API base URL
  const GeoMapConfig({
    required this.apiKey,
    this.routeServiceKey,
    required this.mapType,
    this.environment = Environment.production,
    this.fontConfig = const FontConfig(),
    this.role = GeoMapRole.viewer,
    this.devApiUrl,
    this.prodApiUrl,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeoMapConfig &&
        other.apiKey == apiKey &&
        other.routeServiceKey == routeServiceKey &&
        other.mapType == mapType &&
        other.environment == environment &&
        other.fontConfig == fontConfig &&
        other.role == role &&
        other.devApiUrl == devApiUrl &&
        other.prodApiUrl == prodApiUrl;
  }

  @override
  int get hashCode =>
      apiKey.hashCode ^
      routeServiceKey.hashCode ^
      mapType.hashCode ^
      environment.hashCode ^
      fontConfig.hashCode ^
      role.hashCode ^
      devApiUrl.hashCode ^
      prodApiUrl.hashCode;

  @override
  String toString() =>
      'GeoMapConfig(apiKey: $apiKey, routeServiceKey: $routeServiceKey, mapType: $mapType, fontConfig: $fontConfig, role: $role, devApiUrl: $devApiUrl, prodApiUrl: $prodApiUrl)';
}
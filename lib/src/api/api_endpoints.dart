import 'api_config.dart';

/// API endpoints for the geomap service
class ApiEndpoints {
  /// Base URL for API requests
  final String baseUrl;

  /// Base URL for route service (fixed, not dependent on environment)
  static const String routeServiceUrl = 'https://services.sharemap.live';

  /// Creates an instance of [ApiEndpoints] with the specified environment and optional base URL
  ApiEndpoints(Environment environment, {String? customBaseUrl})
      : baseUrl = (customBaseUrl != null && customBaseUrl.isNotEmpty)
            ? customBaseUrl
            : ApiConfig.getBaseUrl(environment);

  /// Endpoint for getting geomap details
  String get detailMapGeo => '$baseUrl/geo-map/public/detail';

  /// Endpoint for getting tracing list by time range
  String get tracingListByTimeRange =>
      '$baseUrl/geomap-tracing/public/list-by-time-range';

  /// Endpoint for getting public geofencing list
  String get publicGeofencingList => '$baseUrl/geofencing-json/public/list';

  /// Endpoint for getting public geofencing polygon data
  String get publicGeofencingPolygon => '$baseUrl/geofencing/public/polygon';
}

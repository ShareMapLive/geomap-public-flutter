import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/api_response.dart';
import '../models/dataset_model.dart';
import '../models/map_geo_model.dart';
import '../models/list_tracing_model.dart';
import '../models/route_model.dart';
import 'api_endpoints.dart';
import 'api_config.dart';

/// API service for handling geomap related requests
class ApiService extends GetxService {
  /// API endpoints instance
  late ApiEndpoints _endpoints;

  /// API key for authentication
  String? _apiKey;

  /// Route service key for route API requests
  String? _routeServiceKey;

  /// Whether to show logs
  bool _showLogs = false;

  /// Initialize the API service with the specified environment
  Future<ApiService> init({
    Environment environment = Environment.development,
    String? apiKey,
    String? routeServiceKey,
    String? baseUrl,
    bool showLogs = false,
  }) async {
    _apiKey = apiKey;
    _routeServiceKey = routeServiceKey;
    _showLogs = showLogs;
    _endpoints = ApiEndpoints(environment, customBaseUrl: baseUrl);
    return this;
  }

  /// Modify headers to include authentication
  Map<String, String> _modifyHeaders(bool needKey) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      "Device-Timezone": DateTime.now().timeZoneOffset.toString(),
      "Device-Application-Version": "1.0.0",
      "Device-Build-Number": "1",
      "X-Request-ID": DateTime.now().millisecondsSinceEpoch.toString(),
    };

    // Add API key authentication if available
    if (_apiKey != null && _apiKey!.isNotEmpty && needKey) {
      headers['x-public-map-key'] = _apiKey!;
    }

    return headers;
  }

  /// Log response body
  void _logResponseBody(String responseBody, String apiURL) {
    _log('_TAG: Response for API: $apiURL:\n$responseBody');
  }

  /// Internal logger
  void _log(String message) {
    if (_showLogs) {
      debugPrint(message);
    }
  }

  /// Call GET API with authentication
  static Future<ApiResponse?> _callGetAPI({
    required String httpUrl,
    String? param = '',
    bool log = true,
  }) async {
    httpUrl += param != '' ? '$param' : '';
    var url = Uri.parse(httpUrl);

    // Get the service instance to access _modifyHeaders
    final ApiService service = Get.find<ApiService>();
    Map<String, String> headers = service._modifyHeaders(true);

    service._log('_TAG: HttpURL: $httpUrl');
    service._log('_TAG: Headers: $headers');

    final response = await http.get(url, headers: headers);

    if (log) {
      service._logResponseBody(response.body, httpUrl);
    }

    final responseBody = response.body;
    ApiResponse? apiResponse = await compute(_parseInBackground, responseBody);
    return apiResponse;
  }

  /// Call GET API with authentication (for route service)
  static Future<RouteModel?> _callGetRouteAPI({
    required String httpUrl,
    bool log = true,
  }) async {
    var url = Uri.parse(httpUrl);

    // Get the service instance to access _modifyHeaders
    final ApiService service = Get.find<ApiService>();
    Map<String, String> headers = service._modifyHeaders(false);

    // Add the specific sharemap-service-key header for route API if available
    if (service._routeServiceKey != null &&
        service._routeServiceKey!.isNotEmpty) {
      headers['sharemap-service-key'] = service._routeServiceKey!;
    }

    service._log('_TAG: Route HttpURL: $httpUrl');
    service._log('_TAG: Route Headers: $headers');

    final response = await http.get(url, headers: headers);
    service._log('_TAG: Route API Response Status: ${response.statusCode}');

    if (log) {
      service._log('_TAG: Route Response for API: $httpUrl:\n${response.body}');
    }

    try {
      final Map<String, dynamic> jsonMap = json.decode(response.body);
      service._log('_TAG: Parsed route response with keys: ${jsonMap.keys}');
      return RouteModel.fromJson(jsonMap);
    } catch (e) {
      service._log('Error parsing route response: $e');
      return null;
    }
  }

  /// Call POST API with authentication
  static Future<ApiResponse?> _callPostAPI(
      String httpUrl, String jsonBody) async {
    var url = Uri.parse(httpUrl);

    // Get the service instance to access _modifyHeaders
    final ApiService service = Get.find<ApiService>();
    Map<String, String> headers = service._modifyHeaders(true);

    service._log('_TAG: HttpURL: $httpUrl');
    service._log('_TAG: JSON Body: $jsonBody');
    service._log('_TAG: Headers: $headers');

    final response = await http.post(url, headers: headers, body: jsonBody);
    service._logResponseBody(response.body, httpUrl);

    final responseBody = response.body;
    ApiResponse? apiResponse = await compute(_parseInBackground, responseBody);
    return apiResponse;
  }

  /// Parse response in background isolate
  static ApiResponse? _parseInBackground(String responseBody) {
    // Get the service instance to access _log
    final ApiService? service =
        Get.isRegistered<ApiService>() ? Get.find<ApiService>() : null;

    try {
      final Map<String, dynamic> jsonMap = json.decode(responseBody);
      return ApiResponse.fromJson(jsonMap);
    } catch (e) {
      service?._log('Error parsing response: $e');
      return null;
    }
  }

  /// Get the detail of a geomap by its code
  Future<MapGeoModel?> getDetailGeoMap(String geoMapCode) async {
    try {
      final response = await _callGetAPI(
        httpUrl: '${_endpoints.detailMapGeo}/$geoMapCode',
      );

      if (response != null && response.isSuccess()) {
        if (response.data != null) {
          return MapGeoModel.fromJson(response.data);
        }
      } else if (response != null) {
        _log('API Error: ${response.message}, Code: ${response.code}');
      }
      return null;
    } catch (e) {
      _log('Error fetching geomap details: $e');
      return null;
    }
  }

  /// Get dataset detail by code (used to fetch automaticRunTime)
  Future<DatasetModel?> getDatasetDetail(String datasetCode) async {
    try {
      final response = await _callGetAPI(
        httpUrl: '${_endpoints.datasetDetail}/$datasetCode',
      );

      if (response != null && response.isSuccess()) {
        if (response.data != null) {
          return DatasetModel.fromJson(response.data);
        }
      } else if (response != null) {
        _log(
            'API Error getDatasetDetail: ${response.message}, Code: ${response.code}');
      }
      return null;
    } catch (e) {
      _log('Error fetching dataset detail: $e');
      return null;
    }
  }

  /// Get dataset tracking list by time range
  /// [key] is the datasetCode
  /// [objectId] is the userID
  Future<ListTracingModel?> getDatasetTrackingListByTimeRange({
    required String key,
    String? objectId,
    num? startTime,
    num? endTime,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      queryParams['key'] = key;

      if (objectId != null && objectId.isNotEmpty) {
        queryParams['objectId'] = objectId;
      }

      if (startTime != null) {
        queryParams['startTime'] = startTime.toString();
      }

      if (endTime != null) {
        queryParams['endTime'] = endTime.toString();
      }

      if (page != null) {
        queryParams['page'] = page.toString();
      }

      if (limit != null) {
        queryParams['limit'] = limit.toString();
      }

      final queryString = Uri(queryParameters: queryParams).query;
      final url = '${_endpoints.datasetTrackingListByTimeRange}?$queryString';

      final response = await _callGetAPI(httpUrl: url);

      if (response != null && response.isSuccess()) {
        if (response.data != null) {
          final listTracingModel = ListTracingModel.fromJson(response.data);
          return listTracingModel;
        }
      } else if (response != null) {
        _log(
            'API Error getDatasetTrackingListByTimeRange: ${response.message}, Code: ${response.code}');
      }
      return null;
    } catch (e) {
      _log('Error fetching dataset tracking list: $e');
      return null;
    }
  }

  /// Get the list of public geofencing data (points/polygons) by geomap code
  Future<ApiResponse?> getPublicGeofencingList(String geoMapCode) async {
    try {
      final queryParams = <String, dynamic>{};
      queryParams['geo_map_code'] = geoMapCode;

      final queryString = Uri(queryParameters: queryParams).query;
      final url =
          '${_endpoints.publicGeofencingList}?$queryString&sort=ASC&limit=1000"';

      final response = await _callGetAPI(httpUrl: url);

      return response;
    } catch (e) {
      _log('Error fetching public geofencing list: $e');
      return null;
    }
  }

  /// Get route data between two points
  Future<RouteModel?> getRouteBetweenPoints(
      num startLng, num startLat, num endLng, num endLat) async {
    try {
      final url =
          '${ApiEndpoints.routeServiceUrl}/route/v1/driving/$startLng,$startLat;$endLng,$endLat?overview=false&alternatives=false&steps=true';
      _log('Calling route API: $url');
      return await _callGetRouteAPI(httpUrl: url);
    } catch (e) {
      _log('Error fetching route data: $e');
      return null;
    }
  }

  /// Get public geofencing polygon data by UUID (POST request)
  Future<ApiResponse?> getPublicGeofencingPolygon({
    required String uuid,
    List<List<num>>? routeCoordinates,
    int? radius,
    String? unit,
  }) async {
    try {
      // Prepare the request body
      final body = <String, dynamic>{};
      if (routeCoordinates != null) {
        body['routeCoordinates'] = routeCoordinates;
      }
      if (radius != null) {
        body['radius'] = radius;
      }
      if (unit != null) {
        body['unit'] = unit;
      }

      final jsonBody = json.encode(body);
      final response = await _callPostAPI(
          '${_endpoints.publicGeofencingPolygon}/$uuid', jsonBody);

      return response;
    } catch (e) {
      _log('Error fetching public geofencing polygon: $e');
      return null;
    }
  }
}

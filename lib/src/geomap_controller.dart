import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:latlong2/latlong.dart' as latlong;

import 'api/api_config.dart';
import 'api/api_service.dart';
import 'models/dataset_model.dart';
import 'models/geofencing_model.dart';
import 'models/geomap_config.dart';
import 'models/geomap_type.dart';
import 'models/jwt_token_model.dart';
import 'models/list_public_geofencing_model.dart';
import 'models/list_tracing_model.dart';
import 'models/map_geo_model.dart';
import 'models/tracing_model.dart';
import 'utils/flutter_map_marker_utils.dart';
import 'utils/google_map_marker_utils.dart';
import 'utils/map_colors.dart';
import 'utils/mobile_marker_utils.dart';
import 'utils/web_marker_utils.dart';

/// Controller for managing the geomap state and interactions.
///
/// This controller is organized following the UI component order:
/// 1. Status Card - reload functionality, loading state
/// 2. Driver Info Card - driver/user tracing data
/// 3. GeoMap Info Card - geomap details (name, code, type, radius, date)
/// 4. Stop List - geofencing points/polygons
/// 5. Link Card - public geomap URL

class GeoMapController extends GetxController {
  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 1: CONFIGURATION & DEPENDENCIES
  // ════════════════════════════════════════════════════════════════════════════

  /// The package version
  static final RxString _version = '2.0.0'.obs;
  static String get version => _version.value;

  /// Completer for tracking initialization status
  final Completer<void> _initCompleter = Completer<void>();


  /// The configuration for the current geomap
  final GeoMapConfig config;

  /// Gets the clean API key without any query parameters (e.g., removing ?type=driver or &type=driver)
  String get _cleanApiKey => config.apiKey.split('?')[0].split('&')[0];

  /// API service for making requests
  late ApiService _apiService;

  /// Creates a new [GeoMapController] instance
  GeoMapController({
    required this.config,
  });

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 2: UI STATE - Status Card (reload, loading, time display)
  // ════════════════════════════════════════════════════════════════════════════

  /// Whether data is currently being loaded (controls reload button state)
  final RxBool _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  /// Whether the mobile bottom sheet is expanded
  final RxBool isSheetExpanded = false.obs;

  /// Whether the web side panel is expanded
  final RxBool _isSidePanelExpanded = true.obs;

  bool get isSidePanelExpanded => _isSidePanelExpanded.value;

  /// Toggle mobile bottom sheet expanded/collapsed
  void toggleSheet() {
    isSheetExpanded.value = !isSheetExpanded.value;
  }

  void expandSheet() {
    isSheetExpanded.value = true;
  }

  void collapseSheet() {
    isSheetExpanded.value = false;
  }

  /// Toggle web side panel expanded/collapsed
  void toggleSidePanel() {
    _isSidePanelExpanded.value = !_isSidePanelExpanded.value;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 3: DRIVER INFO - Tracing data for driver info card
  // ════════════════════════════════════════════════════════════════════════════

  /// List of tracing records for the current geomap (driver location history)
  final Rx<ListTracingModel?> _driverTracingData = Rx<ListTracingModel?>(null);

  ListTracingModel? get driverTracingData => _driverTracingData.value;

  /// List of driver UUIDs extracted from the API key JWT token
  final RxList<String> _driverUuids = <String>[].obs;

  List<String> get driverUuids => _driverUuids.toList();

  /// Date extracted from the API key JWT token (for filtering tracing data)
  final Rx<int?> _tokenDate = Rx<int?>(null);

  /// Timer for automatic refresh of driver tracing data
  Timer? _driverTracingRefreshTimer;

  /// automaticRunTime fetched from dataset detail API (in minutes)
  int? _datasetAutoRunTime;

  /// Check if driver data is available (token has driver UUIDs)
  bool get hasDriverData => _driverUuids.isNotEmpty;

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 4: GEOMAP INFO - GeoMap details for info card
  // ════════════════════════════════════════════════════════════════════════════

  /// The detail of the current geomap
  final Rx<MapGeoModel?> _geoMapInfo = Rx<MapGeoModel?>(null);

  MapGeoModel? get geoMapInfo => _geoMapInfo.value;

  /// Gets the formatted date from JWT token for display
  String get displayDate {
    if (_tokenDate.value != null) {
      final date = DateTime.fromMillisecondsSinceEpoch(_tokenDate.value!);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
    return '-';
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 5: STOP LIST - Geofencing points/polygons for stop list
  // ════════════════════════════════════════════════════════════════════════════

  /// List of geofencing data (points/polygons) - the "stops" in the route
  final RxList<PublicGeofencingModel> _stopList = <PublicGeofencingModel>[].obs;

  List<PublicGeofencingModel> get stopList => _stopList;

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 6: LINK CARD - Public geomap URL
  // ════════════════════════════════════════════════════════════════════════════

  /// Gets the public geomap URL based on environment and config
  String getPublicGeoMapUrl(String geoMapCode) {
    final isDev = config.environment == Environment.development;
    final baseUrl = isDev
        ? 'https://dev-business.sharemap.live'
        : 'https://business.sharemap.live';
    final token = _cleanApiKey;

    String url = '$baseUrl/public-geomap/$geoMapCode?token=$token';
    if (config.role == GeoMapRole.driver) {
      url += '&type=driver';
    }
    return url;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 7: MAP STATE - Core map properties
  // ════════════════════════════════════════════════════════════════════════════

  /// The current zoom level of the map
  final RxDouble _zoom = 13.0.obs;

  double get zoom => _zoom.value;

  /// The current center position of the map
  final Rx<latlong.LatLng> _center =
      const latlong.LatLng(10.762622, 106.660172).obs;

  latlong.LatLng get center => _center.value;

  /// Whether the map is ready to be interacted with
  final RxBool _isMapReady = false.obs;

  bool get isMapReady => _isMapReady.value;

  set isMapReady(bool value) => _isMapReady.value = value;

  /// Google Map controller (web/mobile) to control camera programmatically
  google_maps.GoogleMapController? googleMapController;

  /// List of route coordinates (LatLng pairs) for drawing routes
  final RxList<List<latlong.LatLng>> _routeCoordinates =
      <List<latlong.LatLng>>[].obs;

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 8: MAP MARKERS - Google Maps
  // ════════════════════════════════════════════════════════════════════════════

  /// Driver location markers (Google Maps)
  final RxList<google_maps.Marker> _googleDriverMarkers =
      <google_maps.Marker>[].obs;

  List<google_maps.Marker> get googleDriverMarkers => _googleDriverMarkers;

  /// Stop/geofencing center markers (Google Maps)
  final RxList<google_maps.Marker> _googleStopMarkers =
      <google_maps.Marker>[].obs;

  List<google_maps.Marker> get googleStopMarkers => _googleStopMarkers;

  /// Check-in markers (Google Maps)
  final RxList<google_maps.Marker> _googleCheckInMarkers =
      <google_maps.Marker>[].obs;

  List<google_maps.Marker> get googleCheckInMarkers => _googleCheckInMarkers;

  /// Check-in info popup markers (Google Maps)
  final RxList<google_maps.Marker> _googleCheckInInfoMarkers =
      <google_maps.Marker>[].obs;

  List<google_maps.Marker> get googleCheckInInfoMarkers =>
      _googleCheckInInfoMarkers;

  /// Geofencing circles (Google Maps)
  final RxList<google_maps.Circle> _googleCircles = <google_maps.Circle>[].obs;

  List<google_maps.Circle> get googleCircles => _googleCircles;

  /// Geofencing polygons (Google Maps)
  final RxList<google_maps.Polygon> _googlePolygons =
      <google_maps.Polygon>[].obs;

  List<google_maps.Polygon> get googlePolygons => _googlePolygons;

  /// Route polylines between stops (Google Maps)
  final RxList<google_maps.Polyline> _googleRoutePolylines =
      <google_maps.Polyline>[].obs;

  List<google_maps.Polyline> get googleRoutePolylines => _googleRoutePolylines;

  /// Driver tracing polylines - shows driver's traveled path (Google Maps)
  final RxList<google_maps.Polyline> _googleDriverPathPolylines =
      <google_maps.Polyline>[].obs;

  List<google_maps.Polyline> get googleDriverPathPolylines =>
      _googleDriverPathPolylines;

  /// Current location marker (Google Maps - specific for Web)
  final Rx<google_maps.Marker?> _googleCurrentLocationMarker =
      Rx<google_maps.Marker?>(null);

  google_maps.Marker? get googleCurrentLocationMarker =>
      _googleCurrentLocationMarker.value;

  /// Last known user position (cached from location stream)
  Position? _lastKnownPosition;

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 9: MAP MARKERS - Flutter Map
  // ════════════════════════════════════════════════════════════════════════════

  /// Driver location markers (Flutter Map)
  final RxList<flutter_map.Marker> _flutterDriverMarkers =
      <flutter_map.Marker>[].obs;

  List<flutter_map.Marker> get flutterDriverMarkers => _flutterDriverMarkers;

  /// Stop/geofencing center markers (Flutter Map)
  final RxList<flutter_map.Marker> _flutterStopMarkers =
      <flutter_map.Marker>[].obs;

  List<flutter_map.Marker> get flutterStopMarkers => _flutterStopMarkers;

  /// Check-in markers (Flutter Map)
  final RxList<flutter_map.Marker> _flutterCheckInMarkers =
      <flutter_map.Marker>[].obs;

  List<flutter_map.Marker> get flutterCheckInMarkers => _flutterCheckInMarkers;

  /// Check-in info popup markers (Flutter Map)
  final RxList<flutter_map.Marker> _flutterCheckInInfoMarkers =
      <flutter_map.Marker>[].obs;

  List<flutter_map.Marker> get flutterCheckInInfoMarkers =>
      _flutterCheckInInfoMarkers;

  /// Geofencing circles (Flutter Map)
  final RxList<flutter_map.CircleMarker> _flutterCircles =
      <flutter_map.CircleMarker>[].obs;

  List<flutter_map.CircleMarker> get flutterCircles => _flutterCircles;

  /// Geofencing polygons (Flutter Map)
  final RxList<flutter_map.Polygon> _flutterPolygons =
      <flutter_map.Polygon>[].obs;

  List<flutter_map.Polygon> get flutterPolygons => _flutterPolygons;

  /// Route polylines between stops (Flutter Map)
  final RxList<flutter_map.Polyline> _flutterRoutePolylines =
      <flutter_map.Polyline>[].obs;

  List<flutter_map.Polyline> get flutterRoutePolylines =>
      _flutterRoutePolylines;

  /// Driver tracing polylines - shows driver's traveled path (Flutter Map)
  final RxList<flutter_map.Polyline> _flutterDriverPathPolylines =
      <flutter_map.Polyline>[].obs;

  List<flutter_map.Polyline> get flutterDriverPathPolylines =>
      _flutterDriverPathPolylines;

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 10: BACKWARD COMPATIBILITY GETTERS
  // These maintain compatibility with existing code that uses old property names
  // ════════════════════════════════════════════════════════════════════════════

  // Status Card compatibility
  bool get isLoadingData => _isLoading.value;

  // Driver Info Card compatibility
  ListTracingModel? get tracingList => _driverTracingData.value;

  List<String> get userUuids => _driverUuids.toList();

  String get jwtDateFormatted => displayDate;

  // GeoMap Info Card compatibility
  MapGeoModel? get mapGeoDetail => _geoMapInfo.value;

  // Stop List compatibility
  List<PublicGeofencingModel> get publicGeofencingList => _stopList;

  // Google Maps markers compatibility
  List<google_maps.Marker> get googleMapsUserMarkers => _googleDriverMarkers;

  List<google_maps.Marker> get googleMapsGeofencingCenterMarkers =>
      _googleStopMarkers;

  List<google_maps.Marker> get googleMapsUserCheckInMarkers =>
      _googleCheckInMarkers;

  List<google_maps.Marker> get googleMapsInfoUserCheckInMarkers =>
      _googleCheckInInfoMarkers;

  List<google_maps.Circle> get googleMapsCircles => _googleCircles;

  List<google_maps.Polygon> get googleMapsPolygons => _googlePolygons;

  List<google_maps.Polyline> get googleMapsPolylines => _googleRoutePolylines;

  List<google_maps.Polyline> get googleMapsTracingPolylines =>
      _googleDriverPathPolylines;

  // Flutter Map markers compatibility
  List<flutter_map.Marker> get flutterMapUserMarkers => _flutterDriverMarkers;

  List<flutter_map.Marker> get flutterMapGeofencingCenterMarkers =>
      _flutterStopMarkers;

  List<flutter_map.Marker> get flutterMapUserCheckInMarkers =>
      _flutterCheckInMarkers;

  List<flutter_map.Marker> get flutterMapInfoUserCheckInMarkers =>
      _flutterCheckInInfoMarkers;

  List<flutter_map.CircleMarker> get flutterMapCircles => _flutterCircles;

  List<flutter_map.Polygon> get flutterMapPolygons => _flutterPolygons;

  List<flutter_map.Polyline> get flutterMapPolylines => _flutterRoutePolylines;

  List<flutter_map.Polyline> get flutterMapTracingPolylines =>
      _flutterDriverPathPolylines;

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 11: LIFECYCLE METHODS
  // ════════════════════════════════════════════════════════════════════════════

  bool _isInitializing = false;

  /// Initialize the controller with the API service
  Future<void> init() async {
    if (_initCompleter.isCompleted) return;
    if (_isInitializing) return _initCompleter.future;

    _isInitializing = true;
    try {
      if (!Get.isRegistered<GeoMapController>()) {
        Get.put(this);
      }

      final String? customBaseUrl =
          config.environment == Environment.development
              ? config.devApiUrl
              : config.prodApiUrl;

      _apiService = await Get.putAsync(() => ApiService().init(
            environment: config.environment,
            apiKey: _cleanApiKey,
            routeServiceKey: config.routeServiceKey,
            baseUrl: customBaseUrl,
          ));
    } catch (e) {
      print('Error initializing GeoMapController: $e');
    } finally {
      _isInitializing = false;
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    }
  }


  @override
  void onInit() {
    // TODO: implement onInit
    init();
    super.onInit();
  }

  @override
  void onClose() {
    _driverTracingRefreshTimer?.cancel();
    _positionStreamSubscription?.cancel();
    _simulationTimer?.cancel();
    super.onClose();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 12: DATA LOADING - Main data loading sequence
  // ════════════════════════════════════════════════════════════════════════════

  /// Track the last loaded code to prevent redundant API calls
  String? _lastLoadedCode;

  /// Load all data in the correct sequence
  Future<void> getAllData(String geoMapCode, {bool force = false}) async {
    // Nếu đang load thì bỏ qua
    if (_isLoading.value) return;

    _isLoading.value = true;
    try {
      // Đảm bảo controller được khởi tạo
      await init();

      // Nếu không ép buộc và đã load code này rồi thì bỏ qua
      if (!force && _lastLoadedCode == geoMapCode) return;

      _lastLoadedCode = geoMapCode;
      print('getAllData: Starting data load sequence for $geoMapCode');
      // Step 1: Parse JWT token
      _parseJwtToken(_cleanApiKey);

      // Step 2: Load GeoMap info
      await _loadGeoMapInfo(geoMapCode);

      // Step 2.5: Load dataset detail to get automaticRunTime (if datasetCode available)
      // Only needed for viewer role to refresh tracing data
      if (config.role != GeoMapRole.driver) {
        await _loadDatasetDetail();
      }

      // Step 3: Load driver tracing data (only if not in driver mode)
      if (config.role != GeoMapRole.driver) {
        await _loadDriverTracingData(geoMapCode);
      }

      // Step 4: Load stop list
      await _loadStopList(geoMapCode);

      // Step 5: Load routes, polygons, and check-in points in parallel
      await _loadRoutesBetweenStops();
      await _loadPolygonsIfNeeded();

      if (config.role != GeoMapRole.driver) {
        _loadCheckInMarkers();
      }

      // Step 6: Start automatic refresh timer
      if (config.role != GeoMapRole.driver) {
        _startDriverTracingRefreshTimer(geoMapCode);
      }

    } finally {
      _isLoading.value = false;
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 13: GEOMAP INFO LOADING
  // ════════════════════════════════════════════════════════════════════════════

  /// Load the detail of the geomap (for GeoMap Info Card)
  Future<void> _loadGeoMapInfo(String geoMapCode) async {
    if (geoMapCode.isEmpty) return;

    final detail = await _apiService.getDetailGeoMap(geoMapCode);

    // If role is driver, filter userJoinGeoMap to only include themselves
    if (detail != null && config.role == GeoMapRole.driver) {
      if (detail.userJoinGeoMap != null) {
        detail.userJoinGeoMap = detail.userJoinGeoMap!
            .where((user) => _driverUuids.contains(user.userId))
            .toList();
      }
    }

    _geoMapInfo.value = detail;

    if (detail != null) {
      print('Loaded GeoMap info: ${detail.name}');
    }
  }

  /// Load dataset detail using the datasetCode from geoMapInfo
  /// This fetches the automaticRunTime for the tracing refresh timer
  Future<void> _loadDatasetDetail() async {
    final datasetCode = _geoMapInfo.value?.datasetCode;
    if (datasetCode == null || datasetCode.isEmpty) {
      print('loadDatasetDetail: No datasetCode available');
      _datasetAutoRunTime = null;
      return;
    }

    print('Loading dataset detail for code: $datasetCode');
    final dataset = await _apiService.getDatasetDetail(datasetCode);

    if (dataset != null) {
      _datasetAutoRunTime = dataset.automaticRunTime?.toInt();
      print('Loaded dataset detail. automaticRunTime: $_datasetAutoRunTime');
    } else {
      _datasetAutoRunTime = null;
      print('Failed to load dataset detail or it returned null');
    }
  }



  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 14: JWT TOKEN PARSING
  // ════════════════════════════════════════════════════════════════════════════

  /// Parse JWT token to extract driver UUIDs and date
  List<String> _parseJwtToken(String jwtToken) {
    try {
      if (JwtDecoder.isExpired(jwtToken)) {
        print('JWT token is expired');
        return [];
      }

      final payload = JwtDecoder.decode(jwtToken);
      print('JWT Payload: $payload');

      final jwtModel = JwtTokenModel.fromJson(payload);
      print(
          'Parsed JWT - listUuid: ${jwtModel.listUuid}, date: ${jwtModel.date}');

      // Extract driver UUIDs
      if (jwtModel.listUuid != null) {
        _driverUuids.assignAll(jwtModel.listUuid!);
      }

      // Extract date
      _tokenDate.value = jwtModel.date;

      print('Extracted driver UUIDs: $_driverUuids');
      print('Extracted date: ${_tokenDate.value}');
      return _driverUuids.toList();
    } catch (e, stackTrace) {
      print('Error parsing JWT token: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Get start time (beginning of the day) from JWT date
  int _getStartTimeFromTokenDate() {
    if (_tokenDate.value != null) {
      final date = DateTime.fromMillisecondsSinceEpoch(_tokenDate.value!);
      final startOfDay = DateTime(date.year, date.month, date.day);
      return startOfDay.millisecondsSinceEpoch;
    }
    // Fallback to 24 hours ago
    return DateTime.now().millisecondsSinceEpoch - 86400000;
  }

  /// Get end time (end of the day) from JWT date
  int _getEndTimeFromTokenDate() {
    if (_tokenDate.value != null) {
      final date = DateTime.fromMillisecondsSinceEpoch(_tokenDate.value!);
      final endOfDay =
          DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
      return endOfDay.millisecondsSinceEpoch;
    }
    // Fallback to current time
    return DateTime.now().millisecondsSinceEpoch;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 15: DRIVER TRACING DATA LOADING (for Driver Info Card)
  // ════════════════════════════════════════════════════════════════════════════

  /// Load driver tracing data with user UUIDs
  Future<void> _loadDriverTracingData(String geoMapCode) async {
    if (_driverUuids.isEmpty) {
      print('No driver UUIDs, skipping driver tracing data load');
      return;
    }

    final startTime = _getStartTimeFromTokenDate();
    final endTime = _getEndTimeFromTokenDate();

    // Get datasetCode from the loaded geomap info
    final datasetCode = _geoMapInfo.value?.datasetCode;

    if (datasetCode == null || datasetCode.isEmpty) {
      // datasetCode chưa có -> chỉ hiển thị points, không load tracing, không crash
      print('datasetCode is null, skipping dataset tracking load');
      return;
    }

    print('Loading dataset tracking data for datasetCode: $datasetCode, uuid: ${_driverUuids[0]}');

    await _loadDatasetTrackingByTimeRange(
      datasetCode: datasetCode,
      objectId: _driverUuids[0],
      startTime: startTime,
      endTime: endTime,
    );

    // Create driver markers from tracing data
    await _createDriverMarkersFromTracingData();
  }

  /// Load dataset tracking records by time range (new API)
  Future<void> _loadDatasetTrackingByTimeRange({
    required String datasetCode,
    String? objectId,
    num? startTime,
    num? endTime,
    int? page,
    int? limit,
  }) async {
    if (datasetCode.isEmpty) return;

    final listTracingModel = await _apiService.getDatasetTrackingListByTimeRange(
      key: datasetCode,
      objectId: objectId,
      startTime: startTime,
      endTime: endTime,
      page: page,
      limit: limit,
    );

    if (listTracingModel != null && listTracingModel.geoMapTracing != null) {
      _driverTracingData.value = listTracingModel;

      // Update geomap info if included in response
      if (listTracingModel.geoMap != null) {
        _geoMapInfo.value = listTracingModel.geoMap;
      }
    }
  }

  /// Start automatic refresh timer for driver tracing data
  void _startDriverTracingRefreshTimer(String geoMapCode) {
    if (_driverUuids.isEmpty) {
      print('No driver UUIDs, skipping refresh timer');
      return;
    }

    final datasetCode = _geoMapInfo.value?.datasetCode;
    if (datasetCode == null || datasetCode.isEmpty) {
      // Nếu không có datasetCode thì không cần refresh timer
      print('No datasetCode, skipping refresh timer');
      return;
    }

    _driverTracingRefreshTimer?.cancel();

    // Ưu tiên dùng automaticRunTime từ dataset detail, fallback về 1 phút
    final autoRunTime = _datasetAutoRunTime ?? 1;
    print('Starting driver tracing refresh timer: $autoRunTime minutes (datasetCode: $datasetCode)');

    _driverTracingRefreshTimer = Timer.periodic(
      Duration(minutes: autoRunTime),
      (timer) async {
        print('Auto-refreshing driver tracing data');
        await _loadDriverTracingData(geoMapCode);
        await _loadCheckInMarkers();
      },
    );
  }

  /// Create driver markers from tracing data
  Future<void> _createDriverMarkersFromTracingData() async {
    _googleDriverMarkers.clear();
    _flutterDriverMarkers.clear();

    final List<List<latlong.LatLng>> routeCoordinates = [];
    final tracingList = _driverTracingData.value?.geoMapTracing;

    if (tracingList != null && tracingList.isNotEmpty) {
      print('Creating driver markers from ${tracingList.length} tracing items');

      // Create marker for the first (latest) item
      final tracing = tracingList[0];
      double? lat;
      double? lng;

      if (tracing.object?.coordinates != null &&
          tracing.object!.coordinates!.length >= 2) {
        lng = tracing.object!.coordinates![0].toDouble();
        lat = tracing.object!.coordinates![1].toDouble();
      }

      if (lat != null && lng != null) {
        String? avatarLink;
        if (tracing.extraData?.avatar != null) {
          avatarLink = tracing.extraData!.avatar;
        }

        final user = UserJoinGeoMap(
          name: tracing.name,
          userId: tracing.uuid,
          linkAvatar: avatarLink,
          lat: lat,
          lng: lng,
          time: _formatTracingTime(tracing.time),
        );

        if (config.mapType == GeoMapType.googleMap) {
          _createGoogleDriverMarker(user);
        } else {
          final marker = kIsWeb
              ? WebMarkerUtils.buildUserGeoMapMarkerForFlutterMap(user,
                  _geoMapInfo.value?.trackingVehicleConfiguration, (user) {})
              : MobileMarkerUtils.buildUserGeoMapMarkerForFlutterMap(user,
                  _geoMapInfo.value?.trackingVehicleConfiguration, (user) {});
          _flutterDriverMarkers.add(marker);
        }
      }

      // Draw driver's traveled path
      if (tracingList.length > 1) {
        final List<latlong.LatLng> driverPath = [];

        for (final tracing in tracingList) {
          if (tracing.object?.coordinates != null &&
              tracing.object!.coordinates!.length >= 2) {
            final lng = tracing.object!.coordinates![0].toDouble();
            final lat = tracing.object!.coordinates![1].toDouble();
            driverPath.add(latlong.LatLng(lat, lng));
          }
        }

        if (driverPath.length > 1) {
          print('Created driver path with ${driverPath.length} points. Adding to routeCoordinates.');
          routeCoordinates.add(driverPath);
          _processDriverPathPolylines(routeCoordinates);
        } else {
          print('Driver path only has ${driverPath.length} points, not enough to draw a line.');
        }
      }
    } else {
      print('No tracing data, clearing driver path polylines');
      _googleDriverPathPolylines.clear();
      _flutterDriverPathPolylines.clear();

      // Fallback: use userJoinGeoMap from geomap info
      final usersToDisplay = (_geoMapInfo.value?.userJoinGeoMap ?? [])
          .where((user) => _driverUuids.contains(user.userId))
          .toList();

      print('Fallback to userJoinGeoMap: ${usersToDisplay.length} users');

      for (final user in usersToDisplay) {
        if (user.lat != null && user.lng != null) {
          if (config.mapType == GeoMapType.googleMap) {
            _createGoogleDriverMarker(user);
          } else {
            final marker = kIsWeb
                ? WebMarkerUtils.buildUserGeoMapMarkerForFlutterMap(user,
                    _geoMapInfo.value?.trackingVehicleConfiguration, (user) {})
                : MobileMarkerUtils.buildUserGeoMapMarkerForFlutterMap(user,
                    _geoMapInfo.value?.trackingVehicleConfiguration, (user) {});
            _flutterDriverMarkers.add(marker);
          }
        }
      }
    }
  }

  /// Create Google Maps driver marker
  void _createGoogleDriverMarker(UserJoinGeoMap user) async {
    try {
      final marker = kIsWeb
          ? await WebMarkerUtils.buildUserGeoMapMarker(
              user, _geoMapInfo.value?.trackingVehicleConfiguration, (user) {})
          : await MobileMarkerUtils.buildUserGeoMapMarker(
              user, _geoMapInfo.value?.trackingVehicleConfiguration, (user) {});
      _googleDriverMarkers.add(marker);
      print('Created Google driver marker at ${marker.position}');
    } catch (e) {
      print('Error creating Google driver marker: $e');
    }
  }

  /// Process driver path polylines (green color for traveled path)
  void _processDriverPathPolylines(
      List<List<latlong.LatLng>> routeCoordinates) {
    print('Processing ${routeCoordinates.length} driver path polylines');
    final Color pathColor = Colors.green;

    if (routeCoordinates.isEmpty) {
      _googleDriverPathPolylines.clear();
      _flutterDriverPathPolylines.clear();
      return;
    }

    if (config.mapType == GeoMapType.googleMap) {
      final polylines = <google_maps.Polyline>[];
      for (int i = 0; i < routeCoordinates.length; i++) {
        polylines.add(
          GoogleMapMarkerUtils.buildRouteTracingPolyline(
              routeCoordinates[i], pathColor, i),
        );
      }
      _googleDriverPathPolylines.assignAll(polylines);
    } else {
      final polylines = <flutter_map.Polyline>[];
      for (int i = 0; i < routeCoordinates.length; i++) {
        polylines.add(
          FlutterMapMarkerUtils.buildRouteTracingPolyline(
              routeCoordinates[i], pathColor, i),
        );
      }
      _flutterDriverPathPolylines.assignAll(polylines);
    }
  }

  /// Format tracing time to ISO format
  String? _formatTracingTime(String? time) {
    if (time == null || time.isEmpty) return time;

    if (time.contains('T') && time.contains('Z')) {
      return time;
    }

    try {
      final milliseconds = int.parse(time);
      final dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
      return dateTime.toIso8601String();
    } catch (e) {
      return time;
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 16: STOP LIST LOADING (for Stop List Card)
  // ════════════════════════════════════════════════════════════════════════════

  /// Load stop list (geofencing points/polygons)
  Future<void> _loadStopList(String geoMapCode) async {
    if (geoMapCode.isEmpty) return;

    final response = await _apiService.getPublicGeofencingList(geoMapCode);

    if (response != null && response.isSuccess() && response.data != null) {
      try {
        final listResponse = ListPublicGeofencingModel.fromJson(response.data);

        if (listResponse.list != null) {
          _stopList.assignAll(listResponse.list!);
          _processStopListMarkers(listResponse.list!);
        }
      } catch (e) {
        print('Error parsing stop list: $e');
      }
    } else if (response != null) {
      print('API Error loading stop list: ${response.message}');
    }
  }

  /// Process stop list to create markers and circles
  void _processStopListMarkers(List<PublicGeofencingModel> stops) {
    // Clear existing markers
    _googleStopMarkers.clear();
    _googleCircles.clear();
    _flutterStopMarkers.clear();
    _googleCheckInMarkers.clear();
    _flutterCheckInMarkers.clear();
    _googleCheckInInfoMarkers.clear();
    _flutterCheckInInfoMarkers.clear();
    _flutterCircles.clear();
    _googlePolygons.clear();
    _flutterPolygons.clear();
    _googleRoutePolylines.clear();
    _flutterRoutePolylines.clear();

    final mapType = _geoMapInfo.value?.type?.toLowerCase();

    if (mapType == 'point') {
      // Point type: each item is a marker with optional circle
      for (int i = 0; i < stops.length; i++) {
        var item = stops[i];
        if (item.lat != null && item.lng != null) {
          _createStopMarker(item, i);
          if (item.radius != null && item.radius! > 0) {
            _createGeofencingCircle(item, i);
          }
        }
      }
    } else if (mapType == 'polygon') {
      // Polygon type: single item with data containing point markers
      if (stops.isNotEmpty) {
        final polygonItem = stops[0];
        _createPolygon(polygonItem);

        if (polygonItem.data != null) {
          for (int i = 0; i < polygonItem.data!.length; i++) {
            final pointData = polygonItem.data![i];
            if (pointData.point != null && pointData.point!.length >= 2) {
              final pointMarker = PublicGeofencingModel(
                lat: pointData.point![1],
                lng: pointData.point![0],
                radius: polygonItem.radius,
                name: pointData.title,
              );
              _createStopMarker(pointMarker, i);
            }
          }
        }
      }
    } else {
      // Default processing
      for (int i = 0; i < stops.length; i++) {
        var item = stops[i];
        if (item.lat != null && item.lng != null) {
          _createStopMarker(item, i);
          if (item.radius != null && item.radius! > 0) {
            _createGeofencingCircle(item, i);
          }
        }
      }
    }
  }

  /// Create stop marker
  void _createStopMarker(PublicGeofencingModel item, int index) {
    final color = MapColors.geofencingCenterMarker;

    if (config.mapType == GeoMapType.googleMap) {
      _createGoogleStopMarker(item, index, color);
    } else {
      final marker = kIsWeb
          ? WebMarkerUtils.buildGeofencingCenterMarkerForFlutterMap(
              item, index, color, (item) {})
          : MobileMarkerUtils.buildGeofencingCenterMarkerForFlutterMap(
              item, index, color, (item) {});
      _flutterStopMarkers.add(marker);
    }
  }

  /// Create Google Maps stop marker
  void _createGoogleStopMarker(
      PublicGeofencingModel item, int index, Color color) async {
    try {
      final marker = kIsWeb
          ? await WebMarkerUtils.buildGeofencingCenterMarker(
              item, index, (item) {})
          : await MobileMarkerUtils.buildGeofencingCenterMarker(
              item, index, color, (item) {});
      _googleStopMarkers.add(marker);
    } catch (e) {
      print('Error creating Google stop marker: $e');
    }
  }

  /// Create geofencing circle
  void _createGeofencingCircle(PublicGeofencingModel item, int index) {
    final color = MapColors.geofencingCircle;

    if (config.mapType == GeoMapType.googleMap) {
      final circle = kIsWeb
          ? WebMarkerUtils.buildGeofencingCircle(item, color)
          : MobileMarkerUtils.buildGeofencingCircle(item, color);
      _googleCircles.add(circle);
    } else {
      final circleMarker = kIsWeb
          ? WebMarkerUtils.buildGeofencingCircleMarker(item, color)
          : MobileMarkerUtils.buildGeofencingCircleMarker(item, color);
      _flutterCircles.add(circleMarker);
    }
  }

  /// Create geofencing polygon
  void _createPolygon(PublicGeofencingModel item) {
    if (config.mapType == GeoMapType.googleMap) {
      _googlePolygons.add(GoogleMapMarkerUtils.buildGeofencingPolygon(item));
    } else {
      _flutterPolygons.add(FlutterMapMarkerUtils.buildGeofencingPolygon(item));
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 17: ROUTE LOADING (routes between stops)
  // ════════════════════════════════════════════════════════════════════════════

  /// Load routes between consecutive stops
  Future<void> _loadRoutesBetweenStops() async {
    print('Loading routes between stops. Stop count: ${_stopList.length}');
    if (_stopList.isEmpty) return;

    final List<Future<List<latlong.LatLng>?>> routeFutures = [];
    final mapType = _geoMapInfo.value?.type?.toLowerCase();

    if (mapType == 'polygon') {
      // Polygon type: use data field
      if (_stopList.isNotEmpty) {
        final polygonItem = _stopList[0];
        if (polygonItem.data != null && polygonItem.data!.length > 1) {
          for (int i = 0; i < polygonItem.data!.length - 1; i++) {
            final currentPoint = polygonItem.data![i];
            final nextPoint = polygonItem.data![i + 1];

            if (currentPoint.point != null &&
                currentPoint.point!.length >= 2 &&
                nextPoint.point != null &&
                nextPoint.point!.length >= 2) {
              routeFutures.add(_fetchRouteCoordinates(
                currentPoint.point![0],
                currentPoint.point![1],
                nextPoint.point![0],
                nextPoint.point![1],
              ));
            }
          }
        }
      }
    } else {
      // Point type
      for (int i = 0; i < _stopList.length - 1; i++) {
        final currentPoint = _stopList[i];
        final nextPoint = _stopList[i + 1];

        if (currentPoint.lat != null &&
            currentPoint.lng != null &&
            nextPoint.lat != null &&
            nextPoint.lng != null) {
          routeFutures.add(_fetchRouteCoordinates(
            currentPoint.lng!,
            currentPoint.lat!,
            nextPoint.lng!,
            nextPoint.lat!,
          ));
        }
      }
    }

    if (routeFutures.isNotEmpty) {
      final routes = await Future.wait(routeFutures);
      final validRoutes = routes
          .where((route) => route != null)
          .cast<List<latlong.LatLng>>()
          .toList();
      _routeCoordinates.assignAll(validRoutes);
      _processRoutePolylines(validRoutes);
    }
  }

  /// Fetch route coordinates between two points
  Future<List<latlong.LatLng>?> _fetchRouteCoordinates(
      num startLng, num startLat, num endLng, num endLat) async {
    try {
      final routeModel = await _apiService.getRouteBetweenPoints(
          startLng, startLat, endLng, endLat);

      if (routeModel?.routes != null && routeModel!.routes!.isNotEmpty) {
        final coordinates = <latlong.LatLng>[];

        for (var route in routeModel.routes!) {
          if (route.legs != null) {
            for (var leg in route.legs!) {
              if (leg.steps != null) {
                for (var step in leg.steps!) {
                  if (step.intersections != null) {
                    for (var intersection in step.intersections!) {
                      if (intersection.location != null &&
                          intersection.location!.length >= 2) {
                        final lng = intersection.location![0].toDouble();
                        final lat = intersection.location![1].toDouble();
                        coordinates.add(latlong.LatLng(lat, lng));
                      }
                    }
                  }
                }
              }
            }
          }
        }
        return coordinates;
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
    return null;
  }

  /// Process route polylines (gray color for planned route)
  void _processRoutePolylines(List<List<latlong.LatLng>> routeCoordinates) {
    if (config.mapType == GeoMapType.googleMap) {
      final polylines = <google_maps.Polyline>{};
      for (int i = 0; i < routeCoordinates.length; i++) {
        polylines.add(
          GoogleMapMarkerUtils.buildRoutePolyline(
              routeCoordinates[i], MapColors.route, i),
        );
      }
      _googleRoutePolylines.assignAll(polylines);
    } else {
      final polylines = <flutter_map.Polyline>[];
      for (int i = 0; i < routeCoordinates.length; i++) {
        polylines.add(
          FlutterMapMarkerUtils.buildRoutePolyline(
              routeCoordinates[i], MapColors.route, i),
        );
      }
      _flutterRoutePolylines.assignAll(polylines);
    }
  }

  /// Load polygons if type is polygon
  Future<void> _loadPolygonsIfNeeded() async {
    final mapDetail = _geoMapInfo.value;
    if (mapDetail == null) return;

    if (mapDetail.type?.toLowerCase() == 'polygon') {
      for (var item in _stopList) {
        _createPolygon(item);
      }
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 18: CHECK-IN MARKERS
  // ════════════════════════════════════════════════════════════════════════════

  /// Load check-in points and create markers
  Future<void> _loadCheckInMarkers() async {
    print('Loading check-in markers: ${_stopList.length} items');

    _googleCheckInMarkers.clear();
    _flutterCheckInMarkers.clear();
    _googleCheckInInfoMarkers.clear();
    _flutterCheckInInfoMarkers.clear();

    if (_stopList.isEmpty) return;

    final mapDetail = _geoMapInfo.value;
    if (mapDetail == null) return;

    // Helper to check if a check-in belongs to the current driver(s)
    bool shouldShowCheckIn(UserCheckIn? checkIn) {
      if (checkIn == null) return false;
      if (config.role != GeoMapRole.driver) return true;
      return _driverUuids.contains(checkIn.userJoinGeoMapUuid);
    }

    if (mapDetail.type?.toLowerCase() == 'polygon') {
      // Polygon case: userCheckIn is in PointData
      for (var item in _stopList) {
        if (item.data != null) {
          for (var pointData in item.data!) {
            if (shouldShowCheckIn(pointData.userCheckIn)) {
              await _createCheckInMarker(pointData.userCheckIn!);
            }
          }
        }
      }
    } else {
      // Point case: userCheckIn is at top level
      for (var item in _stopList) {
        if (shouldShowCheckIn(item.userCheckIn)) {
          await _createCheckInMarker(item.userCheckIn!);
        }
      }
    }
  }

  /// Backward compatibility alias
  Future<void> loadCheckInPoint() => _loadCheckInMarkers();

  /// Create check-in marker
  Future<void> _createCheckInMarker(UserCheckIn checkIn) async {
    if (config.mapType == GeoMapType.googleMap) {
      try {
        final marker = kIsWeb
            ? await WebMarkerUtils.buildUserCheckInMarker(
                checkIn, (checkIn) => _handleCheckInMarkerClick(checkIn))
            : await MobileMarkerUtils.buildUserCheckInMarker(
                checkIn, (checkIn) => _handleCheckInMarkerClick(checkIn));
        _googleCheckInMarkers.add(marker);
      } catch (e) {
        print('Error creating Google check-in marker: $e');
      }
    } else {
      try {
        final marker = kIsWeb
            ? WebMarkerUtils.buildUserCheckInMarkerForFlutterMap(
                checkIn, (checkIn) => _handleCheckInMarkerClick(checkIn))
            : MobileMarkerUtils.buildUserCheckInMarkerForFlutterMap(
                checkIn, (checkIn) => _handleCheckInMarkerClick(checkIn));
        _flutterCheckInMarkers.add(marker);
      } catch (e) {
        print('Error creating Flutter check-in marker: $e');
      }
    }
  }

  /// Handle check-in marker click (show/hide info popup)
  Future<void> _handleCheckInMarkerClick(UserCheckIn checkIn) async {
    final infoMarkerId = "checkin_info_${checkIn.userJoinGeoMapUuid}";
    final userName = _getUserNameFromUuid(checkIn.userJoinGeoMapUuid);

    if (config.mapType == GeoMapType.googleMap) {
      final existingIndex = _googleCheckInInfoMarkers
          .indexWhere((m) => m.markerId.value == infoMarkerId);
      if (existingIndex >= 0) {
        _googleCheckInInfoMarkers.removeAt(existingIndex);
      } else {
        try {
          final marker = kIsWeb
              ? await WebMarkerUtils.buildUserCheckInMarkerInfo(
                  userCheckIn: checkIn,
                  userName: userName,
                  onClick: () => _handleCheckInInfoClose(checkIn))
              : await MobileMarkerUtils.buildUserCheckInMarkerInfo(
                  userCheckIn: checkIn,
                  userName: userName,
                  onClick: () => _handleCheckInInfoClose(checkIn));
          _googleCheckInInfoMarkers.add(marker);
        } catch (e) {
          print('Error creating check-in info marker: $e');
        }
      }
    } else {
      final existingIndex = _flutterCheckInInfoMarkers
          .indexWhere((m) => m.key == ValueKey(infoMarkerId));
      if (existingIndex >= 0) {
        _flutterCheckInInfoMarkers.removeAt(existingIndex);
      } else {
        try {
          final marker = kIsWeb
              ? WebMarkerUtils.buildUserCheckInMarkerInfoForFlutterMap(
                  userCheckIn: checkIn,
                  userName: userName,
                  onClick: () => _handleCheckInInfoClose(checkIn))
              : MobileMarkerUtils.buildUserCheckInMarkerInfoForFlutterMap(
                  userCheckIn: checkIn,
                  userName: userName,
                  onClick: () => _handleCheckInInfoClose(checkIn));
          _flutterCheckInInfoMarkers.add(marker);
        } catch (e) {
          print('Error creating Flutter check-in info marker: $e');
        }
      }
    }
  }

  /// Handle check-in info popup close
  void _handleCheckInInfoClose(UserCheckIn checkIn) {
    final infoMarkerId = "checkin_info_${checkIn.userJoinGeoMapUuid}";
    if (config.mapType == GeoMapType.googleMap) {
      _googleCheckInInfoMarkers
          .removeWhere((m) => m.markerId.value == infoMarkerId);
    } else {
      _flutterCheckInInfoMarkers
          .removeWhere((m) => m.key == ValueKey(infoMarkerId));
    }
  }

  /// Get user name from UUID
  String _getUserNameFromUuid(String? uuid) {
    if (uuid == null || uuid.isEmpty) return "User";

    final userList = _geoMapInfo.value?.userJoinGeoMap;
    if (userList == null || userList.isEmpty) return "User";

    try {
      final user = userList.firstWhere(
        (u) => u.userId == uuid,
        orElse: () => userList.first,
      );
      return user.name ?? "User";
    } catch (e) {
      return "User";
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 19: MAP CONTROL METHODS
  // ════════════════════════════════════════════════════════════════════════════

  /// Updates the map with new position and zoom level
  void updateMap(latlong.LatLng position, double zoomLevel) {
    _center.value = position;
    _zoom.value = zoomLevel;
  }

  /// Move camera to a given position
  void moveCameraTo(
      {required double lat, required double lng, double? zoomLevel}) {
    final controller = googleMapController;
    if (controller != null) {
      controller.animateCamera(
        google_maps.CameraUpdate.newCameraPosition(
          google_maps.CameraPosition(
            target: google_maps.LatLng(lat, lng),
            zoom: (zoomLevel ?? zoom).toDouble(),
          ),
        ),
      );
    }
    updateMap(latlong.LatLng(lat, lng), zoomLevel ?? zoom);
  }

  /// Resets the map to default position and zoom
  void resetMap() {
    _center.value = const latlong.LatLng(10.762622, 106.660172);
    _zoom.value = 13.0;
  }

  /// Start location tracking (Web Google Map specific)
  StreamSubscription<Position>? _positionStreamSubscription;

  Future<void> startWebLocationTracking() async {
    print("Starting location tracking for Web Google Maps...");

    LocationPermission permission;

    // We skip extensive service checks here for Web as explained in moveToCurrentLocation
    try {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
    } catch (e) {
      print('Error checking/requesting permission in tracking: $e');
    }

    // Determine position immediately to show marker
    try {
        final position = await Geolocator.getCurrentPosition(
           locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        print("Error getting initial position: ${position.latitude}");
        _updateCurrentLocationMarker(position);
    } catch(e) {
        print("Error getting initial position: $e");
    }


    // Start stream
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50, // Update every 50m
    );

    _positionStreamSubscription?.cancel();
    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      print(
          'New location received: ${position.latitude}, ${position.longitude}');
      _updateCurrentLocationMarker(position);
    }, onError: (e) {
       print('Error in location stream: $e');
    });
  }

  /// Move map to current location
  Future<void> moveToCurrentLocation() async {
    print('moveToCurrentLocation: Called');

    // First, try to use the cached position if available (most reliable)
    if (_lastKnownPosition != null) {
      print('moveToCurrentLocation: Using cached position ${_lastKnownPosition!.latitude}, ${_lastKnownPosition!.longitude}');
      _moveCameraToPosition(_lastKnownPosition!.latitude, _lastKnownPosition!.longitude);
      return;
    }

    // Fallback: Try to get current position directly
    try {
      print('moveToCurrentLocation: Getting current position...');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );
      print('moveToCurrentLocation: Got position ${position.latitude}, ${position.longitude}');
      _moveCameraToPosition(position.latitude, position.longitude);
      _updateCurrentLocationMarker(position);
    } catch (e) {
      print('Error moving to current location: $e');
      print('Tip: Make sure location tracking is started and has received at least one position update.');
    }
  }

  /// Move camera to a specific lat/lng
  void _moveCameraToPosition(double lat, double lng) {
    final controller = googleMapController;
    if (controller != null) {
      controller.animateCamera(
        google_maps.CameraUpdate.newLatLngZoom(
          google_maps.LatLng(lat, lng),
          15.0,
        ),
      );
      print('moveToCurrentLocation: Camera animated to $lat, $lng');
    } else {
      print('moveToCurrentLocation: GoogleMapController is null');
    }
    updateMap(latlong.LatLng(lat, lng), 15.0);
  }

  /// Update the current location marker
  void _updateCurrentLocationMarker(Position position) async {
    // Cache this position for moveToCurrentLocation
    _lastKnownPosition = position;

    try {
      if (config.mapType == GeoMapType.googleMap && kIsWeb) {
        final marker = await WebMarkerUtils.buildCurrentLocationMarker(
          lat: position.latitude,
          lng: position.longitude,
        );
        _googleCurrentLocationMarker.value = marker;
        print('Success updating current location marker: ${position.latitude} ${position.longitude}');
      }
    } catch (e) {
      print('Error updating current location marker: $e');
    }
  }

  /// Stop location tracking
  void stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _googleCurrentLocationMarker.value = null; // Also clear marker
  }



  /// Process the geomap detail (backward compatibility)
  void processMapGeoDetail(MapGeoModel detail) {
    print('Processed map geo detail');
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SECTION 20: DEBUG & SIMULATION
  // ════════════════════════════════════════════════════════════════════════════

  Timer? _simulationTimer;

  /// Start a simulation of user movement for testing
  void startSimulation() {
    print('Starting location simulation...');
    stopLocationTracking(); // Stop real tracking to avoid conflict

    final startLat = _center.value.latitude;
    final startLng = _center.value.longitude;

    // Create a simple path: moving North-East
    final List<latlong.LatLng> mockPath = [];
     for (int i = 0; i < 20; i++) {
      mockPath.add(latlong.LatLng(
        startLat + (i * 0.0005),
        startLng + (i * 0.0005),
      ));
    }

    int index = 0;
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (index >= mockPath.length) {
        index = 0; // Loop
      }

      final point = mockPath[index++];
      final position = Position(
        latitude: point.latitude,
        longitude: point.longitude,
        timestamp: DateTime.now(),
        accuracy: 10,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 10, // 10 m/s
        speedAccuracy: 0,
        isMocked: true,
      );

      print('Simulating position: ${point.latitude}, ${point.longitude}');
      _updateCurrentLocationMarker(position);

      // Optional: keep camera focused on user
      //  moveCameraTo(
      //     lat: point.latitude,
      //     lng: point.longitude,
      //     zoomLevel: zoom
      // );
    });
  }

  /// Stop the simulation
  void stopSimulation() {
    print('Stopping location simulation');
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }
}

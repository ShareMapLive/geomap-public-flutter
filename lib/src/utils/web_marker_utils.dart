import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher;
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:geomap_package/src/utils/avatar_image_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:latlong2/latlong.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

import '../models/geofencing_model.dart';
import '../models/map_geo_model.dart';
import '../models/tracing_model.dart';
import 'map_colors.dart';
import 'marker_z_indexes.dart';
import 'triangle_painter.dart';

const double textSizeSMedium = 14.0;
const double textSizeSmall = 12.0;

/// Utility class for creating markers with web-optimized sizes
class WebMarkerUtils {
  /// Build current location marker for web (Blue dot)
  static Future<google_maps.Marker> buildCurrentLocationMarker({
    required double lat,
    required double lng,
  }) async {
    final widget = Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.withValues(alpha: 0.3),
        border: Border.all(color: Colors.blue, width: 1),
      ),
      child: Center(
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );

    final double scale =
        PlatformDispatcher.instance.views.first.devicePixelRatio;
    const logicalSize = Size(24, 24);
    final imageSize =
        Size(logicalSize.width * scale, logicalSize.height * scale);

    final bitmap = await widget.toBitmapDescriptor(
      logicalSize: logicalSize,
      imageSize: imageSize,
    );

    return google_maps.Marker(
      markerId: const google_maps.MarkerId('current_location_web'),
      position: google_maps.LatLng(lat, lng),
      icon: bitmap,
      zIndex: MarkerZIndex.currentLocation,
      anchor: const Offset(0.5, 0.5),
    );
  }

  /// Build user marker for web with smaller size using tracking configuration
  static Future<google_maps.Marker> buildUserGeoMapMarker(
    UserJoinGeoMap userLocationModel,
    TrackingVehicleConfiguration? trackingConfig,
    Function(UserJoinGeoMap) onClick,
  ) async {
    // Create a smaller widget for web
    final widget = _buildMarkerStackWidget(
      name: userLocationModel.name,
      trackingConfig: trackingConfig,
      userAvatar: userLocationModel.linkAvatar,
    );

    final double scale =
        PlatformDispatcher.instance.views.first.devicePixelRatio;
    const logicalSize = Size(120, 150);
    final imageSize =
        Size(logicalSize.width * scale, logicalSize.height * scale);

    final bitmap = await widget.toBitmapDescriptor(
      logicalSize: logicalSize,
      imageSize: imageSize,
    );

    return google_maps.Marker(
      markerId: google_maps.MarkerId(userLocationModel.userId ??
          'user_${userLocationModel.lat}_${userLocationModel.lng}'),
      position: google_maps.LatLng(
        userLocationModel.lat?.toDouble() ?? 0.0,
        userLocationModel.lng?.toDouble() ?? 0.0,
      ),
      icon: bitmap,
      zIndex: MarkerZIndex.userGeoMapAvatar,
      onTap: () {
        onClick(userLocationModel);
      },
    );
  }

  /// Build user marker for Flutter Map on web with smaller size
  static flutter_map.Marker buildUserGeoMapMarkerForFlutterMap(
    UserJoinGeoMap userLocationModel,
    TrackingVehicleConfiguration? trackingConfig,
    Function(UserJoinGeoMap) onClick,
  ) {
    return flutter_map.Marker(
      width: 150,
      height: 120,
      point: LatLng(
        userLocationModel.lat?.toDouble() ?? 0.0,
        userLocationModel.lng?.toDouble() ?? 0.0,
      ),
      child: _buildMarkerStackWidget(
        name: userLocationModel.name,
        trackingConfig: trackingConfig,
        userAvatar: userLocationModel.linkAvatar,
      ),
      key: ValueKey(userLocationModel.userId ??
          'user_${userLocationModel.lat}_${userLocationModel.lng}'),
    );
  }

  /// Build marker stack widget based on tracking configuration for web
  static Widget _buildMarkerStackWidget({
    String? name,
    TrackingVehicleConfiguration? trackingConfig,
    String? userAvatar,
  }) {
    // Handle different avatar options based on tracking configuration
    if (trackingConfig?.typeAvatarOption == "text") {
      return Stack(
        children: [
          Positioned(
            bottom: 23,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              height: 45,
              constraints: const BoxConstraints(minWidth: 70, maxWidth: 120),
              decoration: BoxDecoration(
                color: MapColors.markerInfoBoxBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: MapColors.markerInfoBoxBorder),
              ),
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  String displayName = name ?? "";
                  final words = displayName.split(' ');
                  if (words.length <= 3) {
                    displayName = words.join(' ');
                  } else {
                    final firstLine = words.sublist(0, 3).join(' ');
                    String secondLine = words.length <= 6
                        ? words.sublist(3).join(' ')
                        : "${words.sublist(3, 6).join(' ')}...";
                    displayName = '$firstLine\n$secondLine';
                  }
                  return Center(
                    child: Text(
                      displayName,
                      style: const TextStyle(fontSize: 11),
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Icon(Icons.arrow_drop_down, size: 40, color: Colors.grey),
            ),
          ),
        ],
      );
    } else if (trackingConfig?.typeAvatarOption == "emoji") {
      return SizedBox(
        height: 30,
        width: 30,
        child: Text(
          trackingConfig?.valueAvatarOption ?? "🙂",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontFamily: 'NotoColorEmoji'),
        ),
      );
    } else {
      return Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                height: 50,
                width: 50,
                child: Image.asset(
                  "images/icon_user_marker_backup.png",
                  height: 50,
                  width: 50,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: AvatarImageUtils(
                image: userAvatar,
                sizeImage: 30,
                name: name,
                color: MapColors().getRandomColor(name),
              ),
            ),
          ),
        ],
      );
    }
  }

  /// Build geofencing center marker with index number for web with smaller size
  static Future<google_maps.Marker> buildGeofencingCenterMarker(
    PublicGeofencingModel item,
    int index,
    Function(PublicGeofencingModel) onClick,
  ) async {
    // Use the lat/lng fields directly
    if (item.lat == null || item.lng == null) {
      throw Exception('Geofencing item has no coordinates');
    }

    // Tạo widget, rồi convert thành BitmapDescriptor
    final markerWidget = Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: MapColors.geofencingCenterBorderMarker,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: MapColors.geofencingCenterMarker,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            (index + 1).toString(),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );

    // Convert widget -> BitmapDescriptor (xài widget_to_marker package hoặc tương đương)
    final scaleFactor = WidgetsBinding.instance.window.devicePixelRatio;
    const logicalSize = Size(32, 32);
    final imageSize = Size(32 * scaleFactor, 32 * scaleFactor);
    final bitmap = await markerWidget.toBitmapDescriptor(
      logicalSize: logicalSize,
      imageSize: imageSize,
    );

    // Trả ra marker Google Maps
    return google_maps.Marker(
      markerId: google_maps.MarkerId(
          'center_${item.uuid ?? 'point_${item.lat}_${item.lng}'}'),
      position: google_maps.LatLng(
        item.lat!.toDouble(),
        item.lng!.toDouble(),
      ),
      icon: bitmap,
      zIndex: MarkerZIndex.geofencingCenter,
      onTap: () {
        onClick(item);
      },
      consumeTapEvents: true,
      anchor: const Offset(0.5, 0.5),
    );
  }

  /// Build user marker for Flutter Map on web with smaller size
  static flutter_map.Marker buildGeofencingCenterMarkerForFlutterMap(
    PublicGeofencingModel item,
    int index,
    Color color,
    Function(PublicGeofencingModel) onClick,
  ) {
    // Use the lat/lng fields directly
    if (item.lat == null || item.lng == null) {
      throw Exception('Geofencing item has no coordinates');
    }

    return flutter_map.Marker(
      width: 40,
      height: 40,
      point: LatLng(
        item.lat!.toDouble(),
        item.lng!.toDouble(),
      ),
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: MapColors.geofencingCenterBorderMarker,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: MapColors.geofencingCenterMarker,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              (index + 1).toString(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
      key: ValueKey(
          'center_${item.uuid ?? 'point_${item.lat}_${item.lng}_$index'}'),
    );
  }

  /// Build circle for web
  static google_maps.Circle buildGeofencingCircle(
    PublicGeofencingModel item,
    Color color,
  ) {
    // Use the lat/lng fields directly
    if (item.lat == null || item.lng == null) {
      throw Exception('Geofencing item has no coordinates');
    }

    return google_maps.Circle(
      circleId:
          google_maps.CircleId(item.uuid ?? 'circle_${item.lat}_${item.lng}'),
      center: google_maps.LatLng(
        item.lat!.toDouble(),
        item.lng!.toDouble(),
      ),
      radius: item.radius?.toDouble() ?? 100.0,
      fillColor: color.withValues(alpha: 0.3),
      strokeColor: color,
      strokeWidth: 2,
    );
  }

  /// Build circle marker for Flutter Map on web
  static flutter_map.CircleMarker buildGeofencingCircleMarker(
    PublicGeofencingModel item,
    Color color,
  ) {
    // Use the lat/lng fields directly
    if (item.lat == null || item.lng == null) {
      throw Exception('Geofencing item has no coordinates');
    }

    return flutter_map.CircleMarker(
      point: LatLng(
        item.lat!.toDouble(),
        item.lng!.toDouble(),
      ),
      radius: item.radius?.toDouble() ?? 100.0,
      color: color.withValues(alpha: 0.3),
      borderColor: color,
      borderStrokeWidth: 2,
    );
  }

  /// Build user check-in marker
  static Future<google_maps.Marker> buildUserCheckInMarker(
    UserCheckIn userCheckIn,
    Function(UserCheckIn) onClick,
  ) async {
    if (userCheckIn.lat == null || userCheckIn.lng == null) {
      throw Exception('UserCheckIn has no coordinates');
    }

    final widget = SizedBox(
      width: 45,
      height: 45,
      child: Image.asset(
        'images/user_checkin_marker.png',
        package: 'geomap_package',
      ),
    );

    final double scale =
        PlatformDispatcher.instance.views.first.devicePixelRatio;
    const logicalSize = Size(45, 45);
    final imageSize =
        Size(logicalSize.width * scale, logicalSize.height * scale);

    final bitmap = await widget.toBitmapDescriptor(
      logicalSize: logicalSize,
      imageSize: imageSize,
    );

    return google_maps.Marker(
      markerId:
          google_maps.MarkerId('checkin_${userCheckIn.lat}_${userCheckIn.lng}'),
      position: google_maps.LatLng(
        userCheckIn.lat!.toDouble(),
        userCheckIn.lng!.toDouble(),
      ),
      icon: bitmap,
      onTap: () {
        onClick(userCheckIn);
      },
    );
  }

  /// Build user check-in marker for Flutter Map on web
  static flutter_map.Marker buildUserCheckInMarkerForFlutterMap(
    UserCheckIn userCheckIn,
    Function(UserCheckIn) onClick,
  ) {
    if (userCheckIn.lat == null || userCheckIn.lng == null) {
      throw Exception('UserCheckIn has no coordinates');
    }

    return flutter_map.Marker(
      width: 45,
      height: 45,
      point: LatLng(
        userCheckIn.lat!.toDouble(),
        userCheckIn.lng!.toDouble(),
      ),
      child: GestureDetector(
        onTap: () {
          onClick(userCheckIn);
        },
        child: Image.asset(
          'images/user_checkin_marker.png',
          package: 'geomap_package',
        ),
      ),
      key: ValueKey('checkin_${userCheckIn.lat}_${userCheckIn.lng}'),
    );
  }

  /// Build user check-in info marker (Google Maps)
  static Future<google_maps.Marker> buildUserCheckInMarkerInfo({
    required UserCheckIn userCheckIn,
    required String userName,
    required void Function() onClick,
  }) async {
    // Format time
    String formattedTime = "";
    if (userCheckIn.timeCheckIn != null) {
      final dateTime =
          DateTime.fromMillisecondsSinceEpoch(userCheckIn.timeCheckIn!);
      formattedTime =
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ngày ${dateTime.day}/${dateTime.month}/${dateTime.year}";
    }

    final String address = userCheckIn.address ?? "";

    final widget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and close button
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.person_outline,
                      size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onClick,
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Time row
              if (formattedTime.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: textSizeSmall,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              if (formattedTime.isNotEmpty) const SizedBox(height: 8),
              // Address row
              if (address.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        address,
                        style: const TextStyle(
                          fontSize: textSizeSmall,
                          color: Colors.black87,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        // Arrow down
        CustomPaint(
          size: const Size(10, 6),
          painter: TrianglePainter(color: Colors.white),
        ),
        const SizedBox(height: 55),
      ],
    );

    final double scaleFactor =
        PlatformDispatcher.instance.views.first.devicePixelRatio;
    const logicalSize = Size(240, 230);
    final imageSize =
        Size(logicalSize.width * scaleFactor, logicalSize.height * scaleFactor);
    final bitmapDescriptor = await widget.toBitmapDescriptor(
      logicalSize: logicalSize,
      imageSize: imageSize,
    );

    return google_maps.Marker(
      zIndex: MarkerZIndex.userCheckInInfoPopup,
      consumeTapEvents: true,
      anchor: const Offset(0.5, 1.25),
      markerId: google_maps.MarkerId(
          "checkin_info_${userCheckIn.userJoinGeoMapUuid}"),
      position: google_maps.LatLng(
          userCheckIn.lat!.toDouble(), userCheckIn.lng!.toDouble()),
      icon: bitmapDescriptor,
      onTap: () => onClick(),
    );
  }

  /// Build user check-in info marker (Flutter Map)
  static flutter_map.Marker buildUserCheckInMarkerInfoForFlutterMap({
    required UserCheckIn userCheckIn,
    required String userName,
    required void Function() onClick,
  }) {
    // Format time
    String formattedTime = "";
    if (userCheckIn.timeCheckIn != null) {
      final dateTime =
          DateTime.fromMillisecondsSinceEpoch(userCheckIn.timeCheckIn!);
      formattedTime =
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ngày ${dateTime.day}/${dateTime.month}/${dateTime.year}";
    }

    final String address = userCheckIn.address ?? "";

    return flutter_map.Marker(
      width: 240,
      height: 230,
      alignment: Alignment.bottomCenter,
      point: LatLng(
        userCheckIn.lat!.toDouble(),
        userCheckIn.lng!.toDouble(),
      ),
      child: GestureDetector(
        onTap: onClick,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with name and close button
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.person_outline,
                          size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Time row
                  if (formattedTime.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time,
                            size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            formattedTime,
                            style: const TextStyle(
                              fontSize: textSizeSmall,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (formattedTime.isNotEmpty) const SizedBox(height: 8),
                  // Address row
                  if (address.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            address,
                            style: const TextStyle(
                              fontSize: textSizeSmall,
                              color: Colors.black87,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // Arrow down
            CustomPaint(
              size: const Size(10, 6),
              painter: TrianglePainter(color: Colors.white),
            ),
            const SizedBox(height: 55),
          ],
        ),
      ),
      key: ValueKey("checkin_info_${userCheckIn.userJoinGeoMapUuid}"),
    );
  }

  static google_maps.BitmapDescriptor? _cachedDotBitmap;

  /// Build a small green dot marker for a tracing path point (Google Maps)
  static Future<google_maps.Marker> buildTracingDotMarker({
    required double lat,
    required double lng,
    required String markerId,
    String? time,
    String? address,
    required void Function() onClick,
  }) async {
    if (_cachedDotBitmap == null) {
      final widget = Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green,
          border: Border.all(color: Colors.white, width: 2),
        ),
      );

      final double scale =
          PlatformDispatcher.instance.views.first.devicePixelRatio;
      const logicalSize = Size(16, 16);
      final imageSize =
          Size(logicalSize.width * scale, logicalSize.height * scale);

      _cachedDotBitmap = await widget.toBitmapDescriptor(
        logicalSize: logicalSize,
        imageSize: imageSize,
      );
    }

    return google_maps.Marker(
      markerId: google_maps.MarkerId(markerId),
      position: google_maps.LatLng(lat, lng),
      icon: _cachedDotBitmap!,
      zIndex: MarkerZIndex.tracingDot,
      anchor: const Offset(0.5, 0.5),
      onTap: onClick,
    );
  }

  /// Build info popup marker for a tracing dot (Google Maps)
  static Future<google_maps.Marker> buildTracingDotInfoMarker({
    required double lat,
    required double lng,
    required String markerId,
    String? time,
    String? address,
    bool isAvatar = false,
    required void Function() onClose,
  }) async {
    String formattedTime = '';
    if (time != null && time.isNotEmpty) {
      try {
        DateTime dt;
        if (time.contains('T') || time.contains('Z')) {
          dt = DateTime.parse(time).toLocal();
        } else {
          dt = DateTime.fromMillisecondsSinceEpoch(int.parse(time)).toLocal();
        }
        formattedTime =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} ngày ${dt.day}/${dt.month}/${dt.year}';
      } catch (_) {
        formattedTime = time;
      }
    }

    final widget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.4)),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  const Text(
                    'Vị trí',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onClose,
                    child:
                        const Icon(Icons.close, size: 16, color: Colors.grey),
                  ),
                ],
              ),
              if (formattedTime.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        formattedTime,
                        style: const TextStyle(
                            fontSize: textSizeSmall, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (address != null && address.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        address,
                        style: const TextStyle(
                            fontSize: textSizeSmall, color: Colors.black87),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        CustomPaint(
          size: const Size(10, 6),
          painter: TrianglePainter(color: Colors.white),
        ),
        const SizedBox(height: 16),
      ],
    );

    final double scaleFactor =
        PlatformDispatcher.instance.views.first.devicePixelRatio;
    const logicalSize = Size(200, 160);
    final imageSize =
        Size(logicalSize.width * scaleFactor, logicalSize.height * scaleFactor);
    final bitmapDescriptor = await widget.toBitmapDescriptor(
      logicalSize: logicalSize,
      imageSize: imageSize,
    );

    return google_maps.Marker(
      zIndex: MarkerZIndex.tracingDotInfoPopup,
      consumeTapEvents: true,
      markerId: google_maps.MarkerId(markerId),
      position: google_maps.LatLng(lat, lng),
      icon: bitmapDescriptor,
      anchor: isAvatar ? const Offset(0.5, 1.22) : const Offset(0.5, 1.0),
      onTap: onClose,
    );
  }
}

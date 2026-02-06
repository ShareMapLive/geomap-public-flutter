import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/geofencing_model.dart';
import 'map_colors.dart';

/// Utility class for creating Flutter Map markers, circles, polygons, and polylines
class FlutterMapMarkerUtils {

  /// Build polygon for Flutter Map
  static Polygon buildGeofencingPolygon(
    PublicGeofencingModel item,
  ) {
    // Use the polygon field directly
    if (item.polygon == null || item.polygon!.length < 3) {
      throw Exception('Geofencing polygon requires at least 3 points');
    }

    final points = item.polygon!
        .map((p) => LatLng(p[1].toDouble(), p[0].toDouble()))
        .toList();

    return Polygon(
      points: points,
      color: MapColors.geofencingPolygon.withValues(alpha: 0.1),
      borderColor: MapColors.geofencingPolygon.withValues(alpha: 0.2),
      borderStrokeWidth: 1,
    );
  }

  /// Build route polyline for Flutter Map
  static Polyline buildRoutePolyline(
    List<LatLng> routePoints,
    Color color,
    int index,
  ) {
    return Polyline(
      points: routePoints,
      color: color,
      strokeWidth: 5,
    );
  }

  /// Build tracing route polyline for Flutter Map
  static Polyline buildRouteTracingPolyline(
    List<LatLng> routePoints,
    Color color,
    int index,
  ) {
    return Polyline(
      points: routePoints,
      color: color,
      strokeWidth: 5,
    );
  }
}

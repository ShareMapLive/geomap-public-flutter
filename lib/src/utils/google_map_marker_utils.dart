import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../models/geofencing_model.dart';
import 'map_colors.dart';

/// Utility class for creating Google Maps markers, circles, polygons, and polylines
class GoogleMapMarkerUtils {
  /// Build polygon for Google Maps
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
      polygonId: PolygonId(
          item.uuid ?? 'polygon_${DateTime.now().millisecondsSinceEpoch}'),
      points: points,
      fillColor: MapColors.geofencingPolygon.withValues(alpha: 0.2),
      strokeColor: MapColors.geofencingPolygon.withValues(alpha: 0.5),
      strokeWidth: 1,
    );
  }

  /// Build route polyline for Google Maps
  static Polyline buildRoutePolyline(
    List<latlong.LatLng> routePoints,
    Color color,
    int index,
  ) {
    print('Building route polyline $index with ${routePoints.length} points');
    final points = routePoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
    print('Converted to ${points.length} Google Maps LatLng points');

    final polyline = Polyline(
      polylineId: PolylineId('route_$index'),
      points: points,
      color: color,
      width: 5,
    );
    print('Created polyline with ID: route_$index, points count: ${polyline.points.length}');
    return polyline;
  }

  /// Build tracing route polyline for Google Maps with unique ID to avoid conflicts
  static Polyline buildRouteTracingPolyline(
    List<latlong.LatLng> routePoints,
    Color color,
    int index,
  ) {
    print('Building tracing route polyline $index with ${routePoints.length} points');
    final points = routePoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
    print('Converted to ${points.length} Google Maps LatLng points');

    final polyline = Polyline(
      polylineId: PolylineId('route_tracing_$index'),
      points: points,
      color: color,
      zIndex: 1, // Higher z-index for tracing routes
      width: 5,
    );
    print('Created tracing polyline with ID: route_tracing_$index, points count: ${polyline.points.length}');
    return polyline;
  }
}

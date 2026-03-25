import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../models/geofencing_model.dart';
import 'map_colors.dart';
import 'marker_z_indexes.dart';

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
    final points = routePoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    return Polyline(
      polylineId: PolylineId('route_$index'),
      points: points,
      color: color,
      width: 5,
    );
  }

  /// Build tracing route polyline for Google Maps with unique ID to avoid conflicts
  static Polyline buildRouteTracingPolyline(
    List<latlong.LatLng> routePoints,
    Color color,
    int index,
  ) {
    final points = routePoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    return Polyline(
      polylineId: PolylineId('route_tracing_$index'),
      points: points,
      color: color,
      zIndex: MarkerZIndex.tracingRoutePolyline.toInt(),
      width: 5,
    );
  }
}

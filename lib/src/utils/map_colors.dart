import 'dart:math';

import 'package:flutter/material.dart';

/// Color constants for the geomap package
/// Centralized color definitions for easy customization and consistency
class MapColors {
  /// User marker color
  static const Color userMarker = Color(0xFF2196F3); // Blue

  /// Geofencing center marker color
  static const Color geofencingCenterMarker = Color(0xFFFFFFFF); // White

  /// Geofencing center marker border color
  static const Color geofencingCenterBorderMarker = Colors.grey; // White

  /// Geofencing polygon color
  static const Color geofencingPolygon = Color(0xffed184b); // Red

  /// Geofencing circle color
  static const Color geofencingCircle = Color(0xFF4CAF50); // Green

  /// Route color
  static const Color route = Color(0xff04439b); // Blue

  /// Marker border color
  static const Color markerBorder = Color(0xFFFFFFFF); // White

  /// Marker text color
  static const Color markerText = Color(0xFFFFFFFF); // White

  /// Marker background color
  static const Color markerBackground = Color(0xFF2196F3); // Blue

  /// Marker info box background color
  static const Color markerInfoBoxBackground = Color(0xFFFFFFFF); // White

  /// Marker info box border color
  static const Color markerInfoBoxBorder = Color(0xFF9E9E9E); // Grey

  /// Marker info box text color
  static const Color markerInfoBoxText = Color(0xFF000000); // Black

  Color getRandomColor(String? name) {
    final random = Random(name.hashCode);
    return Colors.primaries[random.nextInt(Colors.primaries.length)];
  }
}

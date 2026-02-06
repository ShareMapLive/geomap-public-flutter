import 'package:flutter/material.dart';

import '../../geomap_controller.dart';
import '../../geomap_factory.dart';

/// Base widget that contains the core map functionality
/// This widget is shared between mobile and web implementations
class BaseGeoMapWidget extends StatelessWidget {
  /// The controller managing the map state
  final GeoMapController controller;

  /// Callback when the map is created
  final VoidCallback? onMapCreated;

  /// Whether to show the user's current location
  final bool myLocationEnabled;

  /// Whether to show zoom controls
  final bool zoomControlsEnabled;

  /// Whether to show the my location button
  final bool myLocationButtonEnabled;

  /// Whether to show the compass button
  final bool compassEnabled;

  /// Whether to show the map toolbar
  final bool mapToolbarEnabled;

  /// Whether to enable rotate gestures
  final bool rotateGesturesEnabled;

  /// Creates a new [BaseGeoMapWidget] instance
  const BaseGeoMapWidget({
    super.key,
    required this.controller,
    this.onMapCreated,
    this.myLocationEnabled = true,
    this.zoomControlsEnabled = true,
    this.myLocationButtonEnabled = true,
    this.compassEnabled = false,
    this.mapToolbarEnabled = false,
    this.rotateGesturesEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    // Core map implementation
    return GeoMapFactory.createMap(
      controller: controller,
      onMapCreated: onMapCreated,
      myLocationEnabled: myLocationEnabled,
      zoomControlsEnabled: zoomControlsEnabled,
      myLocationButtonEnabled: myLocationButtonEnabled,
      compassEnabled: compassEnabled,
      mapToolbarEnabled: mapToolbarEnabled,
      rotateGesturesEnabled: rotateGesturesEnabled,
    );
  }
}

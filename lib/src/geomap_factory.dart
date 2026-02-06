import 'package:flutter/material.dart';

import 'geomap_controller.dart';
import 'models/geomap_type.dart';
import 'maps/google_map_impl.dart';
import 'maps/flutter_map_impl.dart';

/// Factory class for creating the appropriate map implementation
class GeoMapFactory {
  /// Creates the appropriate map widget based on the configuration
  static Widget createMap({
    required GeoMapController controller,
    VoidCallback? onMapCreated,
    bool myLocationEnabled = true,
    bool zoomControlsEnabled = true,
    bool myLocationButtonEnabled = true,
    bool compassEnabled = false,
    bool mapToolbarEnabled = false,
    bool rotateGesturesEnabled = false,
  }) {
    // Use the map type specified in the config
    if (controller.config.mapType == GeoMapType.flutterMap) {
      return FlutterMapImpl(
        controller: controller,
        onMapCreated: onMapCreated,
        myLocationEnabled: myLocationEnabled,
        zoomControlsEnabled: zoomControlsEnabled,
        myLocationButtonEnabled: myLocationButtonEnabled,
        compassEnabled: compassEnabled,
        mapToolbarEnabled: mapToolbarEnabled,
        rotateGesturesEnabled: rotateGesturesEnabled,
      );
    } else {
      return GoogleMapImpl(
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
}

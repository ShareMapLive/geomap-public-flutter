import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';

import '../geomap_controller.dart';

/// Flutter Map implementation of the geomap
class FlutterMapImpl extends StatelessWidget {
  final GeoMapController controller;
  final VoidCallback? onMapCreated;
  final bool myLocationEnabled;
  final bool zoomControlsEnabled;
  final bool myLocationButtonEnabled;
  final bool compassEnabled;
  final bool mapToolbarEnabled;
  final bool rotateGesturesEnabled;

  const FlutterMapImpl({
    super.key,
    required this.controller,
    this.onMapCreated,
    this.myLocationEnabled = false,
    this.zoomControlsEnabled = true,
    this.myLocationButtonEnabled = true,
    this.compassEnabled = false,
    this.mapToolbarEnabled = false,
    this.rotateGesturesEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return FlutterMap(
        options: MapOptions(
          initialCenter: controller.center,
          initialZoom: controller.zoom,
          onPositionChanged: (position, _) {
            controller.updateMap(position.center, position.zoom);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'geomap_package',
          ),
          CircleLayer(
            circles: controller.flutterMapCircles,
          ),
          PolygonLayer(
            polygons: controller.flutterMapPolygons,
          ),
          PolylineLayer(
            polylines: [
              // Regular polylines
              ...controller.flutterMapPolylines,
              // Tracing polylines
              ...controller.flutterMapTracingPolylines,
            ],
          ),
          MarkerLayer(
            markers: [
              // User markers
              ...controller.flutterMapUserMarkers,
              // Geofencing center markers
              ...controller.flutterMapGeofencingCenterMarkers,
              // User check-in markers
              ...controller.flutterMapUserCheckInMarkers,
              // User check-in info markers
              ...controller.flutterMapInfoUserCheckInMarkers,
            ],
          ),
        ],
      );
    });
  }
}
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../geomap_controller.dart';

/// Google Maps implementation of the geomap
class GoogleMapImpl extends StatelessWidget {
  final GeoMapController controller;
  final VoidCallback? onMapCreated;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool zoomControlsEnabled;
  final bool rotateGesturesEnabled;
  final bool compassEnabled;
  final bool mapToolbarEnabled;

  const GoogleMapImpl({
    super.key,
    required this.controller,
    this.onMapCreated,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = true,
    this.zoomControlsEnabled = false,
    this.rotateGesturesEnabled = false,
    this.compassEnabled = false,
    this.mapToolbarEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          return GoogleMap(
            onMapCreated: (GoogleMapController mapController) {
              controller.isMapReady = true;
              controller.googleMapController = mapController;

              if (kIsWeb && myLocationEnabled) {
                controller.startWebLocationTracking();
              }

              if (onMapCreated != null) {
                onMapCreated!();
              }
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(
                controller.center.latitude,
                controller.center.longitude,
              ),
              zoom: controller.zoom,
            ),
            // On Web, we handle myLocation manually to have better control/custom marker
            // But we can let Google Maps handle it if myLocationEnabled is passed and it works.
            // However, request is to use "blue dot" marker and manually update it,
            // so we set myLocationEnabled to false on Web for the native layer to avoid duplicates
            // if we are rendering our own marker.
            // BUT, if we want the "blue dot" from Google Maps SDK, we just enable it.
            // The prompt implies we created a custom marker `googleCurrentLocationMarker`.
            // So we disable native myLocation layer on Web.
            myLocationEnabled: kIsWeb ? false : myLocationEnabled,
            // Same for button, we implement custom button for Web
            myLocationButtonEnabled: kIsWeb ? false : myLocationButtonEnabled,
            zoomControlsEnabled: zoomControlsEnabled,
            rotateGesturesEnabled: rotateGesturesEnabled,
            tiltGesturesEnabled: rotateGesturesEnabled,
            compassEnabled: compassEnabled,
            mapToolbarEnabled: mapToolbarEnabled,
            onCameraMove: (cameraPosition) {
              controller.updateMap(
                latlong.LatLng(
                  cameraPosition.target.latitude,
                  cameraPosition.target.longitude,
                ),
                cameraPosition.zoom,
              );
            },
            markers: {
              // User markers
              ...controller.googleMapsUserMarkers.toSet(),
              // Geofencing center markers
              ...controller.googleMapsGeofencingCenterMarkers.toSet(),
              // User check-in markers
              ...controller.googleMapsUserCheckInMarkers.toSet(),
              // User check-in info markers
              ...controller.googleMapsInfoUserCheckInMarkers.toSet(),
              if (controller.googleCurrentLocationMarker != null)
                controller.googleCurrentLocationMarker!,
            },
            circles: controller.googleMapsCircles.toSet(),
            polygons: controller.googleMapsPolygons.toSet(),
            polylines: {
              // Regular polylines
              ...controller.googleMapsPolylines.toSet(),
              // Tracing polylines
              ...controller.googleMapsTracingPolylines.toSet(),
            },
          );
        }),
        // Custom My Location Button for Web
        if (kIsWeb && myLocationButtonEnabled)
          Positioned(
            right: 8,
            bottom: 80, // Positioned above where Google logo usually is
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                controller.moveToCurrentLocation();
              },
              child: const Icon(Icons.my_location, color: Colors.black54),
            ),
          ),
      ],
    );
  }
}
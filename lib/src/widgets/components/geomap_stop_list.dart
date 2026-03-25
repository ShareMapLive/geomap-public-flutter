import 'package:flutter/material.dart';
import 'package:geomap_package/geomap_package.dart';
import 'package:get/get.dart';

class GeoMapStopList extends StatelessWidget {
  final GeoMapController controller;
  final FontConfig fontConfig;
  final Function(dynamic stop)? onStopItemPressed;

  const GeoMapStopList({
    super.key,
    required this.controller,
    required this.fontConfig,
    this.onStopItemPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mapDetail = controller.mapGeoDetail;
      final geos = controller.publicGeofencingList;

      List<dynamic> stops = [];
      bool isPolygon = mapDetail?.type?.toLowerCase() == 'polygon';

      if (isPolygon && geos.isNotEmpty) {
        stops = geos.first.data ?? [];
      } else {
        stops = geos;
      }

      if (stops.isEmpty) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stops.length,
              itemBuilder: (context, index) {
                final dynamic stop = stops[index];
                // Determine title and address based on type
                String title = "";
                String address = "";
                double? lat, lng;
                bool hasCheckIn = false;

                if (stop is PointData) {
                  title = stop.title ?? "Điểm ${index + 1}";
                  address = stop.address ?? "";
                  if (stop.point != null && stop.point!.length >= 2) {
                    lng = stop.point![0];
                    lat = stop.point![1];
                  }
                  hasCheckIn = stop.userCheckIn != null;
                } else if (stop is PublicGeofencingModel) {
                  title = stop.title ?? stop.name ?? "Điểm ${index + 1}";
                  address = stop.address ?? "";
                  lat = stop.lat;
                  lng = stop.lng;
                  hasCheckIn = stop.userCheckIn != null;
                }

                bool isLast = index == stops.length - 1;

                // Green when: has check-in, OR viewer role (see full route), OR driver role
                bool isActive = hasCheckIn ||
                    controller.config.role == GeoMapRole.viewer ||
                    controller.config.role == GeoMapRole.driver;
                Color borderColor;
                Color backgroundColor;
                Color textColor;

                if (isActive) {
                  // Active stop – green indicator
                  borderColor = Colors.green;
                  backgroundColor = Colors.green;
                  textColor = Colors.white;
                } else {
                  // Inactive stop – minimal style
                  borderColor = Colors.transparent;
                  backgroundColor = Colors.transparent;
                  textColor = Colors.grey[600]!;
                }

                return InkWell(
                  onTap: () {
                    if (lat != null && lng != null) {
                      controller.moveCameraTo(
                          lat: lat.toDouble(),
                          lng: lng.toDouble(),
                          zoomLevel: 16);
                    }

                    // Auto collapse if width is narrow (mobile)
                    if (MediaQuery.of(context).size.width < 650) {
                      controller.collapseSheet();
                    }

                    onStopItemPressed?.call(stop);
                  },
                  hoverColor: Colors.blue.withValues(alpha: 0.05),
                  splashColor: Colors.blue.withValues(alpha: 0.1),
                  // borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: borderColor, width: 1.5),
                                ),
                                child: Text(
                                  (index + 1).toString(),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 1,
                                    color: Colors.grey[300],
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title,
                                      style: fontConfig.subtitleStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text(address,
                                      style: fontConfig.bodyStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    });
  }
}

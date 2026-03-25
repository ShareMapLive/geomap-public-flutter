import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import '../../geomap_controller.dart';
import '../../models/geofencing_model.dart';

/// A compact vertical timeline shown on the left side of the map when
/// the mobile sheet or web side panel is collapsed.
///
/// Displays stop name and address with numbering and can be expanded/collapsed.
class GeoMapCollapsedTimeline extends StatelessWidget {
  final GeoMapController controller;

  const GeoMapCollapsedTimeline({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mapDetail = controller.mapGeoDetail;
      final geos = controller.publicGeofencingList;
      final isTimelineExpanded = controller.isTimelineExpanded.value;

      List<dynamic> stops = [];
      bool isPolygon = mapDetail?.type?.toLowerCase() == 'polygon';

      if (isPolygon && geos.isNotEmpty) {
        stops = geos.first.data ?? [];
      } else {
        stops = geos;
      }

      if (stops.isEmpty) return const SizedBox.shrink();

      return PointerInterceptor(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(left: 12),
          padding: const EdgeInsets.symmetric(vertical: 4),
          constraints: BoxConstraints(
            maxHeight: 450,
            maxWidth: isTimelineExpanded ? 200 : 44,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle Header Button
              InkWell(
                onTap: controller.toggleTimeline,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isTimelineExpanded
                            ? Icons.keyboard_double_arrow_left_rounded
                            : Icons.checklist_rtl_rounded,
                        size: 20,
                        color: Colors.green,
                      ),
                      if (isTimelineExpanded) ...[
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Lịch trình',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),

              if (isTimelineExpanded)
                Flexible(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                    shrinkWrap: true,
                    itemCount: stops.length,
                    itemBuilder: (context, index) {
                      final dynamic stop = stops[index];
                      final isLast = index == stops.length - 1;

                      String title = "";
                      String address = "";
                      double? lat, lng;

                      if (isPolygon) {
                        title = "Điểm ${index + 1}";
                        lat = stop[1];
                        lng = stop[0];
                      } else if (stop is PointData) {
                        title = stop.title ?? "Điểm ${index + 1}";
                        address = stop.address ?? "";
                        if (stop.point != null && stop.point!.length >= 2) {
                          lng = stop.point![0];
                          lat = stop.point![1];
                        }
                      } else if (stop is PublicGeofencingModel) {
                        title = stop.title ?? stop.name ?? "Điểm ${index + 1}";
                        address = stop.address ?? "";
                        lat = stop.lat;
                        lng = stop.lng;
                      }

                      return InkWell(
                        onTap: () {
                          if (lat != null && lng != null) {
                            controller.moveCameraTo(
                              lat: lat.toDouble(),
                              lng: lng.toDouble(),
                              zoomLevel: 16,
                            );
                          }
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left column: Dot with Number & Connector
                            Column(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.green, width: 2),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                if (!isLast)
                                  Container(
                                    width: 1.5,
                                    height: address.isNotEmpty ? 40 : 20,
                                    color: Colors.green.withValues(alpha: 0.3),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            // Right column: Content (Title + Address)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (address.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        address,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                          height: 1.2,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

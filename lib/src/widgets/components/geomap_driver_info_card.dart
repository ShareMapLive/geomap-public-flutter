import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../geomap_controller.dart';
import '../../models/font_config.dart';
import '../../models/geomap_driver_info_card_model.dart';
import '../../models/map_geo_model.dart';
import 'card_container.dart';

class GeoMapDriverInfoCard extends StatelessWidget {
  final GeoMapController controller;
  final FontConfig fontConfig;

  /// Optional model to override the card display values.
  /// When a field in [driverInfoCardModel] is non-null it replaces the default
  /// value resolved from the controller tracing data.
  final GeomapDriverInfoCardModel? driverInfoCardModel;

  const GeoMapDriverInfoCard({
    super.key,
    required this.controller,
    required this.fontConfig,
    this.driverInfoCardModel,
  });

  void _handlePhonePress(String phone) {
    _launchPhoneCall(phone);
  }

  Future<void> _launchPhoneCall(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      Get.snackbar(
        'Lỗi',
        'Không thể mở ứng dụng gọi điện',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tracingList = controller.tracingList;

      UserJoinGeoMap? user;

      if (tracingList?.geoMapTracing != null &&
          tracingList!.geoMapTracing!.isNotEmpty) {
        final firstTracing = tracingList.geoMapTracing!.first;
        user = UserJoinGeoMap(
          name: firstTracing.name,
          userId: firstTracing.uuid,
          linkAvatar: firstTracing.imageLink,
          plate: firstTracing.extraData?.plate,
          phone: firstTracing.extraData?.phone,
          address: firstTracing.extraData?.address,
        );
      } else if (tracingList?.geoMap?.userJoinGeoMap != null &&
          tracingList!.geoMap!.userJoinGeoMap!.isNotEmpty) {
        final relevantUsers = tracingList.geoMap!.userJoinGeoMap!
            .where((u) => controller.userUuids.contains(u.userId))
            .toList();
        if (relevantUsers.isNotEmpty) {
          user = relevantUsers.first;
        }
      }

      // Apply model overrides on top of resolved user data
      final hasModel = driverInfoCardModel != null;
      final title = driverInfoCardModel?.title ?? 'Người tham gia (1)';
      final driverName =
          driverInfoCardModel?.driverName ?? user?.name ?? 'Tài xế';
      final plate = driverInfoCardModel?.plate ?? user?.plate;
      final avatarUrl = driverInfoCardModel?.avatarUrl ?? user?.linkAvatar;
      final phone = driverInfoCardModel?.phone ?? user?.phone;
      final description = driverInfoCardModel?.description;

      // If no model override and no resolved user, hide the card
      if (!hasModel && user == null) return const SizedBox.shrink();

      return CardContainer(
        child: SelectionArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: fontConfig.subtitleStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Avatar – tap to move camera to driver's last location
                  Tooltip(
                    message: 'Xem vị trí',
                    child: GestureDetector(
                      onTap: () => controller.moveToDriverLastLocation(),
                      child: ClipOval(
                        child: avatarUrl != null
                            ? Image.network(
                                avatarUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.person, size: 40),
                              )
                            : const Icon(Icons.person, size: 40),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(driverName,
                            style: fontConfig.bodyStyle(
                                fontWeight: FontWeight.bold)),
                        if (plate != null)
                          Text(plate,
                              style: fontConfig.bodyStyle(
                                  color: const Color(0xff1E293B), fontSize: 12))
                        else
                          Text('Chưa có biển số',
                              style: fontConfig.bodyStyle(
                                  color: const Color(0xff1E293B),
                                  fontSize: 12)),
                        if (phone != null)
                          // Phone row: tapped programmatically so excluded from SelectionArea via ExcludeSemantics
                          GestureDetector(
                            onTap: () => _handlePhonePress(phone),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.phone,
                                    size: 12, color: Colors.green[700]),
                                const SizedBox(width: 3),
                                Text(
                                  phone,
                                  style: fontConfig.bodyStyle(
                                    color: Colors.green[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description,
                  style: fontConfig.bodyStyle(
                      color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

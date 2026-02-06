import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../geomap_controller.dart';
import '../../models/font_config.dart';
import '../../models/map_geo_model.dart';
import 'card_container.dart';

class GeoMapDriverInfoCard extends StatelessWidget {
  final GeoMapController controller;
  final FontConfig fontConfig;

  const GeoMapDriverInfoCard({
    super.key,
    required this.controller,
    required this.fontConfig,
  });

  void _handlePhonePress(BuildContext context, String phone) {
    if (kIsWeb) {
      // Web: Show dialog with copy button
      _showPhoneDialog(context, phone);
    } else {
      // Mobile: Launch phone dialer
      _launchPhoneCall(phone);
    }
  }


  void _showPhoneDialog(BuildContext context, String phone) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.phone, color: Colors.green[700]),
              const SizedBox(width: 8),
              const Text('Số điện thoại'),
            ],
          ),
          content: Container(
            constraints: const BoxConstraints(minWidth: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SelectableText(
                          phone,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: phone));
                          Get.snackbar(
                            'Đã sao chép',
                            'Số điện thoại đã được sao chép',
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.green[700],
                            colorText: Colors.white,
                          );
                        },
                        tooltip: 'Sao chép',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
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

      if (tracingList?.geoMapTracing != null && tracingList!.geoMapTracing!.isNotEmpty) {
        final firstTracing = tracingList.geoMapTracing!.first;
        user = UserJoinGeoMap(
          name: firstTracing.name,
          userId: firstTracing.uuid,
          linkAvatar: firstTracing.imageLink,
          plate: firstTracing.extraData?.plate,
          phone: firstTracing.extraData?.phone,
          address: firstTracing.extraData?.address,
        );

      } else if (tracingList?.geoMap?.userJoinGeoMap != null && tracingList!.geoMap!.userJoinGeoMap!.isNotEmpty) {
         // Filter for relevant user if needed, or take first
         final relevantUsers = tracingList.geoMap!.userJoinGeoMap!.where((u) => controller.userUuids.contains(u.userId)).toList();
         if (relevantUsers.isNotEmpty) {
           user = relevantUsers.first;
         }
      }

      if (user == null) {
        return
          const SizedBox.shrink();
        //   CardContainer(
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Text(
        //         "Người tham gia (0)",
        //         style: fontConfig.subtitleStyle(fontWeight: FontWeight.bold)
        //       ),
        //       const SizedBox(height: 12),
        //       Row(
        //         children: [
        //           Container(
        //             padding: const EdgeInsets.all(12),
        //             decoration: BoxDecoration(
        //               color: Colors.grey[100],
        //               shape: BoxShape.circle,
        //             ),
        //             child: Icon(Icons.person_off, color: Colors.grey[400], size: 24),
        //           ),
        //           const SizedBox(width: 12),
        //           Expanded(
        //             child: Text(
        //               'no_driver'.tr,
        //               style: fontConfig.bodyStyle(color: Colors.grey[600]),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // );
      }

      return CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Người tham gia (1)", style: fontConfig.subtitleStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                ClipOval(
                  child: user.linkAvatar != null
                      ? Image.network(
                          user.linkAvatar!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, size: 40),
                        )
                      : const Icon(Icons.person, size: 40),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name ?? "Tài xế", style: fontConfig.bodyStyle(fontWeight: FontWeight.bold)),
                      if (user.plate != null)
                        Text(user.plate!, style: fontConfig.bodyStyle(color: Color(0xff1E293B), fontSize: 12))
                      else
                        Text("Chưa có biển số", style: fontConfig.bodyStyle(color: Color(0xff1E293B), fontSize: 12)),
                      // if (user.address != null)
                      //   Text(user.address!, style: fontConfig.bodyStyle(color: Color(0xff1E293B) ,fontSize: 12))
                      // else
                      //   Text("Chưa có dữ liệu vị trí", style: fontConfig.bodyStyle(color: Color(0xff1E293B), fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.phone, color: Colors.black87, size: 20),
                    onPressed: user.phone != null ? () => _handlePhonePress(context, user!.phone!) : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

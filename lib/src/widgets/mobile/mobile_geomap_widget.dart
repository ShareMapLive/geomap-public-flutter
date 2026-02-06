import 'package:flutter/material.dart';
import 'package:geomap_package/geomap_package.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../base/base_geomap_widget.dart';
import '../shared_geomap_components.dart';

/// Mobile-specific geomap widget with UI optimized for mobile devices
class MobileGeoMapWidget extends StatelessWidget {
  final GeoMapController controller;
  final String geoMapCode;
  final VoidCallback? onMapCreated;
  final bool myLocationEnabled;
  final bool zoomControlsEnabled;
  final bool myLocationButtonEnabled;
  final bool compassEnabled;
  final bool mapToolbarEnabled;
  final bool showCloseButton;
  final VoidCallback? onClosePressed;
  final VoidCallback? onReloadPressed;
  final Function(bool isExpanded)? onToggleSheetPressed;
  final Function(dynamic stop)? onStopItemPressed;
  final Function(String url)? onCopyPressed;

  const MobileGeoMapWidget({
    super.key,
    required this.controller,
    required this.geoMapCode,
    this.onMapCreated,
    this.myLocationEnabled = true,
    this.zoomControlsEnabled = false,
    this.myLocationButtonEnabled = true,
    this.compassEnabled = false,
    this.mapToolbarEnabled = false,
    this.showCloseButton = false,
    this.onClosePressed,
    this.onReloadPressed,
    this.onToggleSheetPressed,
    this.onStopItemPressed,
    this.onCopyPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Gọi load dữ liệu ngay sau khi widget được dựng xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getAllData(geoMapCode);
    });

    return Stack(
      children: [
        BaseGeoMapWidget(
          controller: controller,
          onMapCreated: onMapCreated,
          myLocationEnabled: myLocationEnabled,
          zoomControlsEnabled: zoomControlsEnabled,
          myLocationButtonEnabled: myLocationButtonEnabled,
          compassEnabled: compassEnabled,
          mapToolbarEnabled: mapToolbarEnabled,
        ),

        // Combined Status Card and Expandable Content
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 0,
          right: 0,
          child: Obx(() {
            final isExpanded = controller.isSheetExpanded.value;

            return PointerInterceptor(
              child: Column(
                children: [
                  // Status Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: GeoMapStatusCard(
                      controller: controller,
                      geoMapCode: geoMapCode,
                      fontConfig: controller.config.fontConfig,
                      showCloseButton: showCloseButton,
                      onClosePressed: onClosePressed,
                      onReloadPressed: onReloadPressed,
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    constraints: BoxConstraints(
                      maxHeight: isExpanded
                          ? MediaQuery.of(context).size.height * 0.8
                          : 50,
                    ),
                    decoration: BoxDecoration(
                      // color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Expand/Collapse Button
                        InkWell(
                          onTap: () {
                            controller.toggleSheet();
                            onToggleSheetPressed?.call(controller.isSheetExpanded.value);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                            borderRadius: BorderRadius.circular(8)
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isExpanded ? 'Thu gọn' : 'Xem thêm',
                                  style: controller.config.fontConfig.bodyStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Expandable Content
                        if (isExpanded)
                          Flexible(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 12),
                              child: Column(
                                children: [
                                  if (controller.config.role == GeoMapRole.viewer)
                                    GeoMapDriverInfoCard(
                                      controller: controller,
                                      fontConfig: controller.config.fontConfig,
                                    ),
                                  GeoMapInfoCard(
                                    controller: controller,
                                    fontConfig: controller.config.fontConfig,
                                  ),
                                  GeoMapStopList(
                                    controller: controller,
                                    fontConfig: controller.config.fontConfig,
                                    onStopItemPressed: onStopItemPressed,
                                  ),
                                  GeoMapLinkCard(
                                    url: controller.getPublicGeoMapUrl(geoMapCode),
                                    fontConfig: controller.config.fontConfig,
                                    onCopyPressed: onCopyPressed,
                                  ),
                                  const SizedBox(height: 50,)
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:geomap_package/geomap_package.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../base/base_geomap_widget.dart';
import '../shared_geomap_components.dart';

/// Web-specific geomap widget with UI optimized for web browsers
class WebGeoMapWidget extends StatelessWidget {
  /// The controller managing the map state
  final GeoMapController controller;

  /// The unique code identifying the geomap
  final String geoMapCode;

  /// Callback when the map is created
  final VoidCallback? onMapCreated;

  /// Whether to show the user's current location
  final bool myLocationEnabled;

  /// Whether to show zoom controls
  final bool zoomControlsEnabled;

  /// Whether to enable rotate gestures
  final bool rotateGesturesEnabled;

  /// Whether to show the close button
  final bool showCloseButton;

  /// Callback when the close button is pressed
  final VoidCallback? onClosePressed;

  /// Callback when the reload button is pressed
  final VoidCallback? onReloadPressed;

  /// Callback when the sheet is toggled (expanded/collapsed)
  final Function(bool isExpanded)? onToggleSheetPressed;

  /// Callback when a stop item is pressed
  final Function(dynamic stop)? onStopItemPressed;

  /// Callback when the copy link button is pressed
  final Function(String url)? onCopyPressed;

  /// Whether to show the button that centers the map on the user's location
  final bool myLocationButtonEnabled;

  /// Whether to show the compass button
  final bool compassEnabled;

  /// Whether to show the map toolbar
  final bool mapToolbarEnabled;

  /// Creates a new [WebGeoMapWidget] instance
  const WebGeoMapWidget({
    super.key,
    required this.controller,
    required this.geoMapCode,
    this.onMapCreated,
    this.myLocationEnabled = true,
    this.zoomControlsEnabled = false,
    this.rotateGesturesEnabled = false,
    this.showCloseButton = false,
    this.onClosePressed,
    this.onReloadPressed,
    this.onToggleSheetPressed,
    this.onStopItemPressed,
    this.onCopyPressed,
    this.myLocationButtonEnabled = true,
    this.compassEnabled = false,
    this.mapToolbarEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    // Gọi load dữ liệu ngay sau khi widget được dựng xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getAllData(geoMapCode);
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 650;

        return Stack(
          children: [
            // Map chiếm toàn bộ
            Positioned.fill(
              child: BaseGeoMapWidget(
                controller: controller,
                onMapCreated: onMapCreated,
                myLocationEnabled: myLocationEnabled,
                myLocationButtonEnabled: myLocationButtonEnabled,
                zoomControlsEnabled: zoomControlsEnabled,
                compassEnabled: compassEnabled,
                mapToolbarEnabled: mapToolbarEnabled,
                rotateGesturesEnabled: rotateGesturesEnabled,
              ),
            ),

            if (isMobile)
              _buildMobileOverlay(context, constraints)
            else
              _buildDesktopOverlay(context),
          ],
        );
      },
    );
  }

  Widget _buildMobileOverlay(BuildContext context, BoxConstraints constraints) {
    return Positioned(
      top: 16, // Web usually doesn't have status bar padding
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
                  centerReload: true,
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
                      ? constraints.maxHeight * 0.8
                      : 50,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),

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
                          borderRadius: BorderRadius.circular(8),
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
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
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
                              const SizedBox(height: 50),
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
    );
  }

  Widget _buildDesktopOverlay(BuildContext context) {
      return Positioned(
        top: 16,
        left: 16,
        bottom: 16,
        width: 360,
        child: PointerInterceptor(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GeoMapStatusCard(
                        controller: controller,
                        geoMapCode: geoMapCode,
                        fontConfig: controller.config.fontConfig,
                        showCloseButton: showCloseButton,
                        onClosePressed: onClosePressed,
                        onReloadPressed: onReloadPressed,
                      ),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';

import 'geomap_controller.dart';
import 'models/geomap_driver_info_card_model.dart';
import 'models/geomap_info_card_model.dart';
import 'widgets/mobile/mobile_geomap_widget.dart';
import 'widgets/web/web_geomap_widget.dart';

/// A universal geomap widget that works on both mobile and web platforms
///
/// Automatically selects the appropriate platform-specific widget based on:
/// - Platform (mobile vs web)
class GeoMapPublic extends StatelessWidget {
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

  /// Whether to show the my location button
  final bool myLocationButtonEnabled;

  /// Whether to show the compass button
  final bool compassEnabled;

  /// Whether to show the map toolbar
  final bool mapToolbarEnabled;

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

  /// Optional model to override fields displayed in [GeoMapInfoCard].
  final GeomapInfoCardModel? infoCardModel;

  /// Optional model to override fields displayed in [GeoMapDriverInfoCard].
  final GeomapDriverInfoCardModel? driverInfoCardModel;

  /// Creates a new [GeoMapPublic] instance
  ///
  /// [controller] is required and manages the map state
  const GeoMapPublic({
    super.key,
    required this.controller,
    required this.geoMapCode,
    this.onMapCreated,
    this.myLocationEnabled = true,
    this.myLocationButtonEnabled = true,
    this.zoomControlsEnabled = false,
    this.compassEnabled = false,
    this.mapToolbarEnabled = false,
    this.showCloseButton = false,
    this.onClosePressed,
    this.onReloadPressed,
    this.onToggleSheetPressed,
    this.onStopItemPressed,
    this.onCopyPressed,
    this.infoCardModel,
    this.driverInfoCardModel,
  });

  @override
  Widget build(BuildContext context) {
    Widget mapWidget;
    // Automatically select widget based on platform
    if (kIsWeb) {
      mapWidget = WebGeoMapWidget(
        controller: controller,
        geoMapCode: geoMapCode,
        onMapCreated: onMapCreated,
        myLocationEnabled: myLocationEnabled,
        zoomControlsEnabled: zoomControlsEnabled,
        myLocationButtonEnabled: myLocationButtonEnabled,
        compassEnabled: compassEnabled,
        mapToolbarEnabled: mapToolbarEnabled,
        showCloseButton: showCloseButton,
        onClosePressed: onClosePressed,
        onReloadPressed: onReloadPressed,
        onToggleSheetPressed: onToggleSheetPressed,
        onStopItemPressed: onStopItemPressed,
        onCopyPressed: onCopyPressed,
        infoCardModel: infoCardModel,
        driverInfoCardModel: driverInfoCardModel,
      );
    } else {
      mapWidget = MobileGeoMapWidget(
        controller: controller,
        geoMapCode: geoMapCode,
        onMapCreated: onMapCreated,
        myLocationEnabled: myLocationEnabled,
        zoomControlsEnabled: zoomControlsEnabled,
        myLocationButtonEnabled: myLocationButtonEnabled,
        compassEnabled: compassEnabled,
        mapToolbarEnabled: mapToolbarEnabled,
        showCloseButton: showCloseButton,
        onClosePressed: onClosePressed,
        onReloadPressed: onReloadPressed,
        onToggleSheetPressed: onToggleSheetPressed,
        onStopItemPressed: onStopItemPressed,
        onCopyPressed: onCopyPressed,
        infoCardModel: infoCardModel,
        driverInfoCardModel: driverInfoCardModel,
      );
    }

    return Stack(
      children: [
        mapWidget,
        // Version info overlay
        Positioned(
          bottom: 4,
          left: 80,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black12, width: 0.5),
            ),
            child: Obx(() => Text(
                  'v${GeoMapController.version}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black.withOpacity(0.4),
                    fontWeight: FontWeight.w500,
                  ),
                )),
          ),
        ),
      ],
    );
  }
}

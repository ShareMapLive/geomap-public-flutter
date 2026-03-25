import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../geomap_controller.dart';
import '../../models/font_config.dart';
import '../../models/geomap_info_card_model.dart';
import 'card_container.dart';

class GeoMapInfoCard extends StatelessWidget {
  final GeoMapController controller;
  final FontConfig fontConfig;

  /// Optional model to override the card display values.
  /// When a field in [infoCardModel] is non-null it replaces the default
  /// value resolved from the controller/API.
  final GeomapInfoCardModel? infoCardModel;

  const GeoMapInfoCard({
    super.key,
    required this.controller,
    required this.fontConfig,
    this.infoCardModel,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mapDetail = controller.mapGeoDetail;
      if (mapDetail == null) return const SizedBox.shrink();

      final title = infoCardModel?.title ?? 'Bản đồ';
      final mapName = infoCardModel?.mapName ?? mapDetail.description ?? '-';
      final mapCode = infoCardModel?.mapCode ?? mapDetail.geoMapCode ?? '-';
      final dateDisplay =
          infoCardModel?.dateDisplay ?? controller.jwtDateFormatted;

      return CardContainer(
        child: SelectionArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: fontConfig.subtitleStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildRow(infoCardModel?.mapNameLabel ?? 'Tên bản đồ', mapName,
                  fontConfig),
              if (infoCardModel?.description != null)
                _buildRow(infoCardModel?.descriptionLabel ?? 'Mô tả',
                    infoCardModel!.description!, fontConfig),
              _buildRow(infoCardModel?.mapCodeLabel ?? 'Mã bản đồ', mapCode,
                  fontConfig) ,
              _buildRow(infoCardModel?.dateDisplayLabel ?? 'Ngày', dateDisplay,
                  fontConfig),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildRow(String label, String value, FontConfig fontConfig) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: fontConfig.bodyStyle(color: Colors.grey[600])),
          Expanded(
            child: Text(
              value,
              style: fontConfig.bodyStyle(fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../geomap_controller.dart';
import '../../models/font_config.dart';
import 'card_container.dart';

class GeoMapInfoCard extends StatelessWidget {
  final GeoMapController controller;
  final FontConfig fontConfig;

  const GeoMapInfoCard({
    super.key,
    required this.controller,
    required this.fontConfig,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mapDetail = controller.mapGeoDetail;
      if (mapDetail == null) return const SizedBox.shrink();

      return CardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("GeoMap", style: fontConfig.subtitleStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildRow("Tên", mapDetail.name ?? "-", fontConfig),
            _buildRow("Mã", mapDetail.geoMapCode ?? "-", fontConfig),
            _buildRow("Loại", mapDetail.type ?? "-", fontConfig),
            _buildRow("Bán kính", "${mapDetail.radius ?? '-'}m", fontConfig),
            _buildRow("Ngày dữ liệu", controller.jwtDateFormatted, fontConfig),
          ],
        ),
      );
    });
  }

  Widget _buildRow(String label, String value, FontConfig fontConfig) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: fontConfig.bodyStyle(color: Colors.grey[600])),
          SelectableText(value, style: fontConfig.bodyStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/font_config.dart';
import 'card_container.dart';

class GeoMapLinkCard extends StatelessWidget {
  final String url;
  final FontConfig fontConfig;
  final Function(String url)? onCopyPressed;

  const GeoMapLinkCard({
    super.key,
    required this.url,
    required this.fontConfig,
    this.onCopyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              url,
              style: fontConfig.bodyStyle(color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã sao chép liên kết')),
              );
              onCopyPressed?.call(url);
            },
            child: const Icon(Icons.copy, size: 20, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

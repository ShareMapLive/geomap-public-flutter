import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class EmojiFontLoader {
  static bool _loaded = false;
  static bool _loading = false;

  static Future<void> ensureLoaded() async {
    if (_loaded) return;
    if (_loading) {
      while (_loading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }
    _loading = true;

    try {
      final fontLoader = FontLoader('NotoColorEmoji');

      // 1. Try loading from CDN first
      try {
        final response = await http.get(Uri.parse('https://cdn.sharemap.live/public/fonts/NotoColorEmoji-Regular.ttf'));
        if (response.statusCode == 200) {
          fontLoader.addFont(Future.value(ByteData.sublistView(response.bodyBytes)));
          await fontLoader.load();
          _loaded = true;
          debugPrint('NotoColorEmoji loaded successfully from CDN.');
          return;
        } else {
          debugPrint('Failed to load NotoColorEmoji from CDN, response status: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Failed to load NotoColorEmoji from CDN: $e');
      }

      // 2. Fallback to asset in bundle
      try {
        final byteData = await rootBundle.load('packages/geomap_package/assets/fonts/NotoColorEmoji-Regular.ttf');
        fontLoader.addFont(Future.value(byteData));
        await fontLoader.load();
        _loaded = true;
        debugPrint('NotoColorEmoji loaded successfully from assets.');
      } catch (e) {
        debugPrint('Failed to load NotoColorEmoji from assets: $e');
      }
    } finally {
      _loading = false;
    }
  }
}

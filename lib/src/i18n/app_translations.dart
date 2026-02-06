import 'package:get/get.dart';
import 'en.dart';
import 'vi.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'vi': viTranslations,
        'en': enTranslations,
      };
}

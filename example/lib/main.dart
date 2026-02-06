import 'package:flutter/material.dart';
import 'package:geomap_package/geomap_package.dart';
import 'package:get/get.dart';

/// =============================================================================
/// GEOMAP PACKAGE EXAMPLE
/// =============================================================================
///
/// To use this package, you need to obtain API credentials from ShareMap.
///
/// Please visit: https://business.sharemap.live
///
/// After registration, you will receive:
/// - apiKey: JWT token for API authentication
/// - routeServiceKey: Service key for route API requests
/// - geoMapCode: Your geomap code
///
/// Replace the placeholder values below with your actual credentials.
/// =============================================================================

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Geomap Package Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      translations: AppTranslations(),
      locale: const Locale('vi'),
      fallbackLocale: const Locale('en'),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // =========================================================================
    // CONFIGURATION - Replace with your credentials from business.sharemap.live
    // =========================================================================
    const config = GeoMapConfig(
      apiKey: 'YOUR_API_KEY', // Get from business.sharemap.live
      routeServiceKey: 'YOUR_ROUTE_SERVICE_KEY', // Get from business.sharemap.live
      mapType: GeoMapType.flutterMap,
      environment: Environment.development,
      role: GeoMapRole.driver,
    );

    // Your geomap code - Get from business.sharemap.live
    const String geoMapCode = 'YOUR_GEOMAP_CODE';

    final controller = Get.put(GeoMapController(config: config));

    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoMap Example'),
      ),
      body: GeoMapPublic(
        geoMapCode: geoMapCode,
        controller: controller,
        onMapCreated: () {
          print('Map created successfully');
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        showCloseButton: true,
        onClosePressed: () {
          controller.collapseSheet();
        },
      ),
    );
  }
}

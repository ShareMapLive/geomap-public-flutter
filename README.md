# Geomap Package

A Flutter package for displaying geomaps with Google Maps and Flutter Map, supporting both mobile and web platforms with GetX state management.

## Features

- 🗺️ Universal map widget that works on both mobile and web
- 🔄 Support for both Google Maps and Flutter Map on all platforms
- 👤 Role-based views: `viewer` (full features) and `driver` (simplified view)
- 📍 Display markers, circles, polygons, and polylines
- 🔗 Close button callback for WebView integration
- 🎨 Customizable font configuration
- 🔧 Custom API base URLs for development and production

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  geomap_package: ^1.0.0
```

Then run:
```bash
flutter pub get
```

---

## Quick Start

```dart
import 'package:geomap_package/geomap_package.dart';

// 1. Create configuration
final config = GeoMapConfig(
  apiKey: 'your_jwt_token_from_business_sharemap_live',
  mapType: GeoMapType.flutterMap, // or GeoMapType.googleMap
  environment: Environment.production,
  role: GeoMapRole.viewer,
);

// 2. Create controller
final controller = GeoMapController(config: config);

// 3. Use the widget
GeoMapPublic(
  controller: controller,
  geoMapCode: 'your_geomap_code',
  showCloseButton: true,
  onClosePressed: () {
    print('Close button pressed');
  },
)
```

---

## Platform Configuration

### FlutterMap (Recommended)

**No configuration needed!** FlutterMap uses OpenStreetMap tiles which are free and don't require any API keys.

```dart
final config = GeoMapConfig(
  apiKey: 'your_jwt_token',
  mapType: GeoMapType.flutterMap, // ✅ No extra setup needed
);
```

### Google Maps

If you choose `GeoMapType.googleMap`, you must configure Google Maps SDK for each platform:

#### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
  <application ...>
    <meta-data 
      android:name="com.google.android.geo.API_KEY"
      android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
  </application>
</manifest>
```

#### iOS

Add to `ios/Runner/AppDelegate.swift`:

```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

#### Web

Add to `web/index.html` before the closing `</head>` tag:

```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_GOOGLE_MAPS_API_KEY"></script>
```

> 📖 For complete setup instructions, see [google_maps_flutter documentation](https://pub.dev/packages/google_maps_flutter).

---

## Web Testing

> ⚠️ **Important**: Use port 8080 for local web testing to work properly with ShareMap API.

```bash
# Run on Chrome with port 8080
flutter run -d chrome --web-port=8080

# For HTTPS testing (required for geolocation)
ngrok http 8080
```

---

## FlutterMap vs GoogleMap

| Feature | FlutterMap | GoogleMap |
|---------|------------|-----------|
| **Cost** | ✅ Free (OpenStreetMap) | 💰 Requires Google billing |
| **Setup Required** | ✅ None | ⚙️ Must configure per platform |
| **API Key Required** | ✅ No | 🔑 Yes |
| **Web Support** | ✅ Full | ✅ Full |
| **Mobile Support** | ✅ Full | ✅ Full |
| **Tile Provider** | OpenStreetMap | Google Maps |

> 💡 **Recommendation**: Use `GeoMapType.flutterMap` for quick setup. Use `GeoMapType.googleMap` only if you specifically need Google Maps features.

---

## Configuration Reference

### GeoMapConfig

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `apiKey` | `String` | ✅ | - | JWT token from [business.sharemap.live](https://business.sharemap.live). **Required for all maps** - used to call ShareMap API. |
| `routeServiceKey` | `String?` | ❌ | `null` | API key for route drawing. Used to call route API to render polylines on map. |
| `mapType` | `GeoMapType` | ✅ | - | `GeoMapType.flutterMap` (free) or `GeoMapType.googleMap` (requires setup) |
| `environment` | `Environment` | ❌ | `production` | `Environment.production` or `Environment.development` |
| `role` | `GeoMapRole` | ❌ | `viewer` | `GeoMapRole.viewer` (full UI) or `GeoMapRole.driver` (minimal UI) |
| `fontConfig` | `FontConfig` | ❌ | default | Custom font family and sizes |
| `devApiUrl` | `String?` | ❌ | `null` | Override development API base URL |
| `prodApiUrl` | `String?` | ❌ | `null` | Override production API base URL |

### GeoMapPublic Widget

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `controller` | `GeoMapController` | ✅ | - | Controller created with `GeoMapConfig` |
| `geoMapCode` | `String` | ✅ | - | GeoMap code from [business.sharemap.live](https://business.sharemap.live) → GeoMap → Select GeoMap → Copy code |
| `onMapCreated` | `VoidCallback?` | ❌ | `null` | Callback when map is initialized |
| `myLocationEnabled` | `bool` | ❌ | `true` | Show user's current location marker |
| `zoomControlsEnabled` | `bool` | ❌ | `false` | Show zoom +/- buttons |
| `myLocationButtonEnabled` | `bool` | ❌ | `true` | Show button to center on user location |
| `compassEnabled` | `bool` | ❌ | `false` | Show compass indicator |
| `mapToolbarEnabled` | `bool` | ❌ | `false` | Show map toolbar |
| `showCloseButton` | `bool` | ❌ | `false` | Show close button (for WebView/iframe) |
| `onClosePressed` | `VoidCallback?` | ❌ | `null` | Callback when close button pressed |
| `onReloadPressed` | `VoidCallback?` | ❌ | `null` | Callback when reload button pressed |
| `onToggleSheetPressed` | `Function(bool)?` | ❌ | `null` | Callback when info panel expanded/collapsed |
| `onStopItemPressed` | `Function(dynamic)?` | ❌ | `null` | Callback when user taps a stop |
| `onCopyPressed` | `Function(String)?` | ❌ | `null` | Callback when copy link button pressed |

### FontConfig

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `mobileFontFamily` | `String` | `'RobotoRegular'` | Font family for mobile |
| `webFontFamily` | `String` | `'PoppinsRegular'` | Font family for web |
| `titleFontSize` | `double` | `18.0` | Title text size |
| `subtitleFontSize` | `double` | `16.0` | Subtitle text size |
| `bodyFontSize` | `double` | `14.0` | Body text size |
| `boldFontWeight` | `FontWeight` | `FontWeight.bold` | Bold text weight |
| `regularFontWeight` | `FontWeight` | `FontWeight.normal` | Regular text weight |

---

## Role-Based Views

### Viewer Mode (default)
- Full access to all UI components
- Driver info card with location history
- Auto-refresh timer for real-time updates
- Check-in markers displayed

### Driver Mode
- Simplified view for drivers
- Only shows route and stops
- No driver history or auto-refresh
- Filtered data to show only current driver

```dart
// Viewer mode (default)
final config = GeoMapConfig(
  apiKey: 'token',
  mapType: GeoMapType.flutterMap,
  role: GeoMapRole.viewer,
);

// Driver mode
final config = GeoMapConfig(
  apiKey: 'token',
  mapType: GeoMapType.flutterMap,
  role: GeoMapRole.driver,
);
```

---

## Controller Methods

### Data Loading

```dart
// Load all data for a geomap
await controller.loadAllData('geomap_code');

// Refresh current data
await controller.loadDataInSequence();

// Update geomap code (triggers reload)
controller.updateGeoMapCode('new_code');
```

### UI Control

```dart
// Toggle expandable sheet
controller.toggleSheet();

// Expand/collapse sheet programmatically
controller.expandSheet();
controller.collapseSheet();

// Move camera to specific location
controller.moveCameraTo(lat: 10.762622, lng: 106.660172, zoomLevel: 15);
```

### Accessing Data

```dart
// Map info
final mapDetail = controller.mapGeoDetail;
final stopList = controller.publicGeofencingList;
final publicUrl = controller.publicGeoMapUrl;

// Loading state
final isLoading = controller.isLoadingData;
final isReady = controller.isMapReady;
```

---

## Permissions

### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to show your position on the map</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs location access to track your position</string>
```

---

## WebView Integration

When embedding this package in a WebView, use the close button callback to communicate with the host application:

```dart
GeoMapPublic(
  controller: controller,
  geoMapCode: 'CODE',
  showCloseButton: true,
  onClosePressed: () {
    // Option 1: JavaScript Channel (Mobile WebView)
    // js.context.callMethod('postMessage', ['GEOMAP_CLOSE']);
    
    // Option 2: URL Scheme
    // launchUrl(Uri.parse('sharemap://close'));
    
    // Option 3: Parent Frame Message (iframe)
    // html.window.parent?.postMessage('GEOMAP_CLOSE', '*');
  },
)
```

---

## Custom API URLs

Override default API endpoints for different environments:

```dart
final config = GeoMapConfig(
  apiKey: 'token',
  mapType: GeoMapType.flutterMap,
  environment: Environment.development,
  devApiUrl: 'https://my-dev-api.com',
  prodApiUrl: 'https://my-prod-api.com',
);
```

---

## License

MIT
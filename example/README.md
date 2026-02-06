# Geomap Package Example

This is an example Flutter application demonstrating how to use the geomap_package.

## Getting Started

This example shows how to integrate and use the geomap_package in a Flutter application.

### Prerequisites

1. Make sure you have Flutter installed
2. The geomap_package is already included as a local dependency

### Running the Example

1. Navigate to the example directory:
   ```bash
   cd geomap_package/example
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Configuration Fields Explanation

The example app is configured with the following settings in `lib/main.dart`:

```dart
final config = GeoMapConfig(
  geoMapCode: 'GM_POLYGON_1TAIXE_197B03F404D',
  apiKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJsaXN0VXVpZCI6WyJWSVRMRW4wNEZsaExaTEFseHRkVlB4MmZLeUczIl0sImRhdGUiOiIxNzYzMDA5ODAyNDgzIiwiaWF0IjoxNzYzMDA5ODE5LCJleHAiOjE3NjMwOTYyMTl9.vO5bmdxn0O6MvOKySPh0Zhr4PPxB6snugfs5CujsO8c",
  mapType: GeoMapType.flutterMap,
  environment: Environment.development,
);
```

**Giải thích các trường cấu hình:**

- `geoMapCode`: Mã của geomap dùng để tải dữ liệu bản đồ từ server
- `apiKey`: Key để xác thực và gọi các API, được cung cấp bởi sharemap
- `mapType`: Loại bản đồ sử dụng:
  - `GeoMapType.googleMap`: Sử dụng Google Maps (yêu cầu cấu hình API key)
  - `GeoMapType.flutterMap`: Sử dụng Flutter Map (không yêu cầu API key)
- `environment`: Môi trường chạy ứng dụng:
  - `Environment.development`: Môi trường phát triển
  - `Environment.production`: Môi trường sản xuất

### Cấu hình Google Maps cho iOS

Để sử dụng Google Maps trên iOS, bạn cần thực hiện các bước sau:

1. **Tạo Google Maps API Key**:
   - Truy cập [Google Cloud Console](https://console.cloud.google.com/)
   - Tạo project mới hoặc chọn project hiện có
   - Enable Google Maps SDK for iOS
   - Tạo API Key trong phần Credentials

2. **Cấu hình trong ứng dụng**:
   - Mở file `ios/Runner/AppDelegate.swift`
   - Thêm import statement ở đầu file:
   ```swift
   import GoogleMaps
   ```
   - Thêm dòng sau vào hàm `application`:
   ```swift
   GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
   ```

3. **Cấu hình quyền truy cập**:
   - Mở file `ios/Runner/Info.plist`
   - Thêm các quyền sau nếu chưa có:
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>Vị trí được sử dụng để hiển thị bản đồ</string>
   <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
   <string>Vị trí được sử dụng để hiển thị bản đồ</string>
   ```

Chi tiết hơn có thể tham khảo tại: [Google Maps Flutter Package](https://pub.dev/packages/google_maps_flutter)

### Cấu hình Google Maps cho Android

Để sử dụng Google Maps trên Android, bạn cần thực hiện các bước sau:

1. **Tạo Google Maps API Key**:
   - Truy cập [Google Cloud Console](https://console.cloud.google.com/)
   - Tạo project mới hoặc chọn project hiện có
   - Enable Google Maps SDK for Android
   - Tạo API Key trong phần Credentials

2. **Cấu hình trong ứng dụng**:
   - Mở file `android/app/src/main/AndroidManifest.xml`
   - Thêm meta-data API key bên trong thẻ `<application>`:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
   ```

3. **Thêm dependency** (nếu chưa có):
   - Mở file `pubspec.yaml`
   - Đảm bảo có dependency: `google_maps_flutter: ^x.x.x`

Chi tiết hơn có thể tham khảo tại: [Google Maps Flutter Package](https://pub.dev/packages/google_maps_flutter)

### Cấu hình Google Maps cho Web

Để sử dụng Google Maps trên Web, bạn cần thực hiện các bước sau:

1. **Tạo Google Maps API Key** (nếu chưa có):
   - Truy cập [Google Cloud Console](https://console.cloud.google.com/)
   - Tạo project mới hoặc chọn project hiện có
   - Enable Google Maps JavaScript API
   - Tạo API Key trong phần Credentials

2. **Cấu hình trong ứng dụng**:
   - Mở file `web/index.html`
   - Thêm script sau vào phần `<head>`:
   ```html
   <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_GOOGLE_MAPS_API_KEY"></script>
   ```

Chi tiết hơn có thể tham khảo tại: [Google Maps JavaScript API](https://developers.google.com/maps/documentation/javascript/overview)

### Features Demonstrated

	•	Tích hợp bản đồ cơ bản
	•	Tải dữ liệu GeoMap
	•	Hiển thị marker và polygon geofencing
	•	Theo dõi và truy vết người dùng
	•	Hỗ trợ đa nền tảng (mobile và web)
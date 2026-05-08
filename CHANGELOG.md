## 2.1.0

### Added
* **UI Customization**: Thêm `infoCardModel` và `driverInfoCardModel` vào `GeoMapPublic` cho phép tùy chỉnh thông tin hiển thị trên các thẻ.
* **Multi-day Tracking**: Hỗ trợ chọn xem lịch sử di chuyển theo từng ngày thông qua dropdown mới.
* **Enhanced Data Models**: Bổ sung các thông tin `address`, `time`, `plate`, và `phone` cho model `UserJoinGeoMap`.
* **Extended Map Features**: Thêm hỗ trợ cho các trường dữ liệu mới trong `MapGeoModel` như `isReturn`, `totalGeofencing`, và `listDetectTracing`.

### Improved
* **New Design**: Cập nhật giao diện mới hiện đại hơn cho toàn bộ gói GeoMap trên cả Mobile và Web.
* **Marker Rendering**: Cải thiện hiệu suất và cách hiển thị marker trên bản đồ.
* **UI Components**: Thiết kế lại các thành phần `GeoMapDriverInfoCard`, `GeoMapStatusCard` và `GeoMapCollapsedTimeline`.
* **API Handling**: Tối ưu hóa việc gọi API tracking thông qua `datasetCode` ổn định hơn.

## 2.0.0

### BREAKING CHANGES
* **New Tracking Engine**: Migrated completely to the Dataset Tracking API for improved accuracy and reliability.
* **Response Format Change**: Replaced `geoMapTracing` key with `DatasetTracking` in API responses.
* **Model Cleanup**: Removed deprecated fields (`listConfigurationAPI`, `expiredTime`, `key`, `value`, `automaticRunTime`) from `TrackingVehicleConfiguration`.
* **API Removal**: Removed the legacy `getListTracingByTimeRange` method from `ApiService`.

### Added
* Support for dynamic `automaticRunTime` fetched directly from the Dataset detail.
* Added `datasetCode` to `MapGeoModel` to support multi-dataset tracking.
* New `DatasetModel` to handle dataset-specific configurations.

### Improved & Fixed
* **UI Stability**: Fixed text overflow issues in `GeoMapInfoCard` with smart ellipsis (max 2 lines) and improved wrapping.
* **Performance**: Optimized the data refresh sequence to avoid redundant API calls.

## 1.0.0


- Initial public release
- Support for Google Maps on mobile and web platforms
- Support for Flutter Map on all platforms (mobile and web)
- Universal `GeoMapPublic` widget that works across platforms
- `GeoMapController` for managing map state and data
- `GeoMapConfig` for configuring map behavior and appearance
- Role-based views: `viewer` (full features) and `driver` (simplified view)
- Close button callback for WebView integration
- Custom font configuration support
- Custom API base URLs for development and production environments
- Internationalization support (English and Vietnamese)
- Display markers, circles, polygons, and polylines
- Real-time data refresh capabilities
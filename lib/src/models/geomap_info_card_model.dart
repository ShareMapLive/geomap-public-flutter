/// Model for overriding fields displayed in [GeoMapInfoCard].
///
/// Each field is optional. When provided, it replaces the default value
/// fetched from the controller/API. When null, the card falls back to
/// the controller data.
class GeomapInfoCardModel {
  /// Override the card title. Defaults to "Bản đồ".
  final String? title;

  /// Override the map name row. Defaults to [MapGeoModel.description].
  final String? mapName;

  /// Override the map code row. Defaults to [MapGeoModel.geoMapCode].
  final String? mapCode;

  /// Override the date row. Defaults to the formatted date from JWT token.
  final String? dateDisplay;

  /// Extra description text shown below [mapName].
  /// Hidden when null.
  final String? description;

  /// Override the label for mapName. Defaults to "Tên bản đồ".
  final String? mapNameLabel;

  /// Override the label for mapCode. Defaults to "Mã bản đồ".
  final String? mapCodeLabel;

  /// Override the label for date. Defaults to "Ngày".
  final String? dateDisplayLabel;

  /// Override the label for description. Defaults to "Mô tả".
  final String? descriptionLabel;

  const GeomapInfoCardModel({
    this.title,
    this.mapName,
    this.mapCode,
    this.dateDisplay,
    this.description,
    this.mapNameLabel,
    this.mapCodeLabel,
    this.dateDisplayLabel,
    this.descriptionLabel,
  });
}

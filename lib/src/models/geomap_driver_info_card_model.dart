/// Model for overriding fields displayed in [GeoMapDriverInfoCard].
///
/// Each field is optional. When provided, it replaces the default value
/// resolved from controller tracing data. When null, the card falls back
/// to the controller data.
class GeomapDriverInfoCardModel {
  /// Override the card title. Defaults to "Người tham gia (1)".
  final String? title;

  /// Override the driver name. Defaults to the name fetched from tracing data.
  final String? driverName;

  /// Override the vehicle plate number.
  final String? plate;

  /// Override the avatar image URL shown in the card.
  final String? avatarUrl;

  /// Override the driver phone number.
  final String? phone;

  /// Extra description or status text shown at the bottom of the card.
  /// Hidden when null.
  final String? description;

  /// Manual start time override (milliseconds since epoch).
  final int? startTime;

  /// Manual end time override (milliseconds since epoch).
  final int? endTime;

  /// Optional manual override for distance text (e.g., "10.5 km").
  final String? distance;

  /// Optional manual override for duration text (e.g., "30 mins").
  final String? time;

  /// Optional manual override for average speed text (e.g., "45 km/h").
  final String? averageSpeed;

  /// Whether to force the card into avatar display mode.
  final bool? isAvatar;

  /// Creates a [GeomapDriverInfoCardModel] for overriding card fields.
  const GeomapDriverInfoCardModel({
    this.title,
    this.driverName,
    this.plate,
    this.avatarUrl,
    this.phone,
    this.description,
    this.startTime,
    this.endTime,
    this.distance,
    this.time,
    this.averageSpeed,
    this.isAvatar,
  });
}

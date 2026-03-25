class JwtTokenModel {
  List<String>? listUuid;

  /// Legacy single-date field (milliseconds since epoch).
  int? date;

  /// Start of the date range (milliseconds since epoch).
  /// Takes priority over [date] when computing start time.
  int? startTime;

  /// End of the date range (milliseconds since epoch).
  /// Takes priority over [date] when computing end time.
  int? endTime;

  JwtTokenModel({this.listUuid, this.date, this.startTime, this.endTime});

  factory JwtTokenModel.fromJson(Map<String, dynamic> json) {
    return JwtTokenModel(
      listUuid: _parseStringList(json['listUuid']),
      date: _parseInt(json['date']),
      startTime: _parseInt(json['startTime']),
      endTime: _parseInt(json['endTime']),
    );
  }

  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (listUuid != null) {
      data['listUuid'] = listUuid;
    }
    data['date'] = date;
    if (startTime != null) data['startTime'] = startTime;
    if (endTime != null) data['endTime'] = endTime;
    return data;
  }
}

class JwtTokenModel {
  List<String>? listUuid;
  int? date;

  JwtTokenModel({this.listUuid, this.date});

  factory JwtTokenModel.fromJson(Map<String, dynamic> json) {
    return JwtTokenModel(
      listUuid: _parseStringList(json['listUuid']),
      date: _parseInt(json['date']),
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
    return data;
  }
}
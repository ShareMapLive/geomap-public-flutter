/// Model representing the response structure of the dataset detail API
/// GET /api/sharemap-dataset/public/detail/{code}
class DatasetModel {
  String? code;
  String? name;

  /// Automatic refresh interval in minutes (used for driver tracing timer)
  num? automaticRunTime;

  /// Avatar configuration options from dataset
  String? typeAvatarOption;
  String? value;

  DatasetModel({
    this.code,
    this.name,
    this.automaticRunTime,
    this.typeAvatarOption,
    this.value,
  });

  factory DatasetModel.fromJson(Map<String, dynamic> json) {
    return DatasetModel(
      code: json['code'],
      name: json['name'],
      automaticRunTime: json['automaticRunTime'],
      typeAvatarOption: json['typeAvatarOption'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['name'] = name;
    data['automaticRunTime'] = automaticRunTime;
    data['typeAvatarOption'] = typeAvatarOption;
    data['value'] = value;
    return data;
  }
}


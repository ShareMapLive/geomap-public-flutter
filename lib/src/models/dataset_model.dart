/// Model representing the response structure of the dataset detail API
/// GET /api/sharemap-dataset/public/detail/{code}
class DatasetModel {
  String? projectId;
  bool? allowUserCheckIn;
  String? businessId;
  int? createdAt;
  List<VehicleTrackingData>? vehicleTrackingData;
  String? name;
  int? timeTrackingVehicleConfiguration;
  bool? enabled;
  String? value;
  String? code;
  int? updatedAt;

  /// Automatic refresh interval in minutes (used for driver tracing timer)
  num? automaticRunTime;

  bool? isDefault;
  int? expiredTime;
  String? key;
  List<ListConfigurationAPI>? listConfigurationAPI;
  String? type;

  /// Avatar configuration options from dataset
  String? typeAvatarOption;

  DatasetModel({
    this.projectId,
    this.allowUserCheckIn,
    this.businessId,
    this.createdAt,
    this.vehicleTrackingData,
    this.name,
    this.timeTrackingVehicleConfiguration,
    this.enabled,
    this.value,
    this.code,
    this.updatedAt,
    this.automaticRunTime,
    this.isDefault,
    this.expiredTime,
    this.key,
    this.listConfigurationAPI,
    this.type,
    this.typeAvatarOption,
  });

  factory DatasetModel.fromJson(Map<String, dynamic> json) {
    return DatasetModel(
      projectId: json['projectId'],
      allowUserCheckIn: json['allowUserCheckIn'],
      businessId: json['businessId'],
      createdAt: json['createdAt'],
      name: json['name'],
      timeTrackingVehicleConfiguration:
          json['timeTrackingVehicleConfiguration'],
      enabled: json['enabled'],
      value: json['value'],
      code: json['code'],
      updatedAt: json['updatedAt'],
      automaticRunTime: json['automaticRunTime'],
      isDefault: json['isDefault'],
      expiredTime: json['expiredTime'],
      key: json['key'],
      type: json['type'],
      typeAvatarOption: json['typeAvatarOption'],
      vehicleTrackingData: json['vehicleTrackingData'] != null
          ? List<VehicleTrackingData>.from(json['vehicleTrackingData']
              .map((x) => VehicleTrackingData.fromJson(x)))
          : null,
      listConfigurationAPI: json['listConfigurationAPI'] != null
          ? List<ListConfigurationAPI>.from(json['listConfigurationAPI']
              .map((x) => ListConfigurationAPI.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['projectId'] = projectId;
    data['allowUserCheckIn'] = allowUserCheckIn;
    data['businessId'] = businessId;
    data['createdAt'] = createdAt;
    data['name'] = name;
    data['timeTrackingVehicleConfiguration'] = timeTrackingVehicleConfiguration;
    data['enabled'] = enabled;
    data['value'] = value;
    data['code'] = code;
    data['updatedAt'] = updatedAt;
    data['automaticRunTime'] = automaticRunTime;
    data['isDefault'] = isDefault;
    data['expiredTime'] = expiredTime;
    data['key'] = key;
    data['type'] = type;
    data['typeAvatarOption'] = typeAvatarOption;
    if (vehicleTrackingData != null) {
      data['vehicleTrackingData'] =
          vehicleTrackingData!.map((v) => v.toJson()).toList();
    }
    if (listConfigurationAPI != null) {
      data['listConfigurationAPI'] =
          listConfigurationAPI!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VehicleTrackingData {
  String? name;
  String? objectId;
  int? time;

  VehicleTrackingData({this.name, this.objectId, this.time});

  factory VehicleTrackingData.fromJson(Map<String, dynamic> json) {
    return VehicleTrackingData(
      name: json['name'],
      objectId: json['objectId'],
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'objectId': objectId,
      'time': time,
    };
  }
}

class ListConfigurationAPI {
  HeadersConfig? headers;
  String? method;
  ObjectMappingData? objectMappingData;
  String? url;
  String? responseContent;

  ListConfigurationAPI({
    this.headers,
    this.method,
    this.objectMappingData,
    this.url,
    this.responseContent,
  });

  factory ListConfigurationAPI.fromJson(Map<String, dynamic> json) {
    return ListConfigurationAPI(
      headers: json['headers'] != null
          ? HeadersConfig.fromJson(json['headers'])
          : null,
      method: json['method'],
      objectMappingData: json['objectMappingData'] != null
          ? ObjectMappingData.fromJson(json['objectMappingData'])
          : null,
      url: json['url'],
      responseContent: json['responseContent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'headers': headers?.toJson(),
      'method': method,
      'objectMappingData': objectMappingData?.toJson(),
      'url': url,
      'responseContent': responseContent,
    };
  }
}

class HeadersConfig {
  String? authorization;
  String? contentType;

  HeadersConfig({this.authorization, this.contentType});

  factory HeadersConfig.fromJson(Map<String, dynamic> json) {
    return HeadersConfig(
      authorization: json['Authorization'],
      contentType: json['ContentType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Authorization': authorization,
      'ContentType': contentType,
    };
  }
}

class ObjectMappingData {
  String? name;
  String? address;
  String? time;
  String? objectId;
  String? latitude;
  String? longitude;

  ObjectMappingData({
    this.name,
    this.address,
    this.time,
    this.objectId,
    this.latitude,
    this.longitude,
  });

  factory ObjectMappingData.fromJson(Map<String, dynamic> json) {
    return ObjectMappingData(
      name: json['name'],
      address: json['address'],
      time: json['time'],
      objectId: json['objectId'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'time': time,
      'objectId': objectId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

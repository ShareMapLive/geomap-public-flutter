class MapGeoModel {
  String? linkWebhook;
  String? geoMapCode;
  String? businessId;
  String? name;
  String? radius;
  String? nameWebhook;
  String? type;
  String? projectId;
  String? bizSharemapUid;
  String? passCode;
  List<NotificationManager>? notificationManager;
  List<UserJoinGeoMap>? userJoinGeoMap;
  TrackingVehicleConfiguration? trackingVehicleConfiguration;
  bool? isTrackingVehicleConfiguration;
  int? timeTrackingVehicleConfiguration;

  MapGeoModel({
    this.linkWebhook,
    this.geoMapCode,
    this.businessId,
    this.name,
    this.radius,
    this.nameWebhook,
    this.type,
    this.projectId,
    this.bizSharemapUid,
    this.passCode,
    this.notificationManager,
    this.userJoinGeoMap,
    this.trackingVehicleConfiguration,
    this.isTrackingVehicleConfiguration,
    this.timeTrackingVehicleConfiguration,
  });

  factory MapGeoModel.fromJson(Map<String, dynamic> json) {
    return MapGeoModel(
      projectId: json['projectId'],
      linkWebhook: json['linkWebhook'],
      businessId: json['businessId'],
      passCode: json['passCodeGeoMap'],
      radius: json['radius'],
      name: json['name'],
      notificationManager: json['notificationManager'] != null
          ? List<NotificationManager>.from(
              json['notificationManager'].map((x) => NotificationManager.fromJson(x)))
          : null,
      userJoinGeoMap: json['userJoinGeoMap'] != null
          ? List<UserJoinGeoMap>.from(
              json['userJoinGeoMap'].map((x) => UserJoinGeoMap.fromJson(x)))
          : null,
      trackingVehicleConfiguration: json['trackingVehicleConfiguration'] != null
          ? TrackingVehicleConfiguration.fromJson(json['trackingVehicleConfiguration'])
          : null,
      isTrackingVehicleConfiguration: json['isTrackingVehicleConfiguration'],
      timeTrackingVehicleConfiguration: json['timeTrackingVehicleConfiguration'],
      bizSharemapUid: json['bizSharemapUid'],
      geoMapCode: json['geoMapCode'],
      nameWebhook: json['nameWebhook'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['projectId'] = projectId;
    data['linkWebhook'] = linkWebhook;
    data['businessId'] = businessId;
    data['passCodeGeoMap'] = passCode;
    data['radius'] = radius;
    data['name'] = name;
    if (notificationManager != null) {
      data['notificationManager'] = notificationManager!.map((v) => v.toJson()).toList();
    }
    if (userJoinGeoMap != null) {
      data['userJoinGeoMap'] = userJoinGeoMap!.map((v) => v.toJson()).toList();
    }
    data['trackingVehicleConfiguration'] = trackingVehicleConfiguration?.toJson();
    data['isTrackingVehicleConfiguration'] = isTrackingVehicleConfiguration;
    data['timeTrackingVehicleConfiguration'] = timeTrackingVehicleConfiguration;
    data['bizSharemapUid'] = bizSharemapUid;
    data['geoMapCode'] = geoMapCode;
    data['nameWebhook'] = nameWebhook;
    data['type'] = type;
    return data;
  }
}

class NotificationManager {
  String? name;
  String? linkAvatar;
  String? userId;
  String? fcmToken;

  NotificationManager({
    this.name,
    this.linkAvatar,
    this.userId,
    this.fcmToken,
  });

  factory NotificationManager.fromJson(Map<String, dynamic> json) {
    return NotificationManager(
      name: json['name'],
      linkAvatar: json['linkAvatar'],
      userId: json['userId'],
      fcmToken: json['fcmToken'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['linkAvatar'] = linkAvatar;
    data['userId'] = userId;
    data['fcmToken'] = fcmToken;
    return data;
  }
}

class UserJoinGeoMap {
  String? name;
  String? userId;
  String? linkAvatar;
  double? lng;
  double? lat;
  String? address;  // Added for address information
  String? time;     // Added for time information
  String? plate;    // Vehicle plate number
  String? phone;    // Phone number

  UserJoinGeoMap({
    this.name,
    this.userId,
    this.linkAvatar,
    this.lng,
    this.lat,
    this.address,   // Added parameter
    this.time,      // Added parameter
    this.plate,     // Added parameter
    this.phone,     // Added parameter
  });

  factory UserJoinGeoMap.fromJson(Map<String, dynamic> json) {
    return UserJoinGeoMap(
      name: json['name'],
      userId: json['uuid'],
      linkAvatar: json['linkAvatar'],
      lng: _parseDouble(json['lng']),
      lat: _parseDouble(json['lat']),
      address: json['address'],  // Added field
      time: _parseTime(json['time']),        // Updated to handle both time formats
      plate: json['plate'],      // Added field
      phone: json['phone'],      // Added field
    );
  }

  static double? _parseDouble(dynamic value) {
    try {
      return double.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  // New method to handle both time formats
  static String? _parseTime(dynamic timeValue) {
    if (timeValue == null) return null;

    // If it's already a string, return as is
    if (timeValue is String) {
      return timeValue;
    }

    // If it's a number (milliseconds since epoch), convert to ISO format
    if (timeValue is num) {
      try {
        final dateTime = DateTime.fromMillisecondsSinceEpoch(timeValue.toInt());
        return dateTime.toIso8601String();
      } catch (e) {
        return timeValue.toString();
      }
    }

    // For any other type, convert to string
    return timeValue.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['uuid'] = userId;
    data['linkAvatar'] = linkAvatar;
    data['lng'] = lng;
    data['lat'] = lat;
    data['address'] = address;  // Added field
    data['time'] = time;        // Added field
    data['plate'] = plate;      // Added field
    data['phone'] = phone;      // Added field
    return data;
  }
}

class TrackingVehicleConfiguration {
  List<Map<String, dynamic>>? listConfigurationAPI;
  num? expiredTime;
  String? passCodeGeoMap;
  String? key;
  String? value;
  num? automaticRunTime;
  String? typeAvatarOption;
  String? valueAvatarOption;

  TrackingVehicleConfiguration({
    this.listConfigurationAPI,
    this.expiredTime,
    this.passCodeGeoMap,
    this.key,
    this.value,
    this.automaticRunTime,
    this.typeAvatarOption,
    this.valueAvatarOption,
  });

  factory TrackingVehicleConfiguration.fromJson(Map<String, dynamic> json) {
    return TrackingVehicleConfiguration(
      listConfigurationAPI: json['listConfigurationAPI'] != null
          ? List<Map<String, dynamic>>.from(
              json['listConfigurationAPI'].map((x) => Map<String, dynamic>.from(x)))
          : null,
      expiredTime: json['expiredTime'],
      passCodeGeoMap: json['passCodeGeoMap'],
      key: json['key'],
      value: json['value'],
      automaticRunTime: json['automaticRunTime'],
      typeAvatarOption: json['typeAvatarOption'],
      valueAvatarOption: json['valueAvatarOption'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['listConfigurationAPI'] = listConfigurationAPI;
    data['expiredTime'] = expiredTime;
    data['passCodeGeoMap'] = passCodeGeoMap;
    data['key'] = key;
    data['value'] = value;
    data['automaticRunTime'] = automaticRunTime;
    data['typeAvatarOption'] = typeAvatarOption;
    data['valueAvatarOption'] = valueAvatarOption;
    return data;
  }
}
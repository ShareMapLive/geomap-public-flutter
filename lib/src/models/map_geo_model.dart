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

  /// Dataset code used to call dataset tracking API
  String? datasetCode;

  List<NotificationManager>? notificationManager;
  List<UserJoinGeoMap>? userJoinGeoMap;
  TrackingVehicleConfiguration? trackingVehicleConfiguration;

  // New fields from JSON
  bool? isReturn;
  int? totalGeofencing;
  int? createdAt;
  bool? enableGeo;
  String? objectId;
  List<ListDetectTracing>? listDetectTracing;
  int? updatedAt;
  List<dynamic>? listManager;
  int? updatedTile38Sync;
  String? description;

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
    this.datasetCode,
    this.notificationManager,
    this.userJoinGeoMap,
    this.trackingVehicleConfiguration,
    this.isReturn,
    this.totalGeofencing,
    this.createdAt,
    this.enableGeo,
    this.objectId,
    this.listDetectTracing,
    this.updatedAt,
    this.listManager,
    this.updatedTile38Sync,
    this.description,
  });

  factory MapGeoModel.fromJson(Map<String, dynamic> json) {
    return MapGeoModel(
      projectId: json['projectId'],
      linkWebhook: json['linkWebhook'],
      businessId: json['businessId'],
      passCode: json['passCodeGeoMap'],
      radius: json['radius'],
      name: json['name'],
      datasetCode: json['datasetCode'],
      notificationManager: json['notificationManager'] != null
          ? List<NotificationManager>.from(json['notificationManager']
              .map((x) => NotificationManager.fromJson(x)))
          : null,
      userJoinGeoMap: json['userJoinGeoMap'] != null
          ? List<UserJoinGeoMap>.from(
              json['userJoinGeoMap'].map((x) => UserJoinGeoMap.fromJson(x)))
          : null,
      trackingVehicleConfiguration: json['trackingVehicleConfiguration'] != null
          ? TrackingVehicleConfiguration.fromJson(
              json['trackingVehicleConfiguration'])
          : null,
      bizSharemapUid: json['bizSharemapUid'],
      geoMapCode: json['geoMapCode'],
      nameWebhook: json['nameWebhook'],
      type: json['type'],
      isReturn: json['isReturn'],
      totalGeofencing: json['totalGeofencing'],
      createdAt: json['createdAt'],
      enableGeo: json['enableGeo'],
      objectId: json['objectId'],
      listDetectTracing: json['listDetectTracing'] != null
          ? List<ListDetectTracing>.from(json['listDetectTracing']
              .map((x) => ListDetectTracing.fromJson(x)))
          : null,
      updatedAt: json['updatedAt'],
      listManager: json['listManager'] != null
          ? List<dynamic>.from(json['listManager'])
          : null,
      updatedTile38Sync: json['updatedTile38Sync'],
      description: json['description'],
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
    data['datasetCode'] = datasetCode;
    if (notificationManager != null) {
      data['notificationManager'] =
          notificationManager!.map((v) => v.toJson()).toList();
    }
    if (userJoinGeoMap != null) {
      data['userJoinGeoMap'] = userJoinGeoMap!.map((v) => v.toJson()).toList();
    }
    data['trackingVehicleConfiguration'] =
        trackingVehicleConfiguration?.toJson();
    data['bizSharemapUid'] = bizSharemapUid;
    data['geoMapCode'] = geoMapCode;
    data['nameWebhook'] = nameWebhook;
    data['type'] = type;
    data['isReturn'] = isReturn;
    data['totalGeofencing'] = totalGeofencing;
    data['createdAt'] = createdAt;
    data['enableGeo'] = enableGeo;
    data['objectId'] = objectId;
    if (listDetectTracing != null) {
      data['listDetectTracing'] =
          listDetectTracing!.map((v) => v.toJson()).toList();
    }
    data['updatedAt'] = updatedAt;
    if (listManager != null) {
      data['listManager'] = listManager;
    }
    data['updatedTile38Sync'] = updatedTile38Sync;
    data['description'] = description;
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
  String? address; // Added for address information
  String? time; // Added for time information
  String? plate; // Vehicle plate number
  String? phone; // Phone number

  UserJoinGeoMap({
    this.name,
    this.userId,
    this.linkAvatar,
    this.lng,
    this.lat,
    this.address, // Added parameter
    this.time, // Added parameter
    this.plate, // Added parameter
    this.phone, // Added parameter
  });

  factory UserJoinGeoMap.fromJson(Map<String, dynamic> json) {
    return UserJoinGeoMap(
      name: json['name'],
      userId: json['uuid'],
      linkAvatar: json['linkAvatar'],
      lng: _parseDouble(json['lng']),
      lat: _parseDouble(json['lat']),
      address: json['address'], // Added field
      time: _parseTime(json['time']), // Updated to handle both time formats
      plate: json['plate'], // Added field
      phone: json['phone'], // Added field
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
    data['address'] = address; // Added field
    data['time'] = time; // Added field
    data['plate'] = plate; // Added field
    data['phone'] = phone; // Added field
    return data;
  }
}

class TrackingVehicleConfiguration {
  /// Type of avatar option (e.g., 'image', 'icon')
  String? typeAvatarOption;

  /// Value for the avatar option (e.g., URL or icon name)
  String? valueAvatarOption;

  /// Passcode for the geomap
  String? passCodeGeoMap;

  int? automaticRunTime;
  bool? allowUserCheckIn;
  String? objectId;

  TrackingVehicleConfiguration({
    this.typeAvatarOption,
    this.valueAvatarOption,
    this.passCodeGeoMap,
    this.automaticRunTime,
    this.allowUserCheckIn,
    this.objectId,
  });

  factory TrackingVehicleConfiguration.fromJson(Map<String, dynamic> json) {
    return TrackingVehicleConfiguration(
      typeAvatarOption: json['typeAvatarOption'],
      valueAvatarOption: json['valueAvatarOption'],
      passCodeGeoMap: json['passCodeGeoMap'],
      automaticRunTime: json['automaticRunTime'],
      allowUserCheckIn: json['allowUserCheckIn'],
      objectId: json['objectId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['typeAvatarOption'] = typeAvatarOption;
    data['valueAvatarOption'] = valueAvatarOption;
    data['passCodeGeoMap'] = passCodeGeoMap;
    data['automaticRunTime'] = automaticRunTime;
    data['allowUserCheckIn'] = allowUserCheckIn;
    data['objectId'] = objectId;
    return data;
  }
}

class ListDetectTracing {
  String? name;
  String? objectId;
  int? time;

  ListDetectTracing({
    this.name,
    this.objectId,
    this.time,
  });

  factory ListDetectTracing.fromJson(Map<String, dynamic> json) {
    return ListDetectTracing(
      name: json['name'],
      objectId: json['objectId'],
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['objectId'] = objectId;
    data['time'] = time;
    return data;
  }
}

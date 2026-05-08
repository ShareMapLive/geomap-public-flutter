class TracingModel {
  dynamic listGeofencingJson;
  String? objectId;
  String? detect;
  ObjectModel? object;
  ExtraData? extraData;
  num? createdAt;
  String? uuid;
  String? time;
  String? hook;
  String? key;
  String? name;
  String? imageLink;

  TracingModel({
    this.listGeofencingJson,
    this.objectId,
    this.detect,
    this.object,
    this.extraData,
    this.createdAt,
    this.uuid,
    this.time,
    this.hook,
    this.key,
    this.name,
    this.imageLink,
  });

  factory TracingModel.fromJson(Map<String, dynamic> json) {
    Map<String, GeofencingTracingModel>? geofencingMap;

    // Handle both array and map formats for listGeofencingJson
    if (json['listGeofencingJson'] != null) {
      if (json['listGeofencingJson'] is Map) {
        // Handle map format
        geofencingMap = <String, GeofencingTracingModel>{};
        Map<String, dynamic> geofencingJson = json['listGeofencingJson'];
        geofencingJson.forEach((key, value) {
          if (value != null && value is Map) {
            geofencingMap![key] = GeofencingTracingModel.fromJson(value);
          }
        });
      }
      // For array format, we just keep it as is in the listGeofencingJson field
    }

    return TracingModel(
      listGeofencingJson: json['listGeofencingJson'],
      objectId: json['objectId'],
      detect: json['detect'],
      object:
          json['object'] != null ? ObjectModel.fromJson(json['object']) : null,
      extraData: json['extraData'] != null
          ? ExtraData.fromJson(json['extraData'])
          : null,
      createdAt: json['createdAt'],
      uuid: json['uuid'],
      time: json['time'],
      hook: json['hook'],
      name: json['name'],
      key: json['key'],
      imageLink: json['imageLink'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['listGeofencingJson'] = listGeofencingJson;
    data['objectId'] = objectId;
    data['detect'] = detect;
    if (object != null) {
      data['object'] = object!.toJson();
    }
    data['extraData'] = extraData?.toJson();
    data['createdAt'] = createdAt;
    data['uuid'] = uuid;
    data['time'] = time;
    data['hook'] = hook;
    data['name'] = name;
    data['key'] = key;
    data['imageLink'] = imageLink;
    return data;
  }

  String getDetectWithTitleString() {
    // Handle the case where listGeofencingJson is a map
    if (listGeofencingJson != null && listGeofencingJson is Map) {
      Map<String, dynamic> geofencingMap = listGeofencingJson;
      final values = <String>[];
      geofencingMap.forEach((key, value) {
        if (value != null &&
            value is Map &&
            value['detect'] != null &&
            value['title'] != null) {
          values.add('${value['detect']} ${value['title']}');
        }
      });
      return values.join(', ');
    }
    return '';
  }
}

class ExtraData {
  String? avatar;
  String? plate;
  String? phone;
  String? address;
  // Add other fields as needed

  ExtraData({
    this.avatar,
    this.plate,
    this.phone,
    this.address,
  });

  factory ExtraData.fromJson(Map<String, dynamic> json) {
    return ExtraData(
      avatar: json['avatar'],
      plate: json['plate'],
      phone: json['phone'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['avatar'] = avatar;
    data['plate'] = plate;
    data['phone'] = phone;
    data['address'] = address;
    return data;
  }
}

class ObjectModel {
  String? type;
  List<num>? coordinates;

  ObjectModel({this.type, this.coordinates});

  factory ObjectModel.fromJson(Map<String, dynamic> json) {
    return ObjectModel(
      type: json['type'],
      coordinates: json['coordinates'] != null
          ? List<num>.from(json['coordinates'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['coordinates'] = coordinates;
    return data;
  }
}

class GeofencingTracingModel {
  double? lng;
  String? geoMapCode;
  String? businessId;
  String? searchKey;
  String? title;
  String? address;
  String? uuid;
  List<List<double>>? polygon;
  String? detect;
  List<PointDataTracing>? data;
  String? geohash;
  String? name;
  String? linkWebhook;
  int? radius;
  String? projectId;
  double? lat;
  int? sort;
  UserCheckIn? userCheckIn;

  GeofencingTracingModel({
    this.lng,
    this.geoMapCode,
    this.businessId,
    this.searchKey,
    this.title,
    this.address,
    this.uuid,
    this.polygon,
    this.detect,
    this.data,
    this.geohash,
    this.name,
    this.linkWebhook,
    this.radius,
    this.projectId,
    this.lat,
    this.sort,
    this.userCheckIn,
  });

  factory GeofencingTracingModel.fromJson(Map<dynamic, dynamic> json) {
    return GeofencingTracingModel(
      sort: json["sort"] != null && json["sort"].toString().isNotEmpty
          ? json["sort"]
          : 0,
      polygon: json["polygon"] != ""
          ? List<List<double>>.from(json["polygon"]
              .map((x) => List<double>.from(x.map((x) => x.toDouble()))))
          : null,
      data: json["data"] != "" && json["data"] != null
          ? GeofencingModel.parseDataFromJson(json["data"])
          : null,
      lng: json["lng"] != null && json["lng"].toString().isNotEmpty
          ? json["lng"]
          : null,
      geoMapCode: json["geoMapCode"],
      businessId: json["businessId"],
      searchKey: json["searchKey"],
      title: json["title"],
      address: json["address"],
      uuid: json["uuid"],
      geohash: json["geohash"],
      name: json["name"],
      radius: json["radius"],
      projectId: json["projectId"],
      linkWebhook: json["linkWebhook"],
      detect: json['detect'] ?? "",
      lat: json["lat"] != null && json["lat"].toString().isNotEmpty
          ? json["lat"]
          : null,
      userCheckIn: json["userCheckIn"] != null
          ? UserCheckIn.fromJson(Map<String, dynamic>.from(json["userCheckIn"]))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["lng"] = lng;
    if (polygon != null) {
      data["polygon"] = List<dynamic>.from(
          polygon!.map((x) => List<dynamic>.from(x.map((x) => x))));
    }
    if (this.data != null) {
      data["data"] = List<dynamic>.from(this.data!.map((x) => x.toJson()));
    }
    data["sort"] = sort;
    data["geoMapCode"] = geoMapCode;
    data["businessId"] = businessId;
    data["searchKey"] = searchKey;
    data["linkWebhook"] = linkWebhook;
    data["title"] = title;
    data["uuid"] = uuid;
    data["geohash"] = geohash;
    data["name"] = name;
    data["radius"] = radius;
    data["projectId"] = projectId;
    data["lat"] = lat;
    data["detect"] = detect;
    if (userCheckIn != null) {
      data["userCheckIn"] = userCheckIn!.toJson();
    }
    return data;
  }
}

class GeofencingModel {
  static List<PointDataTracing>? parseDataFromJson(dynamic json) {
    if (json == null) return null;
    if (json is List) {
      return json
          .map((e) => PointDataTracing.fromJson(e))
          .toList()
          .cast<PointDataTracing>();
    }
    return null;
  }
}

class PointDataTracing {
  String? uuid;
  String? title;
  double? lat;
  double? lng;
  int? radius;
  String? detect;

  PointDataTracing(
      {this.uuid, this.title, this.lat, this.lng, this.radius, this.detect});

  factory PointDataTracing.fromJson(Map<String, dynamic> json) {
    return PointDataTracing(
      uuid: json['uuid'],
      title: json['title'],
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      radius: json['radius'],
      detect: json['detect'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['title'] = title;
    data['lat'] = lat;
    data['lng'] = lng;
    data['radius'] = radius;
    data['detect'] = detect;
    return data;
  }
}

class UserCheckIn {
  String? userJoinGeoMapUuid;
  double? lat;
  double? lng;
  String? address;
  String? managerUuid;
  int? indexPoint;
  int? timeCheckIn;

  UserCheckIn({
    this.userJoinGeoMapUuid,
    this.lat,
    this.lng,
    this.address,
    this.managerUuid,
    this.indexPoint,
    this.timeCheckIn,
  });

  factory UserCheckIn.fromJson(Map<String, dynamic> json) {
    return UserCheckIn(
      userJoinGeoMapUuid: json['userJoinGeoMapUuid'],
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.tryParse(json['lng'].toString()) : null,
      address: json['address'],
      managerUuid: json['managerUuid'],
      indexPoint: json['indexPoint'],
      timeCheckIn: json['timeCheckIn'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userJoinGeoMapUuid'] = userJoinGeoMapUuid;
    data['lat'] = lat;
    data['lng'] = lng;
    data['address'] = address;
    data['managerUuid'] = managerUuid;
    data['indexPoint'] = indexPoint;
    data['timeCheckIn'] = timeCheckIn;
    return data;
  }
}

/// Model for geofencing data (points, polygons, etc.)
library;

import 'dart:convert';

import 'tracing_model.dart';

PublicGeofencingModel geofencingModelFromJson(String str) =>
    PublicGeofencingModel.fromJson(json.decode(str));

String geofencingModelToJson(PublicGeofencingModel data) =>
    json.encode(data.toJson());

class PointData {
  PointData({
    this.title,
    this.address,
    this.point,
    this.userCheckIn,
  });

  PointData.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    address = json['address'];
    point = json['point'] != null
        ? List<double>.from(json['point'].map((x) => x.toDouble()))
        : [];

    // Parse userCheckIn similar to PublicGeofencingModel
    // Handle both formats:
    // 1. Empty object: "userCheckIn": {}
    // 2. Nested object: "userCheckIn": {"UUID": {"userJoinGeoMapUuid": "...", ...}}
    userCheckIn = json['userCheckIn'] != null
        ? () {
            final dynamic checkInJson = json['userCheckIn'];
            if (checkInJson is Map<String, dynamic> ||
                checkInJson is Map<dynamic, dynamic>) {
              final map = Map<String, dynamic>.from(checkInJson);

              // Check if it's an empty object
              if (map.isEmpty) {
                return null;
              }

              // Check if it has direct keys like 'lat', 'lng', or 'userJoinGeoMapUuid'
              if (map.containsKey('lat') ||
                  map.containsKey('userJoinGeoMapUuid')) {
                return UserCheckIn.fromJson(map);
              }

              // Otherwise, check if it contains nested objects keyed by UUID
              // We take the first value that looks like a check-in
              if (map.isNotEmpty) {
                final firstValue = map.values.first;
                if (firstValue is Map) {
                  return UserCheckIn.fromJson(
                      Map<String, dynamic>.from(firstValue));
                }
              }
            }
            return null;
          }()
        : null;
  }

  String? title;
  String? address;
  List<double>? point;
  UserCheckIn? userCheckIn;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['title'] = title;
    map['address'] = address;
    if (point != null) {
      map['point'] = point!.map((x) => x).toList();
    }
    if (userCheckIn != null) {
      map['userCheckIn'] = userCheckIn!.toJson();
    }
    return map;
  }
}

class PublicGeofencingModel {
  PublicGeofencingModel({
    this.lng,
    this.data,
    this.geoMapCode,
    this.businessId,
    this.searchKey,
    this.title,
    this.address,
    this.uuid,
    this.polygon,
    this.detect,
    this.geohash,
    this.name,
    this.linkWebhook,
    this.radius,
    this.projectId,
    this.lat,
    this.sort,
    this.userCheckIn,
  });

  // copyWith method for creating a copy with updated values
  PublicGeofencingModel copyWith({
    double? lng,
    List<PointData>? data,
    String? geoMapCode,
    String? businessId,
    String? searchKey,
    String? title,
    String? address,
    String? uuid,
    List<List<double>>? polygon,
    List<String>? detect,
    String? geohash,
    String? name,
    String? linkWebhook,
    int? radius,
    String? projectId,
    double? lat,
    int? sort,
    UserCheckIn? userCheckIn,
  }) {
    return PublicGeofencingModel(
      lng: lng ?? this.lng,
      data: data ?? this.data,
      geoMapCode: geoMapCode ?? this.geoMapCode,
      businessId: businessId ?? this.businessId,
      searchKey: searchKey ?? this.searchKey,
      title: title ?? this.title,
      address: address ?? this.address,
      uuid: uuid ?? this.uuid,
      polygon: polygon ?? this.polygon,
      detect: detect ?? this.detect,
      geohash: geohash ?? this.geohash,
      name: name ?? this.name,
      linkWebhook: linkWebhook ?? this.linkWebhook,
      radius: radius ?? this.radius,
      projectId: projectId ?? this.projectId,
      lat: lat ?? this.lat,
      sort: sort ?? this.sort,
      userCheckIn: userCheckIn ?? this.userCheckIn,
    );
  }

  double? lng;
  String? geoMapCode;
  String? businessId;
  String? searchKey;
  String? title;
  String? uuid;
  String? address;
  List<List<double>>? polygon;
  List<String>? detect;
  List<PointData>? data;
  String? geohash;
  String? name;
  String? linkWebhook;
  int? radius;
  String? projectId;
  double? lat;
  int? sort;
  UserCheckIn? userCheckIn;

  factory PublicGeofencingModel.fromJson(Map<dynamic, dynamic> json) =>
      PublicGeofencingModel(
        sort: json["sort"] != null && json["sort"].toString().isNotEmpty
            ? json["sort"]
            : 0,
        polygon: json["polygon"] != ""
            ? List<List<double>>.from(json["polygon"]
                .map((x) => List<double>.from(x.map((x) => x.toDouble()))))
            : null,
        data: json["data"] != null && json["data"] != ""
            ? List<PointData>.from(
                json["data"].map((x) => PointData.fromJson(x)))
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
        detect: json['detect'] != null ? json['detect'].cast<String>() : [],
        lat: json["lat"] != null && json["lat"].toString().isNotEmpty
            ? json["lat"]
            : null,
        userCheckIn: json["userCheckIn"] != null
            ? () {
                // userCheckIn structure from server is:
                // "userCheckIn": { "UUID_STRING": { "userJoinGeoMapUuid": "...", ... } }
                // or potentially just directly the object if structure changes.
                // Based on user log: "userCheckIn":{"VITLEn04FlhLZLAlxtdVPx2fKyG3":{...}}

                final dynamic checkInJson = json["userCheckIn"];
                if (checkInJson is Map<String, dynamic> ||
                    checkInJson is Map<dynamic, dynamic>) {
                  final map = Map<String, dynamic>.from(checkInJson);

                  // Check if it has direct keys like 'lat', 'lng'
                  if (map.containsKey('lat') ||
                      map.containsKey('userJoinGeoMapUuid')) {
                    return UserCheckIn.fromJson(map);
                  }

                  // Otherwise, check if it contains nested objects keyed by UUID
                  // We take the first value that looks like a checkin
                  if (map.isNotEmpty) {
                    final firstValue = map.values.first;
                    if (firstValue is Map) {
                      return UserCheckIn.fromJson(
                          Map<String, dynamic>.from(firstValue));
                    }
                  }
                }
                return null;
              }()
            : null,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      "lng": lng,
      "polygon": polygon != null
          ? List<dynamic>.from(
              polygon!.map((x) => List<dynamic>.from(x.map((x) => x))))
          : [],
      "data":
          data != null ? List<dynamic>.from(data!.map((x) => x.toJson())) : [],
      "sort": sort,
      "geoMapCode": geoMapCode,
      "businessId": businessId,
      "searchKey": searchKey,
      "linkWebhook": linkWebhook,
      "title": title,
      "address": address,
      "uuid": uuid,
      "geohash": geohash,
      "name": name,
      "radius": radius,
      "projectId": projectId,
      "lat": lat,
      "detect": detect,
    };
    if (userCheckIn != null) {
      // Wrap userCheckIn in a map keyed by uuid if necessary?
      // For now, assume client-side doesn't need to replicate the weird server structure when sending back.
      // But for storage consistency/caching, we just save the object.
      // However, if we want to match server response structure exactly, we'd need the key.
      // Since we don't store the key, we just save the object directly or we can't fully reconstruct.
      // Let's just save the object for now.
      map["userCheckIn"] = userCheckIn!.toJson();
    }
    return map;
  }
}

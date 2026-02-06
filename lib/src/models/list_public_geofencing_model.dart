import 'geofencing_model.dart';

class ListPublicGeofencingModel {
  int? total;
  List<PublicGeofencingModel>? list;

  ListPublicGeofencingModel({
    this.total,
    this.list,
  });

  factory ListPublicGeofencingModel.fromJson(Map<String, dynamic> json) {
    return ListPublicGeofencingModel(
      total: json['total'],
      list: json['list'] != null
          ? List<PublicGeofencingModel>.from(
              json['list'].map((x) => PublicGeofencingModel.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

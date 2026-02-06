import 'tracing_model.dart';
import 'map_geo_model.dart';

/// Model representing the response structure for a list of tracing records
class ListTracingModel {
  int? total;
  List<TracingModel>? geoMapTracing;
  MapGeoModel? geoMap;
  int? limit;
  int? page;

  ListTracingModel({
    this.total,
    this.geoMapTracing,
    this.geoMap,
    this.limit,
    this.page,
  });

  factory ListTracingModel.fromJson(Map<String, dynamic> json) {
    return ListTracingModel(
      total: json['total'] as int?,
      geoMapTracing: json['geoMapTracing'] != null
          ? (json['geoMapTracing'] as List)
              .map((item) => TracingModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      geoMap: json['geoMap'] != null 
          ? MapGeoModel.fromJson(json['geoMap'] as Map<String, dynamic>) 
          : null,
      limit: json['limit'] as int?,
      page: json['page'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    if (geoMapTracing != null) {
      data['geoMapTracing'] = geoMapTracing!.map((item) => item.toJson()).toList();
    }
    if (geoMap != null) {
      data['geoMap'] = geoMap!.toJson();
    }
    data['limit'] = limit;
    data['page'] = page;
    return data;
  }
}
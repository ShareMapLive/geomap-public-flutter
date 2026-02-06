/// Model for route data
class RouteModel {
  String? code;
  List<Route>? routes;

  RouteModel({this.code, this.routes});

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    print('Parsing RouteModel from JSON: $json');
    final model = RouteModel(
      code: json['code'],
      routes: json['routes'] != null
          ? List<Route>.from(json['routes'].map((x) => Route.fromJson(x)))
          : null,
    );
    print('Parsed RouteModel with code: ${model.code}, routes count: ${model.routes?.length ?? 0}');
    return model;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    if (routes != null) {
      data['routes'] = routes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

/// Model for a single route
class Route {
  num? distance;
  num? duration;
  List<Leg>? legs;
  String? geometry;

  Route({this.distance, this.duration, this.legs, this.geometry});

  factory Route.fromJson(Map<String, dynamic> json) {
    print('Parsing Route from JSON. Keys: ${json.keys}');
    print('Route geometry: ${json['geometry']}');
    final route = Route(
      distance: json['distance'],
      duration: json['duration'],
      legs: json['legs'] != null
          ? List<Leg>.from(json['legs'].map((x) => Leg.fromJson(x)))
          : null,
      geometry: json['geometry'],
    );
    print('Parsed Route with distance: ${route.distance}, duration: ${route.duration}, legs count: ${route.legs?.length ?? 0}');
    return route;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['distance'] = distance;
    data['duration'] = duration;
    if (legs != null) {
      data['legs'] = legs!.map((v) => v.toJson()).toList();
    }
    data['geometry'] = geometry;
    return data;
  }
}

/// Model for a leg of a route
class Leg {
  num? distance;
  num? duration;
  List<Step>? steps;

  Leg({this.distance, this.duration, this.steps});

  factory Leg.fromJson(Map<String, dynamic> json) {
    print('Parsing Leg from JSON. Keys: ${json.keys}');
    print('Leg steps count: ${json['steps']?.length ?? 0}');
    final leg = Leg(
      distance: json['distance'],
      duration: json['duration'],
      steps: json['steps'] != null
          ? List<Step>.from(json['steps'].map((x) => Step.fromJson(x)))
          : null,
    );
    print('Parsed Leg with distance: ${leg.distance}, duration: ${leg.duration}, steps count: ${leg.steps?.length ?? 0}');
    return leg;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['distance'] = distance;
    data['duration'] = duration;
    if (steps != null) {
      data['steps'] = steps!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

/// Model for a step in a route leg
class Step {
  num? distance;
  num? duration;
  Maneuver? maneuver;
  String? geometry;
  String? name;
  String? mode;
  String? drivingSide;
  List<Intersection>? intersections;
  num? weight;

  Step({
    this.distance,
    this.duration,
    this.maneuver,
    this.geometry,
    this.name,
    this.mode,
    this.drivingSide,
    this.intersections,
    this.weight,
  });

  factory Step.fromJson(Map<String, dynamic> json) {
    print('Parsing Step from JSON. Keys: ${json.keys}');
    print('Step intersections count: ${json['intersections']?.length ?? 0}');
    final step = Step(
      distance: json['distance'],
      duration: json['duration'],
      maneuver:
          json['maneuver'] != null ? Maneuver.fromJson(json['maneuver']) : null,
      geometry: json['geometry'],
      name: json['name'],
      mode: json['mode'],
      drivingSide: json['driving_side'],
      intersections: json['intersections'] != null
          ? List<Intersection>.from(
              json['intersections'].map((x) => Intersection.fromJson(x)))
          : null,
      weight: json['weight'],
    );
    print('Parsed Step with distance: ${step.distance}, duration: ${step.duration}, intersections count: ${step.intersections?.length ?? 0}');
    return step;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['distance'] = distance;
    data['duration'] = duration;
    if (maneuver != null) {
      data['maneuver'] = maneuver!.toJson();
    }
    data['geometry'] = geometry;
    data['name'] = name;
    data['mode'] = mode;
    data['driving_side'] = drivingSide;
    if (intersections != null) {
      data['intersections'] = intersections!.map((v) => v.toJson()).toList();
    }
    data['weight'] = weight;
    return data;
  }
}

/// Model for maneuver information
class Maneuver {
  num? bearingAfter;
  num? bearingBefore;
  List<num>? location;
  String? type;
  String? modifier;

  Maneuver(
      {this.bearingAfter,
      this.bearingBefore,
      this.location,
      this.type,
      this.modifier});

  factory Maneuver.fromJson(Map<String, dynamic> json) {
    return Maneuver(
      bearingAfter: json['bearing_after'],
      bearingBefore: json['bearing_before'],
      location:
          json['location'] != null ? List<num>.from(json['location']) : null,
      type: json['type'],
      modifier: json['modifier'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bearing_after'] = bearingAfter;
    data['bearing_before'] = bearingBefore;
    if (location != null) {
      data['location'] = location;
    }
    data['type'] = type;
    data['modifier'] = modifier;
    return data;
  }
}

/// Model for intersection information
class Intersection {
  num? out;
  num? inn;
  List<bool>? entry;
  List<num>? bearings;
  List<num>? location;

  Intersection({this.out, this.inn, this.entry, this.bearings, this.location});

  factory Intersection.fromJson(Map<String, dynamic> json) {
    print('Parsing Intersection from JSON. Keys: ${json.keys}');
    print('Intersection location: ${json['location']}');
    final intersection = Intersection(
      out: json['out'],
      inn: json['in'],
      entry: json['entry'] != null ? List<bool>.from(json['entry']) : null,
      bearings:
          json['bearings'] != null ? List<num>.from(json['bearings']) : null,
      location:
          json['location'] != null ? List<num>.from(json['location']) : null,
    );
    print('Parsed Intersection with location: ${intersection.location}');
    return intersection;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['out'] = out;
    data['in'] = inn;
    if (entry != null) {
      data['entry'] = entry;
    }
    if (bearings != null) {
      data['bearings'] = bearings;
    }
    if (location != null) {
      data['location'] = location;
    }
    return data;
  }
}

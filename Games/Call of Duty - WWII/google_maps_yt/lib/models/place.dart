// To parse this JSON data, do
//
//     final purpleMap = purpleMapFromJson(jsonString);

import 'dart:convert';

List<List<PurpleMap>> purpleMapFromJson(String str) => List<List<PurpleMap>>.from(json.decode(str).map((x) => List<PurpleMap>.from(x.map((x) => PurpleMap.fromJson(x)))));

String purpleMapToJson(List<List<PurpleMap>> data) => json.encode(List<dynamic>.from(data.map((x) => List<dynamic>.from(x.map((x) => x.toJson())))));

class PurpleMap {
  Location location;
  String id;
  String name;
  String address;
  String city;
  String country;
  String state;
  String postalCode;
  String type;
  int starRating;
  String picture;
  List<String> menuItems;
  List<double> prices;
  String foodType;
  bool reservation;
  int occupancy;
  List<AvailableWeekDay> availableWeekDays;
  DateTime creationTimestamp;
  int v;

  PurpleMap({
    required this.location,
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.country,
    required this.state,
    required this.postalCode,
    required this.type,
    required this.starRating,
    required this.picture,
    required this.menuItems,
    required this.prices,
    required this.foodType,
    required this.reservation,
    required this.occupancy,
    required this.availableWeekDays,
    required this.creationTimestamp,
    required this.v,
  });

  factory PurpleMap.fromJson(Map<String, dynamic> json) => PurpleMap(
    location: Location.fromJson(json["location"]),
    id: json["_id"],
    name: json["name"],
    address: json["Address"],
    city: json["City"],
    country: json["Country"],
    state: json["State"],
    postalCode: json["PostalCode"],
    type: json["type"],
    starRating: json["starRating"],
    picture: json["picture"],
    menuItems: List<String>.from(json["menuItems"].map((x) => x)),
    prices: List<double>.from(json["prices"].map((x) => x?.toDouble())),
    foodType: json["foodType"],
    reservation: json["reservation"],
    occupancy: json["occupancy"],
    availableWeekDays: List<AvailableWeekDay>.from(json["availableWeekDays"].map((x) => AvailableWeekDay.fromJson(x))),
    creationTimestamp: DateTime.parse(json["creationTimestamp"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "location": location.toJson(),
    "_id": id,
    "name": name,
    "Address": address,
    "City": city,
    "Country": country,
    "State": state,
    "PostalCode": postalCode,
    "type": type,
    "starRating": starRating,
    "picture": picture,
    "menuItems": List<dynamic>.from(menuItems.map((x) => x)),
    "prices": List<dynamic>.from(prices.map((x) => x)),
    "foodType": foodType,
    "reservation": reservation,
    "occupancy": occupancy,
    "availableWeekDays": List<dynamic>.from(availableWeekDays.map((x) => x.toJson())),
    "creationTimestamp": creationTimestamp.toIso8601String(),
    "__v": v,
  };
}

class AvailableWeekDay {
  String dayOfWeek;
  OpenTime openTime;
  CloseTime closeTime;
  String id;

  AvailableWeekDay({
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    required this.id,
  });

  factory AvailableWeekDay.fromJson(Map<String, dynamic> json) => AvailableWeekDay(
    dayOfWeek: json["dayOfWeek"],
    openTime: openTimeValues.map[json["openTime"]]!,
    closeTime: closeTimeValues.map[json["closeTime"]]!,
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "dayOfWeek": dayOfWeek,
    "openTime": openTimeValues.reverse[openTime],
    "closeTime": closeTimeValues.reverse[closeTime],
    "_id": id,
  };
}

enum CloseTime {
  THE_0900_PM,
  THE_1000_PM,
  THE_1100_PM
}

final closeTimeValues = EnumValues({
  "09:00 PM": CloseTime.THE_0900_PM,
  "10:00 PM": CloseTime.THE_1000_PM,
  "11:00 PM": CloseTime.THE_1100_PM
});

enum OpenTime {
  THE_0800_AM,
  THE_0900_AM
}

final openTimeValues = EnumValues({
  "08:00 AM": OpenTime.THE_0800_AM,
  "09:00 AM": OpenTime.THE_0900_AM
});

class Location {
  String type;
  List<double> coordinates;

  Location({
    required this.type,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    type: json["type"],
    coordinates: List<double>.from(json["coordinates"].map((x) => x?.toDouble())),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

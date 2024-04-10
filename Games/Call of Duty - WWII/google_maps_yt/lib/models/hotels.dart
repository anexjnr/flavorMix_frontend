import 'dart:convert';

enum MenuItem { item1, item2, item3 } // Define your menu item enum here

final menuItemValues = EnumValues({
  "item1": MenuItem.item1,
  "item2": MenuItem.item2,
  "item3": MenuItem.item3
}); // Define enum values mapping here

enum OpenTime { time1, time2 } // Define your open time enum here

final openTimeValues = EnumValues({
  "time1": OpenTime.time1,
  "time2": OpenTime.time2
}); // Define enum values mapping here

enum CloseTime { time1, time2 } // Define your close time enum here

final closeTimeValues = EnumValues({
  "time1": CloseTime.time1,
  "time2": CloseTime.time2
}); // Define enum values mapping here

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String>? get reverse {
    reverseMap ??= map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

List<Hotely> hotelyFromJson(String str) => List<Hotely>.from(json.decode(str).map((x) => Hotely.fromJson(x)));

String hotelyToJson(List<Hotely> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Hotely {
  String userId;
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
  List<MenuItem> menuItems;
  List<int> prices;
  String foodType;
  bool reservation;
  int occupancy;
  List<AvailableWeekDay> availableWeekDays;
  DateTime creationTimestamp;
  int v;
  int approximateTotalBill;
  double? distance;
  List<Combination> combinations;

  Hotely({
    required this.userId,
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
    required this.approximateTotalBill,
    required this.distance,
    required this.combinations,
  });

  factory Hotely.fromJson(Map<String, dynamic> json) => Hotely(
    userId: json["userId"],
    id: json["_id"],
    name: json["name"],
    address: json["address"],
    city: json["city"],
    country: json["country"],
    state: json["state"],
    postalCode: json["postalCode"],
    type: json["type"],
    starRating: json["starRating"],
    picture: json["picture"],
    menuItems: List<MenuItem>.from(json["menuItems"].map((x) => menuItemValues.map[x])),
    prices: List<int>.from(json["prices"].map((x) => x)),
    foodType: json["foodType"],
    reservation: json["reservation"],
    occupancy: json["occupancy"],
    availableWeekDays: List<AvailableWeekDay>.from(json["availableWeekDays"].map((x) => AvailableWeekDay.fromJson(x))),
    creationTimestamp: DateTime.parse(json["creationTimestamp"]),
    v: json["__v"],
    approximateTotalBill: json["approximateTotalBill"],
    distance: json["distance"]?.toDouble(),
    combinations: List<Combination>.from(json["combinations"].map((x) => Combination.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "_id": id,
    "name": name,
    "address": address,
    "city": city,
    "country": country,
    "state": state,
    "postalCode": postalCode,
    "type": type,
    "starRating": starRating,
    "picture": picture,
    "menuItems": List<dynamic>.from(menuItems.map((x) => menuItemValues.reverse![x])),
    "prices": List<dynamic>.from(prices.map((x) => x)),
    "foodType": foodType,
    "reservation": reservation,
    "occupancy": occupancy,
    "availableWeekDays": List<dynamic>.from(availableWeekDays.map((x) => x.toJson())),
    "creationTimestamp": creationTimestamp.toIso8601String(),
    "__v": v,
    "approximateTotalBill": approximateTotalBill,
    "distance": distance,
    "combinations": List<dynamic>.from(combinations.map((x) => x.toJson())),
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
    "openTime": openTimeValues.reverse![openTime],
    "closeTime": closeTimeValues.reverse![closeTime],
    "_id": id,
  };
}

class Combination {
  List<MenuItem> combination;
  int totalPrice;

  Combination({
    required this.combination,
    required this.totalPrice,
  });

  factory Combination.fromJson(Map<String, dynamic> json) => Combination(
    combination: List<MenuItem>.from(json["combination"].map((x) => menuItemValues.map[x])),
    totalPrice: json["totalPrice"],
  );

  Map<String, dynamic> toJson() => {
    "combination": List<dynamic>.from(combination.map((x) => menuItemValues.reverse![x])),
    "totalPrice": totalPrice,
  };
}

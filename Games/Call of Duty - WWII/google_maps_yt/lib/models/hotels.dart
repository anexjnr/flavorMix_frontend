// import 'dart:convert';
//
// class ManuRestaurant {
//   final String userId;
//   final Location location;
//   final String id;
//   final String name;
//   final String address;
//   final String city;
//   final String country;
//   final String state;
//   final String postalCode;
//   final String type;
//   final int starRating;
//   final String picture;
//   final List<String> menuItems;
//   final List<int> prices;
//   final String foodType;
//   final bool reservation;
//   final int occupancy;
//   final List<AvailableWeekDay> availableWeekDays;
//   final DateTime creationTimestamp;
//   final int v;
//   final int approximateTotalBill;
//   final double distance;
//   final List<Combination> combinations;
//
//   ManuRestaurant({
//     required this.userId,
//     required this.location,
//     required this.id,
//     required this.name,
//     required this.address,
//     required this.city,
//     required this.country,
//     required this.state,
//     required this.postalCode,
//     required this.type,
//     required this.starRating,
//     required this.picture,
//     required this.menuItems,
//     required this.prices,
//     required this.foodType,
//     required this.reservation,
//     required this.occupancy,
//     required this.availableWeekDays,
//     required this.creationTimestamp,
//     required this.v,
//     required this.approximateTotalBill,
//     required this.distance,
//     required this.combinations,
//   });
//
//   factory ManuRestaurant.fromJson(Map<String, dynamic> json) {
//     return ManuRestaurant(
//       userId: json['userId'],
//       location: Location.fromJson(json['location']),
//       id: json['_id'],
//       name: json['name'],
//       address: json['Address'],
//       city: json['City'],
//       country: json['Country'],
//       state: json['State'],
//       postalCode: json['PostalCode'],
//       type: json['type'],
//       starRating: json['starRating'],
//       picture: json['picture'],
//       menuItems: List<String>.from(json['menuItems']),
//       prices: List<int>.from(json['prices']),
//       foodType: json['foodType'],
//       reservation: json['reservation'],
//       occupancy: json['occupancy'],
//       availableWeekDays: List<AvailableWeekDay>.from(json['availableWeekDays'].map((x) => AvailableWeekDay.fromJson(x))),
//       creationTimestamp: DateTime.parse(json['creationTimestamp']),
//       v: json['__v'],
//       approximateTotalBill: json['approximateTotalBill'],
//       distance: json['distance'].toDouble(),
//       combinations: List<Combination>.from(json['combinations'].map((x) => Combination.fromJson(x))),
//     );
//   }
// }
//
// class Location {
//   final String type;
//   final List<double> coordinates;
//
//   Location({
//     required this.type,
//     required this.coordinates,
//   });
//
//   factory Location.fromJson(Map<String, dynamic> json) {
//     return Location(
//       type: json['type'],
//       coordinates: List<double>.from(json['coordinates'].map((x) => x.toDouble())),
//     );
//   }
// }
//
// class AvailableWeekDay {
//   final String dayOfWeek;
//   final String openTime;
//   final String closeTime;
//   final String id;
//
//   AvailableWeekDay({
//     required this.dayOfWeek,
//     required this.openTime,
//     required this.closeTime,
//     required this.id,
//   });
//
//   factory AvailableWeekDay.fromJson(Map<String, dynamic> json) {
//     return AvailableWeekDay(
//       dayOfWeek: json['dayOfWeek'],
//       openTime: json['openTime'],
//       closeTime: json['closeTime'],
//       id: json['_id'],
//     );
//   }
// }
//
// class Combination {
//   final List<String> combination;
//   final int totalPrice;
//
//   Combination({
//     required this.combination,
//     required this.totalPrice,
//   });
//
//   factory Combination.fromJson(Map<String, dynamic> json) {
//     return Combination(
//       combination: List<String>.from(json['combination']),
//       totalPrice: json['totalPrice'],
//     );
//   }
// }
//
// Future<ManuRestaurant> parseResponseAndBuildUI(String responseBody) async {
//   final ManuRestaurant restaurant = await parseResponseAndBuildUI(responseBody);
//   print('Restaurant Name: ${restaurant.name}');
//   print('Menu Items: ${restaurant.menuItems}');
//   print('Star Rating: ${restaurant.starRating}');
//   return buildHotelCard(restaurant.toJson());
// }
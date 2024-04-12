import 'dart:convert';
import 'package:http/http.dart' as http;

class Place {
  final String id;
  final String name;
  final String address;
  final String city;
  final String country;
  final String state;
  final String postalCode;
  final String type;
  final int starRating;
  final String picture;
  final String foodType;
  final Location location; // Add Location property

  Place({
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
    required this.foodType,
    required this.location, // Add Location parameter
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['_id'],
      name: json['name'],
      address: json['Address'],
      city: json['City'],
      country: json['Country'],
      state: json['State'],
      postalCode: json['PostalCode'],
      type: json['type'],
      starRating: json['starRating'],
      foodType: json['foodType'],
      picture: json['picture'],
      location: Location.fromJson(json['location']),
    );
  }
}

class Location {
  final List<double> coordinates;

  Location({
    required this.coordinates,
  });

  // Add factory method to create Location object from JSON
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      coordinates: List<double>.from(json['coordinates']),
    );
  }
}

Future<List<Place>> fetchPlaces() async {
  final response = await http.get(Uri.parse('http://192.168.212.143:3000/api/hotels/hotels'));

  if (response.statusCode == 200) {
    List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((json) => Place.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load places');
  }
}

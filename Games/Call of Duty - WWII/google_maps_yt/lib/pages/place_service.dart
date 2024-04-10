import 'package:google_maps_yt/models/place.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlaceService {
  static const String baseUrl = 'http://192.168.212.143:3000/api/hotels'; // Replace with your backend URL

  static Future<List<PurpleMap>> fetchPlaces() async {
    final response = await http.get(Uri.parse('$baseUrl/hotels'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PurpleMap.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load places');
    }
  }
}
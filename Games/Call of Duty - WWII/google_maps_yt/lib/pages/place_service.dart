import 'package:http/http.dart' as http;
import 'dart:convert';

class PlaceService {
  static const String baseUrl = 'http://192.168.212.143:3000/api/hotels'; // Replace with your backend URL

  static Future<List<dynamic>> fetchPlaces() async {
    final response = await http.get(Uri.parse('$baseUrl/hotels'));
    print('API Response: ${response.body}');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load places');
    }
  }
}

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/hotels.dart';

class UsersService {
  Future<dynamic> getUserProfile(String userId, String token) async {
    var client = http.Client();
    var apiUrl = Uri.parse('http://192.168.212.143:3000/api/viewuserprofile');
    var response = await client.post(apiUrl,
        headers: <String, String>{
          'Authorization': token,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'userId': userId,
        }));

    print('Status Code : ${response.statusCode}');
    print('userId in service : $userId');
    print('token in service : $token');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  Future<dynamic> getProfile(String userId, String token) async {
    var client = http.Client();
    var apiUrl = Uri.parse(
        'http://192.168.212.143:3000/api/viewprofilepicture');
    var response = await client.post(apiUrl,
        headers: <String, String>{
          'Authorization': token,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'userId': userId,
        }));

    print('Status Code in getProfile : ${response.statusCode}');
    print('userId in getProfile : $userId');
    print('token in getProfile : $token');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  Future<dynamic> calculateMenuCombinations(String userId,
      String token,
      int totalAmount,
      int numberOfPeople,
      bool reservation,
      Map<String, List<double>>? userLocation,
      String dayOfWeek,
      String time,) async {
    var client = http.Client();
    var apiUrl = Uri.parse(
        'http://192.168.212.143:3000/api/user/calculateMenuCombinations');
    var response = await client.post(
      apiUrl,
      headers: <String, String>{
        'Authorization': token,
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'totalAmount': totalAmount,
        'numberOfPeople': numberOfPeople,
        'reservation': reservation,
        'userLocation': userLocation,
        'dayOfWeek': dayOfWeek,
        'time': time,
      }),
    );

    print('Response status code: ${response.statusCode}');
    final responseBody = response.body;
    print('Response body length: ${responseBody.length}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw 'Failed to calculate menu combinations: ${response.statusCode}';
    }
}}

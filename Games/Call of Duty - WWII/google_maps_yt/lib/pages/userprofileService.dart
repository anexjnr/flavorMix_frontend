import 'package:http/http.dart' as http;
import 'dart:convert';

class UsersService {
  Future<dynamic> getUserProfile(String userId, String token) async {
    var client = http.Client();
    var apiUrl = Uri.parse('http://192.168.33.143:3000/api/viewuserprofile');

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
}

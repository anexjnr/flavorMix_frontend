import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future<Map<String, dynamic>> calculateMenuCombinations(
      String userId,
      String token,
      double totalAmount,
      int numberOfPeople,
      bool reservation,
      List<double>? userLocation,
      String dayOfWeek,
      String time,
      ) async {
    var client = http.Client();
    var apiUrl = Uri.parse('http://192.168.212.143:3000/api/user/calculateMenuCombinations');
    try
    {
    var response = await client.post(apiUrl,
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

    print("userId in Search : "+userId);
    print("totalAmount in Search : "+totalAmount.toString());
    print("numberOfPeople in Search : "+numberOfPeople.toString());
    print("reservation in Search : "+reservation.toString());
    print(userLocation);
    print("dayOfWeek in Search : "+dayOfWeek);
    print("time in Search : "+time);
    // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody as Map<String, dynamic>;
      } else {
        // Request failed, throw an error
        throw 'Failed to calculate menu combinations: ${response.statusCode}';
      }
    } catch (error) {
      // Catch any errors that occur during the request
      throw 'Error calculating menu combinations: $error';
    }
  }
}

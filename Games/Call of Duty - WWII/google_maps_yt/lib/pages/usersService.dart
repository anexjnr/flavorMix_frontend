import 'package:http/http.dart' as http;
import 'dart:convert';

class UsersService {
  static const String baseUrl = 'http://192.168.33.143:3000/api/user/signup';

  static Future<String> userSignup({
    required String firstName,
    required String lastName,
    required String mobileNumber,
    required String email,
    required String password,
  }) async {
    // Construct the request body
    Map<String, String> requestBody = {
      'firstName': firstName,
      'lastName': lastName,
      'mobileNumber': mobileNumber,
      'email': email,
      'password': password,
    };

    // Make the HTTP POST request with the request body
    final response = await http.post(
      Uri.parse(baseUrl),
      body: jsonEncode(requestBody), // Encode the body to JSON
      headers: {'Content-Type': 'application/json'}, // Set headers
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String? userId = responseData['userId'];
      if (userId != null) {
        return userId;
      } else {
        throw Exception('User ID not found in response');
      }
    } else {
      // Extract error message from response body
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String errorMessage = responseData['message'] ?? 'Failed to sign up user';
      throw Exception(errorMessage);
    }
  }

  static const String signUrl = 'http://192.168.33.143:3000/api/user/signin';
  static Future<Map<String, dynamic>> signIn({required String email, required String password}) async {
    final response = await http.post(
      Uri.parse(signUrl),
      body: jsonEncode({'email': email, 'password': password}), // Ensure proper JSON encoding
      headers: {'Content-Type': 'application/json'},
    );

    // Troubleshooting Step 5: Log the response status code and body
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String token = responseData['token'];
      final String userId = responseData['userId'];
      return {'token': token, 'userId': userId};
    } else if (response.statusCode == 401) {
      throw Exception('Please verify your OTP before logging in');
    } else if (response.statusCode == 402) {
      throw Exception('Invalid credentials');
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Server error');
    }
  }

  static const String forgetUrl = 'http://192.168.33.143:3000/api/user/forgotpassword';
  static Future<void> forgetPass({required String email}) async {
    final response = await http.post(
      Uri.parse(forgetUrl),
      body: jsonEncode({'email': email}), // Ensure proper JSON encoding
      headers: {'Content-Type': 'application/json'},
    );

    // Troubleshooting Step 5: Log the response status code and body
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Email is not registered');
    } else {
      throw Exception('Server error');
    }
  }

  static const String forgetmainUrl = 'http://192.168.33.143:3000/api/user/resetpassword';

  static Future<void> forgetmainPass({required String email, required String otp, required String newPassword, required String confirmPassword}) async {
  try {
  final response = await http.post(
  Uri.parse(forgetmainUrl),
  body: jsonEncode({
  'email': email,
  'otp': otp,
  'newPassword': newPassword,
  'confirmPassword': confirmPassword,
  }),
  headers: {'Content-Type': 'application/json'},
  );

  // Troubleshooting Step 5: Log the response status code and body
  print('Response status code: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
  final Map<String, dynamic> responseData = json.decode(response.body);
  // Handle success response if needed
  } else if (response.statusCode == 404) {
  throw Exception('Email is not registered');
  } else if (response.statusCode == 401) {
  throw Exception('Invalid OTP');
  } else if (response.statusCode == 402) {
  throw Exception('Passwords do not match');
  } else if (response.statusCode == 405) {
  throw Exception('Password must be at least 8 characters long');
  } else {
  throw Exception('Server error');
  }
  } catch (error) {
  throw Exception('Error: $error');
  }
  }
}

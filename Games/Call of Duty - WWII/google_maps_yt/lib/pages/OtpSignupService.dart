import 'package:http/http.dart' as http;
import 'dart:convert';

class OtpService {
  static const String baseUrl = 'http://192.168.33.143:3000/api/user/verifyotp';
  static Future<String> verifyOtp({required String userId, required String otp}) async {
    final response = await http.post(
      Uri.parse(baseUrl),

body: jsonEncode({'userId': userId, 'otp': otp}), // Ensure proper JSON encoding
headers: {'Content-Type': 'application/json'},
);

// Troubleshooting Step 5: Log the response status code and body
print('Response status code: ${response.statusCode}');
print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return 'OTP verification successful';
    } else if (response.statusCode == 400) {
      throw Exception('Invalid OTP');
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Server error');
    }
  }
}

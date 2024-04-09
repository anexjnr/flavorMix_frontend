import 'dart:convert';
import 'package:http/http.dart' as http;
import 'student_request_model.dart';

class StudentRequestService {
  static const String baseUrl = 'http://your-api-url.com';

  Future<List<StudentRequest>> fetchStudentRequests({
    String? date,
    String? email,
    String? name,
    String? admissionNumber,
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/doctor-view-requests'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'date': date,
        'email': email,
        'name': name,
        'admissionNumber': admissionNumber,
        'token': token,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => StudentRequest.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load student requests');
    }
  }
}

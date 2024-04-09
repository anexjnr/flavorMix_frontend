// student_request_model.dart

class StudentRequest {
  final String id;
  final String name;
  final String email;
  final String admissionNumber;
  final String token;
  final DateTime createdAt;

  StudentRequest({
    required this.id,
    required this.name,
    required this.email,
    required this.admissionNumber,
    required this.token,
    required this.createdAt,
  });

  // Factory method to convert JSON data to StudentRequest object
  factory StudentRequest.fromJson(Map<String, dynamic> json) {
    return StudentRequest(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      admissionNumber: json['admissionNumber'],
      token: json['token'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

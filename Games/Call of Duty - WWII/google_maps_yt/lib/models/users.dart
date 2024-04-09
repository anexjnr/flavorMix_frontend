// To parse this JSON data, do
//
//     final users = usersFromJson(jsonString);

import 'dart:convert';

List<Users> usersFromJson(String str) => List<Users>.from(json.decode(str).map((x) => Users.fromJson(x)));

String usersToJson(List<Users> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Users {
  String id;
  String firstName;
  String lastName;
  String mobileNumber;
  String email;
  String password;
  bool otpVerified;

  Users({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    required this.email,
    required this.password,
    required this.otpVerified,
  });

  factory Users.fromJson(Map<String, dynamic> json) => Users(
    id: json["_id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    mobileNumber: json["mobileNumber"],
    email: json["email"],
    password: json["password"],
    otpVerified: json["otpVerified"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "firstName": firstName,
    "lastName": lastName,
    "mobileNumber": mobileNumber,
    "email": email,
    "password": password,
    "otpVerified": otpVerified,
  };
}

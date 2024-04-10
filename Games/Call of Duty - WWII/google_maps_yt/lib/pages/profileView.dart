import 'dart:convert';
import 'dart:typed_data'; // Add this import
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileViewPage extends StatefulWidget {
  @override
  _ProfileViewPageState createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  late String _userId;
  late String _token;
  Uint8List? _profilePicBytes;// Declare the variable here

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId') ?? '';
      _token = prefs.getString('token') ?? '';
      print("UserID in profileView : " +_userId);
    });
  }
  Future<Map<String, dynamic>> _fetchUserProfile(_userId,_token) async {
    var client = http.Client();
    var apiUrl = Uri.parse("http://192.168.212.143:3000/api/fullviewuserprofile");
    var response = await client.post(apiUrl,
        headers: <String, String>{
        'Authorization': _token,
        'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
        'userId': _userId,
        }));
    print("StatusCOde in Profile View :" +response.statusCode.toString());
    print('userId in profileService : $_userId');
    print('token in profileService : $_token');
    if (response.statusCode == 200) {
      final Map<String, dynamic> userProfile = json.decode(response.body);
      final String base64Image = userProfile['profilePic'];
      _profilePicBytes = base64Decode(base64Image);
      return userProfile;
    } else {
      throw Exception('Failed to load user profile');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('View Profile', style: TextStyle(color: Colors.pinkAccent)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.pinkAccent),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder(
        future: _fetchUserProfile(_userId,_token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final Map<String, dynamic> userProfile = snapshot.data as Map<String, dynamic>;
            print("Userprofile : " +userProfile.toString());
            return SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 80.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: _profilePicBytes != null && _profilePicBytes is Uint8List
                      ? MemoryImage(_profilePicBytes as Uint8List) as ImageProvider<Object>
                      : AssetImage('assets/images/unknown.jpg'),
                  ),
                  SizedBox(height: 20),
                  Text('Full Name:', style: TextStyle(color: Colors.pinkAccent)),
                  Text(userProfile['fullName'], style: TextStyle(color: Colors.white)),
                  SizedBox(height: 10),
                  Text('Email:', style: TextStyle(color: Colors.pinkAccent)),
                  Text(userProfile['email'], style: TextStyle(color: Colors.white)),
                  SizedBox(height: 10),
                  Text('Mobile Number:', style: TextStyle(color: Colors.pinkAccent)),
                  Text(userProfile['mobileNumber'], style: TextStyle(color: Colors.white)),
                  SizedBox(height: 10),
                  Text('Age:', style: TextStyle(color: Colors.pinkAccent)),
                  Text(userProfile['age'].toString(), style: TextStyle(color: Colors.white)),
                  SizedBox(height: 10),
                  Text('Place:', style: TextStyle(color: Colors.pinkAccent)),
                  Text(userProfile['place'], style: TextStyle(color: Colors.white)),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

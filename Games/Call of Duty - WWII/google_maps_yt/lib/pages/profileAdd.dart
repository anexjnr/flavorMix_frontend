import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileAddPage extends StatefulWidget {
  @override
  _ProfileAddPageState createState() => _ProfileAddPageState();
}

class _ProfileAddPageState extends State<ProfileAddPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _placeController = TextEditingController();
  XFile? _imageFile; // Store the selected image file
  String? _userId;
  String? _token;
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _mobileNumber;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    _token = prefs.getString('token');
    _firstName = prefs.getString('firstName');
    _lastName = prefs.getString('lastName');
    _email = prefs.getString('email');
    _mobileNumber = prefs.getString('mobileNumber');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Add Profile', style: TextStyle(color: Colors.pinkAccent)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.pinkAccent),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text('Profile Picture:', style: TextStyle(color: Colors.pinkAccent)),
              SizedBox(height: 10),
              _buildImagePicker(), // Add image picker widget
              SizedBox(height: 20),
              if (_userId != null && _token != null) _buildHiddenField('UserId', _userId!),
              if (_token != null) _buildHiddenField('Token', _token!),
              if (_firstName != null) _buildHiddenField('First Name', _firstName!),
              if (_lastName != null) _buildHiddenField('Last Name', _lastName!),
              if (_email != null) _buildHiddenField('Email', _email!),
              if (_mobileNumber != null) _buildHiddenField('Mobile Number', _mobileNumber!),
              SizedBox(height: 20),
              _buildTextField('Age', _ageController, TextInputType.number),
              SizedBox(height: 20),
              _buildTextField('Place', _placeController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _submitProfile();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
                child: Text('Submit', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller, [TextInputType? keyboardType]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.pinkAccent),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white), borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pinkAccent), borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        return null;
      },
    );
  }

  Widget _buildHiddenField(String labelText, String value) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.pinkAccent),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white), borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pinkAccent), borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: () => _pickImage(),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: _imageFile == null
            ? Icon(Icons.camera_alt, size: 40, color: Colors.pinkAccent)
            : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_userId != null && _token != null) {
        String fileName = _imageFile != null ? _imageFile!.path.split('/').last : '';
        String url = 'http://192.168.212.143:3000/api/userprofile';
        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.fields['userId'] = _userId!;
        request.fields['age'] = _ageController.text;
        request.fields['place'] = _placeController.text;
        request.headers['Authorization'] = _token!; // Using null-aware operator
        request.files.add(await http.MultipartFile.fromPath('profilePic', _imageFile!.path, filename: fileName));

        var response = await request.send();
        var responseBody = await response.stream.bytesToString();
        var jsonData = json.decode(responseBody);
        if (response.statusCode == 201) {
          // Profile submitted successfully
          print('Profile submitted successfully');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonData['message'])));
          // Navigate to next screen or perform any action
        } else {
          // Error in submitting profile
          print('Error in submitting profile: ${jsonData['error']}');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonData['error'])));
        }
      }
    }
  }
}

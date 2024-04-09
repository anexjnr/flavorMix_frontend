import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_maps_yt/pages/usersService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'forgetPassword_page.dart';
import 'map_page.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Sign In', style: TextStyle(color: Colors.pinkAccent)),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 210),
                _buildTextField('Email', _emailController, keyboardType: TextInputType.emailAddress),
                SizedBox(height: 20),
                _buildPasswordField('Password', _passwordController),
                SizedBox(height: 30),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgetPasswordPage()));
                      },
                      child: Text(
                        'Forgot Your Password ?',
                        style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _validateInputs();
                    _signIn();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  ),
                  child: Text('Sign In', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white), borderRadius: BorderRadius.circular(10.0)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pinkAccent), borderRadius: BorderRadius.circular(10.0)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        if (labelText == 'Email' && !EmailValidator.validate(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(String labelText, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      obscureText: !_passwordVisible,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white), borderRadius: BorderRadius.circular(10.0)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pinkAccent), borderRadius: BorderRadius.circular(10.0)),
        suffixIcon: IconButton(
          icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        } else if (value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
    );
  }

  void _validateInputs() {
    if (_formKey.currentState!.validate()) {
      // All fields are valid
    }
  }

  void _signIn() async {
    // Implement your sign-in logic here
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text;
      final String password = _passwordController.text;

      try {
        final Map<String, dynamic> userData = await UsersService.signIn(email: email, password: password);

        final String token = userData['token'];
        final String userId = userData['userId'];

        // Save user session using SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);
        prefs.setString('userId', userId);
        print("token : "+token);
        print("userId : "+userId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in successful'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context)=>MapPage()));
        // Navigate to next screen after successful sign in
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

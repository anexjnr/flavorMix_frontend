import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_maps_yt/pages/usersService.dart';

import 'forget_Main_Page.dart';

class ForgetPasswordPage extends StatefulWidget {
  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Forget Password', style: TextStyle(color: Colors.pinkAccent)),
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
                ElevatedButton(
                  onPressed: () {
                    _validateInputs();
                    _forgotPassword();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  ),
                  child: Text('Verify OTP', style: TextStyle(color: Colors.white)),
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

  void _validateInputs() {
    if (_formKey.currentState!.validate()) {
      // All fields are valid
    }
  }

  void _forgotPassword() async {
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text;

      try {
        await UsersService.forgetPass(email: email);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset instructions sent to $email'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgetMainPage()));
      }
      catch (error) {
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

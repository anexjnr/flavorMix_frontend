import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_maps_yt/pages/signin_page.dart';
import 'package:google_maps_yt/pages/usersService.dart';

class ForgetMainPage extends StatefulWidget {
  const ForgetMainPage({Key? key}) : super(key: key);

  @override
  _ForgetMainPageState createState() => _ForgetMainPageState();
}

class _ForgetMainPageState extends State<ForgetMainPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Reset Password', style: TextStyle(color: Colors.pinkAccent)),
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
                SizedBox(height: 20),
                _buildTextField('Email', _emailController, keyboardType: TextInputType.emailAddress),
                SizedBox(height: 20),
                _buildTextField('OTP', _otpController, keyboardType: TextInputType.number),
                SizedBox(height: 20),
                _buildPasswordField('New Password', _newPasswordController),
                SizedBox(height: 20),
                _buildPasswordField('Confirm Password', _confirmPasswordController),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _forgotPassword,
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

  Widget _buildPasswordField(String labelText, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      obscureText: true,
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
        if (value.length < 8) {
          return 'Password must be at least 8 characters long';
        }
        return null;
      },
    );
  }

  void _forgotPassword() async {
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text;
      final String otp = _otpController.text;
      final String newPassword = _newPasswordController.text;
      final String confirmPassword = _confirmPasswordController.text;

      try {
        await UsersService.forgetmainPass(email: email, otp: otp, newPassword: newPassword, confirmPassword: confirmPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset successful'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context)=>SignInPage()));
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

import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_yt/pages/signin_page.dart';
import 'package:google_maps_yt/pages/usersService.dart';
import 'package:google_maps_yt/pages/verifyOtp_signUp_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _agreeToTerms = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Sign Up', style: TextStyle(color: Colors.pinkAccent)),
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
                _buildTextField('First Name', _firstNameController),
                SizedBox(height: 10),
                _buildTextField('Last Name', _lastNameController),
                SizedBox(height: 10),
                _buildTextField('Email', _emailController, keyboardType: TextInputType.emailAddress),
                SizedBox(height: 10),
                _buildTextField('Mobile Number', _mobileController, keyboardType: TextInputType.phone),
                SizedBox(height: 10),
                _buildPasswordField('Password', _passwordController),
                SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value!;
                        });
                      },
                      activeColor: Colors.pinkAccent,
                    ),
                    Text(
                      'I agree to the Terms and Conditions',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _agreeToTerms ? _signUp : null, // Call _signUp function
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _agreeToTerms ? Colors.pinkAccent : Colors.grey,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  ),
                  child: Text('Sign Up', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>SignInPage()));
                  },
                  child: Text(
                    'Already have an account? Sign in',
                    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                ),
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
        if (labelText == 'Mobile Number' && !value.startsWith('+91-') && !RegExp(r'^\+91-[1-9]\d{9}$').hasMatch(value)) {
          return 'Please enter a valid mobile number (e.g., +91-1234567890)';
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

  void _signUp() async {
    print('Attempting to sign up'); // Debugging statement
    if (_formKey.currentState!.validate()) {
      try {
        print('Validation successful'); // Debugging statement
        final String userId = await UsersService.userSignup(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          mobileNumber: _mobileController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
        print('User created successfully'); // Debugging statement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User created successfully. Please check your email for confirmation.'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to OTP verification page after successful sign up
        Navigator.push(context, MaterialPageRoute(builder: (context)=>VerifyOtpPage(userId: userId))); // Replace '/otp_verification' with your OTP verification page route
      } catch (error) {
        print('Error during sign up: $error'); // Debugging statement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print('Validation failed'); // Debugging statement
    }
  }
}
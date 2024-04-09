import 'package:flutter/material.dart';
import 'package:google_maps_yt/pages/signin_page.dart';
import 'dart:async';
import 'OtpSignupService.dart';

class VerifyOtpPage extends StatefulWidget {
  final String userId;

  VerifyOtpPage({required this.userId});

  @override
  _VerifyOtpPageState createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  late Timer _timer;
  int _secondsRemaining = 30;
  String _otp = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer.cancel();
          // Handle timeout
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _verifyOtp() async {
    try {
      // Troubleshooting Step 1: Confirm that the method is being called
      print('Verifying OTP: $_otp for user: ${widget.userId}');

      final response = await OtpService.verifyOtp(userId: widget.userId, otp: _otp);

      // Troubleshooting Step 3: Verify Scaffold availability and context
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context)=>SignInPage()));
    }
    catch (error) {
      // Troubleshooting Step 4: Check error handling and console logs
      print('Error verifying OTP: $error');

      // Show error message in a snackbar
      String errorMessage = 'Error verifying OTP';
      if (error is Exception) {
        errorMessage = error.toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Verify OTP',
          style: TextStyle(color: Colors.pinkAccent),
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Time remaining: $_secondsRemaining seconds',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _otp = value;
                  });
                },
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter OTP',
                  hintStyle: TextStyle(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pinkAccent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _otp.length < 6 ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
                child: Text('Verify OTP', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Implement resend OTP logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
                child: Text('Resend OTP', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
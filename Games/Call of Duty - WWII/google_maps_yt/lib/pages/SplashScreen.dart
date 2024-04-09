import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'signup_page.dart'; // Import your sign-up page here

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  late bool _isVideoInitialized;

  @override
  void initState() {
    super.initState();
    _isVideoInitialized = false;
    _controller = VideoPlayerController.asset('assets/videos/Comp2.mp4')
      ..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
          _controller.play();
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      body: _isVideoInitialized
          ? Center(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
      )
          : Container(), // Placeholder until video is initialized
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Navigate to sign-up page after the video has finished playing
    _controller.addListener(() {
      if (_controller.value.isInitialized &&
          !_controller.value.isPlaying &&
          _controller.value.duration == _controller.value.position) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignUpPage()),
        );
      }
    });
  }
}
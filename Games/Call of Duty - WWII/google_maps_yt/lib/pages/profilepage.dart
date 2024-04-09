import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: _buildProfile(),
    );
  }

  Widget _buildProfile() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 32.0),
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 80.0,
            //backgroundImage: AssetImage('assets/profile_picture.jpg'), // Placeholder image
          ),
          SizedBox(height: 16.0),
          Text(
            'John Doe',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.0),
          TextButton(
            onPressed: () {
              // Navigate to full profile page
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, color: Colors.white), // Icon representing profile
                SizedBox(width: 8.0),
                Text(
                  'View Full Profile',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_maps_yt/pages/profileAdd.dart';
import 'package:google_maps_yt/pages/profileView.dart';

class BottomNavigationPage extends StatefulWidget {
  @override
  _BottomNavigationPageState createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    ProfileViewPage(),
    ProfileAddPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.pinkAccent),
            label: 'View Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.pinkAccent),
            label: 'Add Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pinkAccent,
        backgroundColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}

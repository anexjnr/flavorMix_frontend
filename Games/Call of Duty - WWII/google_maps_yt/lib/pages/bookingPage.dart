import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookingPage extends StatefulWidget {
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String _selectedItem = ''; // Initially no item is selected
  List<String> _bookingOptions = []; // List to hold booking options

  @override
  void initState() {
    super.initState();
    _fetchBookingOptions(); // Fetch booking options when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Booking',
          style: TextStyle(color: Colors.pinkAccent),
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _bookingOptions.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    color: _selectedItem == _bookingOptions[index] ? Colors.pinkAccent.withOpacity(0.3) : Colors.grey[800],
                    child: ListTile(
                      title: Text(
                        _bookingOptions[index],
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedItem = _bookingOptions[index];
                          _saveSelectedOption(_selectedItem);
                          print('Selected Option: $_selectedItem');
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _submitBooking(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
              ),
              child: Text('Select'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchBookingOptions() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token') ?? '';
      final String userId = prefs.getString('userId') ?? '';
      final String hotelId = prefs.getString('selectedHotelId') ?? '';
      final int totalAmount = prefs.getInt('totalAmount') ?? 0;
      final int numberOfPeople = prefs.getInt('numberOfPeople') ?? 0;

      final String apiUrl = 'http://192.168.212.143:3000/api/reservation/get-menu-item-combinations';
      final Map<String, dynamic> requestData = {
        'userId': userId,
        'hotelId': hotelId,
        'totalPrice': totalAmount,
        'numberOfPeople': numberOfPeople,
      };

      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );

      print("in booking page status : " + response.statusCode.toString());
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> combinations = jsonData['combinations'];

        List<String> bookingOptions = [];
        combinations.forEach((dynamic combination) {
          if (combination is List<dynamic>) {
            bookingOptions.add(combination.join(", "));
          }
        });

        setState(() {
          _bookingOptions = bookingOptions;
          print(_bookingOptions);
          _selectedItem = bookingOptions.isNotEmpty ? bookingOptions.first : '';
        });
      } else {
        throw Exception('Failed to fetch booking options: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching booking options: $error');
      // Show user-friendly error message (e.g., SnackBar)
    }
  }

  void _saveSelectedOption(String selectedOption) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedOption', selectedOption);
  }

  void _submitBooking(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token') ?? '';
      final String userId = prefs.getString('userId') ?? '';
      final String hotelId = prefs.getString('selectedHotelId') ?? '';
      final String selectedOption = prefs.getString('selectedOption') ?? '';
      final String dayOfWeek = prefs.getString('dayOfWeek') ?? '';
      final String time = prefs.getString('time') ?? '';

      print("In booking page dayOfWeek : " + dayOfWeek);
      print("In booking page time : " + time);
      print("In booking page selectedOption : " + selectedOption);

      final String apiUrl = 'http://192.168.212.143:3000/api/reservation/create-reservation';
      final Map<String, dynamic> requestData = {
        'userId': userId,
        'hotelId': hotelId,
        'selectedOption': selectedOption,
        'time': time,
        'day': dayOfWeek
      };

      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to submit booking: ${response.statusCode}');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

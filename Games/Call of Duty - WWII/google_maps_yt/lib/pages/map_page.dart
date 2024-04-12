import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_yt/pages/profileMenu.dart';
import 'package:google_maps_yt/pages/profileView.dart';
import 'package:google_maps_yt/pages/userprofileService.dart';
import 'package:location/location.dart' as location;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hotels.dart';
import '../models/place.dart';
import '../pages/place_service.dart';
import 'package:intl/intl.dart';

import 'bookingPage.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  TextEditingController _amountController = TextEditingController();
  TextEditingController _peopleController = TextEditingController();
  Uint8List? _profilePicBytes;
  String? _fullName;
  double _currentHeading = 0.0;
  location.Location _locationController = location.Location();
  final Completer<GoogleMapController> _mapController = Completer<
      GoogleMapController>();
  LatLng? _currentPosition;
  List<Place> _places = [];
  List<Map<String, dynamic>> _hotelData = []; // Change the type of _hotelData
  bool _showCarousel = false;
  bool _isLoading = true;
  bool _reservation = false;
  bool _showDrawer = false;

  @override
  void initState() {
    super.initState();
    _getLocationUpdates();
    _fetchPlaces();
    _fetchUserProfile();
    _fetchProfilePicture();
  }

  Future<void> _getExistingParametersAndNavigate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');
    final List<String>? userLocationStrings = prefs.getStringList(
        'userLocation');

    final userLocation = userLocationStrings != null
        ? {
      'coordinates': [
        double.parse(userLocationStrings[1]),
        double.parse(userLocationStrings[0])
      ]
    }
        : null;

    final String dayOfWeek = DateFormat('EEEE').format(DateTime.now());
    final String time = TimeOfDay.now().format(context);

    prefs.setString('dayOfWeek', dayOfWeek);
    prefs.setString('time', time);

    print('Amount controller text: ${_amountController.text}');
    print('People controller text: ${_peopleController.text}');

    final int totalAmount = int.tryParse(_amountController.text) ?? 0;
    final int numberOfPeople = int.tryParse(_peopleController.text) ?? 0;
    final bool reservation = _reservation;

    try {
      if (userId != null && token != null) {
        UsersService userService = UsersService();
        final hotelData = await userService.calculateMenuCombinations(
          userId,
          token,
          totalAmount,
          numberOfPeople,
          reservation,
          userLocation,
          dayOfWeek,
          time,
        );

        if (hotelData != null && hotelData is Map<String, dynamic>) {
          // Check if hotelData["hotels"] is a list
          if (hotelData["hotels"] is List<dynamic>) {
            // Cast each element to Map<String, dynamic> and add to _hotelData
            List<dynamic> hotelsList = hotelData["hotels"];
            List<Map<String, dynamic>> hotelsMapList = [];
            for (var hotel in hotelsList) {
              if (hotel is Map<String, dynamic>) {
                // Convert each hotel object to a map
                Map<String, dynamic> convertedHotel = Map<String, dynamic>.from(
                    hotel);
                // Add the converted hotel map to the list
                hotelsMapList.add(convertedHotel);
              }
            }
            setState(() {
              _hotelData = hotelsMapList;
              _showCarousel = true;
            });
          } else {
            throw 'Invalid hotel data received';
          }
        } else {
          throw 'Invalid hotel data received';
        }
      }
    } catch (error) {
      print('Error: $error');
      _showErrorSnackbar(context, error.toString());
    }

    // Store totalAmount and numberOfPeople in SharedPreferences
    prefs.setInt('totalAmount', totalAmount);
    prefs.setInt('numberOfPeople', numberOfPeople);
  }

  void _showErrorSnackbar(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: Duration(seconds: 3), // Adjust the duration as needed
      ),
    );
  }

// Function to handle storing hotelId in SharedPreferences
  void _storeHotelId(String hotelId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedHotelId', hotelId);
  }


  Future<void> _fetchProfilePicture() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');
    print("On Map Page profile : " + userId!);
    print("On Map Page profile : " + token!);
    if (userId != null && token != null) {
      try {
        UsersService userService = UsersService();
        final userData = await userService.getProfile(
            userId, token); // Call the method on the instan
        Uint8List bytes = base64Decode(userData['profilePic']
            .split(',')
            .last);
        setState(() {
          _profilePicBytes = bytes;
        });
      } catch (error) {
        print('Error fetching user profile: $error');
      }
    }
  }

  Future<void> _fetchUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');
    print("On Map Page : " + userId!);
    print("On Map Page : " + token!);
    if (userId != null && token != null) {
      try {
        UsersService userService = UsersService(); // Create an instance of UsersService
        final userData = await userService.getUserProfile(
            userId, token); // Call the method on the instan
        Uint8List bytes = base64Decode(userData['profilePic']
            .split(',')
            .last);
        setState(() {
          _profilePicBytes = bytes; // Set the profile picture bytes
          _fullName = userData['fullName'];
        });
      } catch (error) {
        print('Error fetching user profile: $error');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                setState(() {
                  _showDrawer = !_showDrawer;
                });
              },
              icon: Icon(
                Icons.menu,
                color: Colors
                    .white, // Change the color of the hamburger icon to white
              ),
            );
          },
        ),
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/FLAVOR (1).png',
            fit: BoxFit.contain,
            width: 100,
            height: 40,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            // Adjust right padding for notification icon
            child: IconButton(
              onPressed: () {
                // Handle Notification Button Pressed
              },
              iconSize: 28.0,
              icon: Icon(Icons.notifications, color: Colors.white),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            // Adjust right padding between icons
            child: IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfileViewPage()));
              },
              iconSize: 30,
              icon: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white, // Background color for avatar
                backgroundImage: _profilePicBytes != null &&
                    _profilePicBytes is Uint8List
                    ? MemoryImage(
                    _profilePicBytes as Uint8List) as ImageProvider<Object>
                    : AssetImage(
                    'assets/images/unknown.jpg'), // Default profile picture
              ),
            ),
          ),
        ],
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          _buildGoogleMap(),
          if (_showDrawer) _buildDrawer(),
          if (!_showDrawer) _buildAdditionalFields(),
          if (_showCarousel) _buildCarousel(),
        ],
      ),
    );
  }

  Widget _buildGoogleMap() {
    return _isLoading || _currentPosition == null
        ? Center(child: CircularProgressIndicator())
        : GoogleMap(
      onMapCreated: ((GoogleMapController controller) =>
          _mapController.complete(controller)),
      initialCameraPosition: CameraPosition(
          target: _currentPosition!, zoom: 13),
      markers: _buildMarkers(),
      mapType: MapType.normal,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.grey[300], // Grey background color
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.grey[300], // Grey background color
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // Center items vertically
                children: [
                  CircleAvatar(
                    radius: 30.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: _profilePicBytes != null &&
                        _profilePicBytes is Uint8List
                        ? MemoryImage(
                        _profilePicBytes as Uint8List) as ImageProvider<Object>
                        : AssetImage('assets/images/unknown.jpg'),
                  ),
                  SizedBox(height: 2.0), // Reduce spacing
                  Text(
                    _fullName ?? 'Guest', // Add user's name here
                    style: TextStyle(
                      fontSize: 14.0, // Decrease font size
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5.0), // Reduce spacing
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => BottomNavigationPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent, // Button color
                      padding: EdgeInsets.symmetric(horizontal: 10.0,
                          vertical: 6.0), // Decrease button width and height
                    ),
                    child: Text(
                      'View Profile', // Add 'View Profile' button here
                      style: TextStyle(
                        fontSize: 12.0, // Decrease font size
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.0), // Reduce spacing
            ListTile(
              onTap: () {
                // Navigate to payment details page
              },
              title: Text(
                'Payment Details',
                style: TextStyle(
                    color: Colors.black, fontSize: 12.0), // Decrease font size
              ),
              trailing: Icon(
                  Icons.payment, color: Colors.black), // Add trailing icon
            ),
            ListTile(
              onTap: () {
                // Navigate to recent searches page
              },
              title: Text(
                'Recent Searches',
                style: TextStyle(
                    color: Colors.black, fontSize: 12.0), // Decrease font size
              ),
              trailing: Icon(
                  Icons.history, color: Colors.black), // Add trailing icon
            ),
            ListTile(
              onTap: () {
                // Navigate to reservation history page
              },
              title: Text(
                'Reservation History',
                style: TextStyle(
                    color: Colors.black, fontSize: 12.0), // Decrease font size
              ),
              trailing: Icon(Icons.calendar_today,
                  color: Colors.black), // Add trailing icon
            ),
            ListTile(
              onTap: () {
                // Navigate to reviews page
              },
              title: Text(
                'Reviews',
                style: TextStyle(
                    color: Colors.black, fontSize: 12.0), // Decrease font size
              ),
              trailing: Icon(
                  Icons.star, color: Colors.black), // Add trailing icon
            ),
            SizedBox(height: 50.0), // Reduce spacing
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent, // Pink accent color
                padding: EdgeInsets.symmetric(horizontal: 10.0,
                    vertical: 6.0), // Decrease button height and width
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                    fontSize: 12.0, color: Colors.white), // Decrease font size
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAdditionalFields() {
    return Positioned(
      top: 20.0,
      left: 20.0,
      right: 20.0,
      child: Container(
        padding: EdgeInsets.all(8.0), // Adjusted padding
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5), // Black with transparency
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.pinkAccent,
              width: 2.0), // Pink stroke around the container
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
                'Amount in Hand', 'Enter amount', TextInputType.number,
                _amountController),
            SizedBox(height: 12.0), // Adjusted spacing
            _buildTextField(
                'Number of People', 'Enter number', TextInputType.number,
                _peopleController),
            SizedBox(height: 12.0), // Adjusted spacing// Adjusted spacing
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reservation',
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                      SizedBox(height: 4.0),
                      Switch(
                        value: _reservation,
                        onChanged: (value) {
                          setState(() {
                            _reservation = value;
                          });
                        },
                        activeColor: Colors.pinkAccent,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _getExistingParametersAndNavigate(); // Call the function when the button is pressed
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: Text('Search', style: TextStyle(fontSize: 12.0,
                        color: Colors.white)), // Changed text color to white
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, String hintText,
      TextInputType keyboardType, TextEditingController controller) {
    print('Controller linked to text field: $controller');
    return TextFormField(
      controller: controller,
      // Assign the provided controller to the text field
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(10.0)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.pinkAccent),
            borderRadius: BorderRadius.circular(10.0)),
      ),
      keyboardType: keyboardType,
      onChanged: (value) {
        // Handle text field changes
        print('Text field value changed: $value');
      },
    );
  }


  Widget _buildCarousel() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.4, // Adjust the value to position the carousel vertically
      left: 0,
      right: 0,
      child: CarouselSlider(
        options: CarouselOptions(
          aspectRatio: 2.0,
          enlargeCenterPage: true,
          enableInfiniteScroll: false,
          initialPage: 0,
          autoPlay: true,
        ),
        items: _hotelData.map((hotelData) {
          // Ensure each hotelData is a map
          if (hotelData is Map<String, dynamic>) {
            return Builder(
              builder: (BuildContext context) {
                // Build hotel card using the provided method
                return SingleChildScrollView(
                  child: buildHotelCard(hotelData),
                  scrollDirection: Axis.vertical,
                );
              },
            );
          } else {
            // If hotelData is not a map, return an empty container
            return Container();
          }
        }).toList(),
      ),
    );
  }


  void _storeUserLocation(double latitude, double longitude) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<double> locationList = [latitude, longitude];
    prefs.setStringList(
        'userLocation', locationList.map((coord) => coord.toString()).toList());
  }

  void _getLocationUpdates() async {
    await _locationController.requestPermission();
    _locationController.onLocationChanged.listen((
        location.LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentPosition =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _currentHeading =
              currentLocation.heading ?? 0.0; // Store the current heading
          _cameraToPosition(_currentPosition!);
          _storeUserLocation(
              currentLocation.latitude!, currentLocation.longitude!);
        });
      }
    });
  }


  Widget buildHotelCard(Map<String, dynamic> hotelData) {
    // Extract hotel details from the response
    String picture = hotelData['picture'];
    String name = hotelData['name'];
    int approximateTotalBill = hotelData['approximateTotalBill'];
    double distance = hotelData['distance'];
    int starRating = hotelData['starRating'];
    String state = hotelData['type'];
    bool reservation = hotelData['reservation'];
    List<dynamic> combinations = hotelData['combinations'] ?? []; // Handle null value

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: double.infinity,
              child: Image.network(
                picture,
                fit: BoxFit.cover,
                height: 150, // Reduced height
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text('Approximate Total Bill: $approximateTotalBill'),
                  Text('Distance: $distance meters'),
                  Text('Star Rating: $starRating'),
                ],
              ),
            ),
            ExpansionTile(
              title: Text('Combinations'),
              children: combinations.map<Widget>((combination) {
                List<String> items = (combination['items'] as List<dynamic>)
                    .cast<String>(); // Handle null value
                int totalPrice = combination['totalPrice'] ?? 0; // Handle null value
                return ListTile(
                  title: Text('Items: ${items.join(', ')}'),
                  subtitle: Text('Total Price: $totalPrice'),
                );
              }).toList(),
            ),
            if (reservation)
              ElevatedButton(
                onPressed: () {
                  _storeHotelId(hotelData['hotelId']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BookingPage()),
                  );
                },
                child: Text('Make Reservation'),
              )
            else
              ElevatedButton(
                onPressed: () {
                  // Handle mix it
                },
                child: Text('Mix it'),
              ),
          ],
        ),
      ),
    );
  }

  void _fetchPlaces() {
    PlaceService.fetchPlaces().then((places) {
      List<Place> fetchedPlaces = places.map((place) => Place.fromJson(place))
          .toList();
      setState(() {
        _places = fetchedPlaces;
        _isLoading = false;
      });
    }).catchError((error) {
      print('Error fetching places: $error');
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(target: pos, zoom: 13);
    await controller.animateCamera(
        CameraUpdate.newCameraPosition(_newCameraPosition));
  }

  Set<Marker> _buildMarkers() {
    Set<Marker> markers = {};

    // Add marker for current position
    if (_currentPosition != null) {
      BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed);
      if (_currentHeading != null && _currentHeading > 0) {
        markerIcon = BitmapDescriptor.defaultMarkerWithHue(
            _currentHeading); // Use current heading for marker icon
      }
      markers.add(
        Marker(
          markerId: MarkerId("_currentLocation"),
          icon: markerIcon,
          position: _currentPosition!,
          rotation: _currentHeading ?? 0.0,
          // Use current heading for rotation
          infoWindow: InfoWindow(
            title: 'Current Location', // Show "Current Location" as marker title
          ),
        ),
      );
    }


    void _showPlaceDetails(Place place) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.black.withOpacity(0.8),
            // Black with transparency
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          place.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      place.picture, // Image URL from the place object
                      width: MediaQuery
                          .of(context)
                          .size
                          .width - 32, // Adjust width as needed
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Address: ${place.address}, ${place.city}, ${place
                        .state}, ${place.country}, ${place.postalCode}',
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow),
                      SizedBox(width: 4.0),
                      Text(
                        'Rating: ${place.starRating}',
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Food Type: ${place.foodType}',
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      // Perform action when "Book Now" button is pressed
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent, // Pink accent color
                    ),
                    child: Text(
                      'Book Now',
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }


      // Add markers for fetched places with custom icons
      for (Place place in _places) {
        BitmapDescriptor placeIcon = BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue); // Default marker icon
        if (place.foodType != null && place.foodType.isNotEmpty) {
          // Use custom icon based on food type
          placeIcon = BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen); // Example custom icon (green)
        }
        markers.add(
          Marker(
            markerId: MarkerId(place.id),
            position: LatLng(place.location.coordinates[1],
                place.location.coordinates[0]),
            icon: placeIcon, // Custom icon for fetched places
            infoWindow: InfoWindow(
              title: place.name, // Show place name as marker title
              snippet: place.foodType ?? '', // Show food type in marker snippet
            ),
            onTap: () {
              _showPlaceDetails(place);
            },
          ),
        );
      }
      return markers;
    }
  }
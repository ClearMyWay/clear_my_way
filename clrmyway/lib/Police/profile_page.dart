import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For jsonDecode and base64Decode
import 'dart:typed_data'; // For Uint8List
import '../main.dart';

class ProfilePage extends StatefulWidget {
  final String officerId;

  const ProfilePage({Key? key, required this.officerId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? officerDetails;
  bool isLoading = true;
  late GoogleMapController _mapController;
  LatLng? _currentLocation;
  bool _isSendingLocation = false;
  late IO.Socket socket; // Socket.io instance
  String etaMessage = '';
  Uint8List? officerImage;

  @override
  void initState() {
    super.initState();
    _fetchOfficerDetails();
    _getCurrentLocation();
    _connectToSocket();
  }

  // Fetch officer details from the AP

Future<void> _fetchOfficerDetails() async {
  final url = Uri.parse('https://clear-my-way-6.onrender.com/api/officers/get-details');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': widget.officerId}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('✅ Officer details fetched successfully: $data');

      setState(() {
        officerDetails = data['existingOfficer'];
        isLoading = false;
      });

      print('✅ Officer details fetched successfully: $officerDetails');
      // Assuming the officer's photo is in base64 format
      String base64Image = officerDetails?['ID'];  // Replace with actual key if necessary
      Uint8List bytes = base64Decode(base64Image); // Decode base64 image to bytes

      // Optionally store the decoded image bytes for later use
      setState(() {
        officerImage = bytes;
      });

    } else {
      print('❌ Failed to fetch officer details: ${response.statusCode}');
      _showError('❌ Failed to fetch officer details: ${response.statusCode}');
    }
  } catch (e) {
    print('⚠️ An error occurred while fetching officer details: $e');
    _showError('⚠️ An error occurred: $e');
  }
}



  // Show an error message
  void _showError(String message) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Fetch the current location of the officer
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      await _sendLocationToBackend(position.latitude, position.longitude);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to get current location, please provide permission')),
      );
    }
  }

  // Send the officer's current location to the backend
  Future<void> _sendLocationToBackend(double lat, double lng) async {
    if (_isSendingLocation) return;

    setState(() {
      _isSendingLocation = true;
    });

    try {
      final body = jsonEncode({
        'email': widget.officerId,
        'lat': lat,
        'lng': lng,
      });
      final url = Uri.parse('https://clear-my-way-6.onrender.com/api/officers/update-location');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        print('Location updated successfully');
      } else {
        print('Failed to update location: ${response.statusCode}');
      }
    } catch (e) {
      print('Error while sending location: $e');
    } finally {
      setState(() {
        _isSendingLocation = false;
      });
    }
  }

  // Connect to the WebSocket server
  void _connectToSocket() {
    socket = IO.io('https://clear-my-way-6.onrender.com/', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.on('custom_message', (data) {
      print('Received message: $data');
      // Parse message data and calculate ETA
      double destinationLat = data['currentLocation']['lat'];
      double destinationLon = data['currentLocation']['lon'];

      _calculateETA(destinationLat, destinationLon);
    });
  }

  // Calculate ETA using LocationIQ API
  Future<void> _calculateETA(double destLat, double destLon) async {
    if (_currentLocation == null) return;

    try {
      final url = Uri.parse(
        'https://us1.locationiq.com/v1/directions/driving/${_currentLocation!.longitude},${_currentLocation!.latitude};$destLon,$destLat?key=pk.6f42dd49661501bfc2d4728d87f9014e'
      );

      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final duration = data['routes'][0]['duration']; // Duration in seconds
        setState(() {
          etaMessage = 'ETA to destination: ${duration ~/ 60} minutes';
        });
      } else {
        print('Error fetching ETA');
      }
    } catch (e) {
      print('Error calculating ETA: $e');
    }
  }

  // Logout functionality
  void _logout() async {
    final response = await http.post(
      Uri.parse('https://clear-my-way-6.onrender.com/api/officers/update-location'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': widget.officerId}),
    );
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn_police', false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Police Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    //Profile Picture
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: officerImage != null
                          ? MemoryImage(officerImage!) // Use MemoryImage instead of Image.memory
                          : AssetImage('assets/images/default_profile.png') as ImageProvider, // Default image
                    ),
                    SizedBox(height: 16),

                    // Full Name
                    Text(
                      officerDetails?['name'] ?? 'Not Updated',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),

                    // Other Profile Details
                    _buildProfileDetail('Rank/Designation', officerDetails?['Designation'] ?? 'Not Updated'),
                    _buildProfileDetail('Phone Number', officerDetails?['phoneNumber'] ?? 'Not Updated'),
                    _buildProfileDetail('Email', officerDetails?['email'] ?? 'Not Updated'),
                    _buildProfileDetail('Station Name', officerDetails?['StationName'] ?? 'Not Updated'),

                    // ETA Message
                    if (etaMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          etaMessage,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),

                    // Map showing current location
                    _currentLocation == null
                        ? CircularProgressIndicator()
                        : Container(
                            height: 300,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: _currentLocation!,
                                zoom: 15,
                              ),
                              onMapCreated: (controller) {
                                _mapController = controller;
                              },
                              myLocationEnabled: true, // Enable the blue dot
                              myLocationButtonEnabled: false, // Optional: Disable default button
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        Divider(height: 24, thickness: 1),
      ],
    );
  }
}

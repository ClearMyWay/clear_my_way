import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../main.dart';

class PoliceMainScreen extends StatefulWidget {
  @override
  _PoliceMainScreenState createState() => _PoliceMainScreenState();
}

class _PoliceMainScreenState extends State<PoliceMainScreen> {
  late GoogleMapController _mapController;
  LatLng? _currentLocation;
  bool _isSendingLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  /// Fetch the current location of the officer
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update the state with the current location
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      // Send the current location to the backend
      await _sendLocationToBackend(position.latitude, position.longitude);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to get current location: $e')),
      );
    }
  }

  /// Send the officer's current location to the backend
  Future<void> _sendLocationToBackend(double lat, double lng) async {
    if (_isSendingLocation) return; // Prevent overlapping API calls

    setState(() {
      _isSendingLocation = true;
    });

    try {
      final url = Uri.parse('https://clear-my-way-6.onrender.com/api/officer/update-location'); // Replace with your backend API
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer your-auth-token', // Optional: Include a token if needed
        },
        body: jsonEncode({
          'officerId': 'unique_officer_id', // Replace with the actual officer ID
          'lat': lat,
          'lng': lng,
        }),
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

  /// Logout functionality
  void _logout() {
    // Navigate to the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Police Main Screen'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Logout when tapped
          ),
        ],
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation!,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  markers: {
                    if (_currentLocation != null)
                      Marker(
                        markerId: const MarkerId('currentLocation'),
                        position: _currentLocation!,
                        infoWindow: const InfoWindow(title: 'You are here'),
                      ),
                  },
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: _getCurrentLocation,
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}

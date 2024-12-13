import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'login.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Position? _currentPosition;
  String? _errorMsg;
  bool _hasPermission = false;
  String _searchQuery = '';
  final List<String> _suggestions = [
    'Narayana Hrudayala',
    'Aadi Hospital',
    'Vijaya Nursing Home'
  ];

  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _getLocationPermission();
  }

  Future<void> _getLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _errorMsg = "Location services are disabled. Please enable them.";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMsg = "Permission to access location was denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMsg = "Location permission is permanently denied.";
      });
      return;
    }

    setState(() {
      _hasPermission = true;
    });

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMsg = "Failed to get current location: $e";
      });
    }
  }

  void _handleSOS() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('SOS Activated'),
        content: Text('Emergency services have been notified.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AmbulanceLogin(), 
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _hasPermission && _currentPosition != null
              ? Expanded(
                  child: GoogleMap(
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      zoom: 13,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('currentLocation'),
                        position: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        infoWindow: InfoWindow(title: 'Current Location'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                      ),
                    },
                  ),
                )
              : Container(
                  height: 300,
                  color: Colors.green[50],
                  child: Center(
                    child: Text(
                      _errorMsg ?? "Map preview not available",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Search Destination",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.green[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      controller: TextEditingController(text: _searchQuery),
                    ),
                    SizedBox(height: 16),
                    Column(
                      children: _suggestions.map((suggestion) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _searchQuery = suggestion;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.grey),
                                SizedBox(width: 8),
                                Text(
                                  suggestion,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[800]),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (_currentPosition != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          "Latitude: ${_currentPosition!.latitude}, Longitude: ${_currentPosition!.longitude}",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton.extended(
              onPressed: _handleSOS,
              backgroundColor: Colors.red,
              label: Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 4),
                  Text("SOS"),
                ],
              ),
            ),
            FloatingActionButton.extended(
              onPressed: _logout,
              backgroundColor: Colors.blue,
              label: Row(
                children: [
                  Icon(Icons.logout, color: Colors.white),
                  SizedBox(width: 4),
                  Text("Logout"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

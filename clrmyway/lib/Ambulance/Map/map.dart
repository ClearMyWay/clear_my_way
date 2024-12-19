import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'search_screen.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  LatLng? _currentLocation;
  LatLng? _pickUpLocation;
  LatLng? _dropOffLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to get current location: $e')),
      );
    }
  }

  Future<void> _navigateAndGetLocation(BuildContext context, bool isPickUp) async {
    // Navigate to the FormScreen and get the selected location
    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormScreen()),
    );

    if (selectedLocation != null) {
      setState(() {
        if (isPickUp) {
          _pickUpLocation = selectedLocation;
        } else {
          _dropOffLocation = selectedLocation;
        }
      });

      // Update the camera position to the selected location
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(selectedLocation, 15),
      );
    }
  }

  void _showSosSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('SOS - Help Needed'),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Screen'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _currentLocation == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
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
                    if (_pickUpLocation != null)
                      Marker(
                        markerId: const MarkerId('pickUpLocation'),
                        position: _pickUpLocation!,
                        infoWindow: const InfoWindow(title: 'Pick-Up Location'),
                      ),
                    if (_dropOffLocation != null)
                      Marker(
                        markerId: const MarkerId('dropOffLocation'),
                        position: _dropOffLocation!,
                        infoWindow: const InfoWindow(title: 'Drop-Off Location'),
                      ),
                  },
                ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Row(
              children: [
                _buildPickLocationSnackBar('Pick-Up Location'),
                const SizedBox(width: 10),
                _buildDropLocationSnackBar('Drop-Off Location'),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: GestureDetector(
              onTap: _showSosSnackBar,  // Show SOS snackbar when tapped
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'SOS',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickLocationSnackBar(String title) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _navigateAndGetLocation(context, true); // true for pick-up
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildDropLocationSnackBar(String title) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _navigateAndGetLocation(context, false); // false for drop-off
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}

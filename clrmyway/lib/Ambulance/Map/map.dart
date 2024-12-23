// MapScreen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'search_screen.dart';

class MapScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLon;

  const MapScreen({this.initialLat, this.initialLon, Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  LatLng? _currentLocation;
  LatLng? _destinationLocation;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLon != null) {
      _currentLocation = LatLng(widget.initialLat!, widget.initialLon!);
    } else {
      _getCurrentLocation();
    }
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

  Future<void> _searchDestination() async {
    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormScreen()),
    );

    if (selectedLocation != null) {
      setState(() {
        _destinationLocation = LatLng(
          double.parse(selectedLocation['lat']),
          double.parse(selectedLocation['lon']),
        );
      });

      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_destinationLocation!, 15),
      );
    }
  }

  Future<void> _fetchRoute() async {
    if (_currentLocation == null || _destinationLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Both locations must be selected for routing')),
      );
      return;
    }

    final String apiKey = "pk.6f42dd49661501bfc2d4728d87f9014e";
    final String url =
        "https://us1.locationiq.com/v1/directions/driving/${_currentLocation!.longitude},${_currentLocation!.latitude};${_destinationLocation!.longitude},${_destinationLocation!.latitude}?key=$apiKey&steps=true&alternatives=true&geometries=polyline&overview=full";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final polyline = data['routes'][0]['geometry'];
        setState(() {
          _routePoints = _decodePolyline(polyline);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch route: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching route: $e')),
      );
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
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
                    if (_destinationLocation != null)
                      Marker(
                        markerId: const MarkerId('destinationLocation'),
                        position: _destinationLocation!,
                        infoWindow: const InfoWindow(title: 'Destination Location'),
                      ),
                  },
                  polylines: {
                    if (_routePoints.isNotEmpty)
                      Polyline(
                        polylineId: const PolylineId('route'),
                        color: Colors.blue,
                        width: 5,
                        points: _routePoints,
                      ),
                  },
                ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: GestureDetector(
              onTap: _searchDestination,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: const Text(
                  '🔍 Search for Destination',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 10,
            child: GestureDetector(
              onTap: _fetchRoute,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'SOS',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
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
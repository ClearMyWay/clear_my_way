import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String officerId;

  const ProfilePage({Key? key, required this.officerId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? officerDetails;
  bool isLoading = true;
  String badgeImageBase64 = '';

  @override
  void initState() {
    super.initState();
    _fetchOfficerDetails();
  }

  // Fetch officer details from the API
  Future<void> _fetchOfficerDetails() async {
    final url = Uri.parse('https://clear-my-way-6.onrender.com/api/officers/get-details');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.officerId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          officerDetails = data['officer'];
          badgeImageBase64 = officerDetails?['badgeId'] ?? '';
          isLoading = false;
        });
      } else {
        _showError('Failed to fetch officer details: ${response.statusCode}');
      }
    } catch (e) {
      _showError('An error occurred: $e');
    }
  }

  // Helper to display error
  void _showError(String message) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Convert Base64 to Image widget
  Widget _buildBadgeImage() {
    if (badgeImageBase64.isEmpty) {
      return CircleAvatar(
        radius: 50,
        child: Icon(Icons.image, size: 50),
      );
    }
    
    // Decode base64 and convert it into an image
    Uint8List bytes = base64Decode(badgeImageBase64);
    return CircleAvatar(
      radius: 50,
      backgroundImage: MemoryImage(bytes),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Police Profile'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildBadgeImage(), // Display badge image
                    SizedBox(height: 16),

                    // Full Name
                    Text(
                      officerDetails?['name'] ?? 'Not Updated',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),

                    // Other Profile Details
                    _buildProfileDetail('Badge ID', officerDetails?['badgeId'] ?? 'Not Updated'),
                    _buildProfileDetail('Rank/Designation', officerDetails?['rank'] ?? 'Not Updated'),
                    _buildProfileDetail('Phone Number', officerDetails?['phoneNumber'] ?? 'Not Updated'),
                    _buildProfileDetail('Email', officerDetails?['email'] ?? 'Not Updated'),
                    _buildProfileDetail('Station Name', officerDetails?['stationName'] ?? 'Not Updated'),
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

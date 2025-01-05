import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FormScreen extends StatefulWidget {
  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  List<dynamic> suggestions = [];
  TextEditingController _controller = TextEditingController();
  String locationIQApiKey = "pk.6f42dd49661501bfc2d4728d87f9014e";

  // Fetch autocomplete suggestions
  Future<void> fetchSuggestions(String query) async {
    final url = Uri.parse(
        'https://api.locationiq.com/v1/autocomplete?key=$locationIQApiKey&q=$query&limit=5&dedupe=1');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          suggestions = jsonDecode(response.body);
        });
      } else {
        debugPrint('Error fetching suggestions: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception while fetching suggestions: $e');
    }
  }

  // Fetch place details
  Future<void> fetchPlaceDetails(String query) async {
    final url = Uri.parse(
        'https://us1.locationiq.com/v1/search?key=$locationIQApiKey&q=$query&format=json');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List<dynamic> && data.isNotEmpty) {
          final lat = data[0]['lat'];
          final lon = data[0]['lon'];

          Navigator.pop(context, {'lat': lat, 'lon': lon});
        } else {
          debugPrint('Unexpected response format: $data');
        }
      } else {
        debugPrint('Error fetching place details: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception while fetching place details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Location'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search TextField with suggestions
            TextField(
              controller: _controller,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  fetchSuggestions(value);
                } else {
                  setState(() {
                    suggestions = [];
                  });
                }
              },
              decoration: InputDecoration(
                hintText: "Search location...",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            // Display autocomplete suggestions
            Expanded(
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return ListTile(
                    title: Text(suggestion['display_name'] ?? 'Unknown'),
                    onTap: () {
                      fetchPlaceDetails(suggestion['display_name'] ?? '');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
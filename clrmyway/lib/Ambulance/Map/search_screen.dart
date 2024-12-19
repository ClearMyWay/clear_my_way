import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_places_suggestions_autocomplete_field/google_places_suggestions_autocomplete_field.dart';

class FormScreen extends StatefulWidget {
  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  String? resultObject;  // Variable to hold selected location data
  TextEditingController _controller = TextEditingController();  // Persistent controller

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
            // Google Places Autocomplete Field
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              height: 50,
              width: double.infinity,
              child: GooglePlacesSuggestionsAutoCompleteField(
                controller: _controller,  // Use the persistent controller
                googleAPIKey: "AIzaSyBr3hQE4DvdH6bye1wJE4UM5YFG8KhDmAw", // Replace with your API Key
                countries: "in", // Country filter for India
                onPlaceSelected: (place) {
                  // Debugging the place selection
                  try {
                    final placeJson = jsonEncode(place.toJson());
                    debugPrint("Selected place: $placeJson");
                    setState(() {
                      resultObject = placeJson;
                    });
                  } catch (e) {
                    debugPrint("Error parsing place: $e");
                  }
                },
              ),
            ),
            // Display selected location details if available
            if (resultObject != null)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: Text("Returned Location: $resultObject"),
              ),
          ],
        ),
      ),
    );
  }
}

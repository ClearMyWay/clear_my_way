import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'DriverForm.dart';
import 'dart:convert';



class AddVehicleDetails extends StatefulWidget {
  @override
  _AddVehicleDetailsState createState() => _AddVehicleDetailsState();
}

class _AddVehicleDetailsState extends State<AddVehicleDetails> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {
    'agency': '',
    'vehicleNo': '',
    'vehicleModel': '',
    'ownerNumber': '',
    'rcNo': '',
    'vehicleColor': '',
  };
  String? _vehiclePhotoPath;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _vehiclePhotoPath = image.path;
      });
    } else {
      print("No image selected");
    }
  }

 

Future<String?> encodeFileToBase64(String filePath) async {
  try {
    final bytes = await File(filePath).readAsBytes();
    return base64Encode(bytes);
  } catch (e) {
    print('Error encoding file: $e');
    return null;
  }
}

Future<void> _handleSubmit() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save(); // Save the form data to the _formData map

    final base64Photo = await encodeFileToBase64(_vehiclePhotoPath!);

    if (base64Photo == null) {
      print('❌ Failed to encode photo.');
      return;
    }

    final payload = {
      "agency": _formData['agency'],
      "vehicleNumber": _formData['vehicleNo'],
      "vehicleModel": _formData['vehicleModel'],
      "ownerNumber": _formData['ownerNumber'],
      "rcNumber": _formData['rcNo'],
      "vehicleColor": _formData['vehicleColor'],
      "vehiclePhoto": base64Photo,
    };

    print("Payload: $payload");

    final url = Uri.parse('https://clear-my-way-6.onrender.com/api/vehicles/VehicleDetails');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201) {
      print('🎉 Vehicle details submitted successfully!');
      Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDriverDetails(_formData['ownerNumber']!)),
            );
    } else {
      print('❌ Failed to submit details. Status Code: ${response.statusCode}');
    }
  } else {
    print('❌ Form validation failed.');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context,  MaterialPageRoute(builder: (context) => AmbulanceLogin()),);
          },
       )
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Display the logo at the top
              Image.asset(
                'assets/images/logo.png',
                height: 120,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 16),
              Text('Add Ambulance Details', style: TextStyle(fontSize: 24)),
              SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField('agency', 'Enter your agnecy', 'agency'),
                    SizedBox(height: 16),
                    _buildTextField('Vehicle No.', 'Enter your vehicle number', 'vehicleNo'),
                    SizedBox(height: 16),
                    _buildTextField('Vehicle Model', 'Enter your vehicle model', 'vehicleModel'),
                    SizedBox(height: 16),
                    _buildTextField('Owner Number', 'Enter owner number', 'ownerNumber'),
                    SizedBox(height: 16),
                    _buildTextField('RC No.', 'Enter your RC number', 'rcNo'),
                    SizedBox(height: 16),
                    _buildTextField('Vehicle Colour', 'Enter your vehicle colour', 'vehicleColor'),
                    SizedBox(height: 16),
                    Text('Add Vehicle Photo', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFF008F4C)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: _vehiclePhotoPath == null
                              ? Icon(Icons.camera_alt, color: Colors.grey, size: 50)
                              : Image.file(File(_vehiclePhotoPath!), fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF008F4C),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: Center(child: Text('Continue')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String placeholder, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        TextFormField(
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(),
          ),
          onSaved: (value) => _formData[key] = value!,
          validator: (value) => value?.isEmpty ?? true ? '$label is required' : null,
        ),
      ],
    );
  }

 
}

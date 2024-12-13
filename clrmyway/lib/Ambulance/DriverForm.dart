import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'SignUp.dart';

class AddDriverDetails extends StatefulWidget {
  @override
  _AddDriverDetailsState createState() => _AddDriverDetailsState();
}

class _AddDriverDetailsState extends State<AddDriverDetails> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {
    'driverName': '',
    'gender': '',
    'dob': '',
    'email': '',
    'phoneNumber': '',
    'licenseNumber': '',
  };
  String? _licensePhotoPath;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery); // You can also use ImageSource.camera if you want to capture from the camera

    if (image != null) {
      setState(() {
        _licensePhotoPath = image.path;
      });
    } else {
      print("No image selected");
    }
  }

  void _handleSubmit() {
    // if (_formKey.currentState?.validate() ?? false) {
    //   _formKey.currentState?.save();
    //   print('Form Data: $_formData');
    //   print('Vehicle Photo: ${_vehiclePhotoPath ?? "No photo selected"}');

    //   // Navigate to DriverForm.dart
    // }
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DriverSignUp(), 
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Add Driver Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Logo
              Image.asset(
                'assets/images/logo.png',
                height: 120,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 16),
              Text('Add Driver Details', style: TextStyle(fontSize: 24)),
              SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField('Driver Name', 'Enter vehicle owner name', 'driverName'),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            'Gender',
                            'Gender',
                            'gender',
                            [
                              DropdownMenuItem(value: '', child: Text('Gender')),
                              DropdownMenuItem(value: 'male', child: Text('Male')),
                              DropdownMenuItem(value: 'female', child: Text('Female')),
                              DropdownMenuItem(value: 'other', child: Text('Other')),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField('DOB', 'DD/MM/YYYY', 'dob'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildTextField('Email', 'Enter your Email', 'email'),
                    SizedBox(height: 16),
                    _buildTextField('Phone Number', 'Enter your 10 digit phone number', 'phoneNumber'),
                    SizedBox(height: 16),
                    _buildTextField('License Number', 'Enter driver\'s driving license number', 'licenseNumber'),
                    SizedBox(height: 16),
                    Text('Add Driving License Photo', style: TextStyle(fontSize: 16)),
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
                          child: _licensePhotoPath == null
                              ? Icon(Icons.camera_alt, color: Colors.grey, size: 50)
                              : Image.file(File(_licensePhotoPath!), fit: BoxFit.cover),
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

  Widget _buildDropdownField(String label, String placeholder, String key, List<DropdownMenuItem<String>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        DropdownButtonFormField<String>(
          value: _formData[key],
          onChanged: (value) => setState(() {
            _formData[key] = value!;
          }),
          items: items,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          validator: (value) => value == '' ? 'Please select $label' : null,
        ),
      ],
    );
  }
}

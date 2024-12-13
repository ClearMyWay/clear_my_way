import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'SignUp.dart';
import 'login.dart';
import 'dart:io';

class AddPersonalInfo extends StatefulWidget {
  @override
  _AddPersonalInfoState createState() => _AddPersonalInfoState();
}

class _AddPersonalInfoState extends State<AddPersonalInfo> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {
    'fullName': '',
    'badgeId': '',
    'rank': '',
    'phoneNumber': '',
    'email': '',
    'stationName': '',
  };
  String? _idCardPhotoPath;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _idCardPhotoPath = image.path;
      });
    } else {
      print("No image selected");
    }
  }

  void _handleSubmit() {
    // if (_formKey.currentState?.validate() ?? false) {
    //   _formKey.currentState?.save();
    //   print('Form Data: $_formData');
    //   print('ID Card Photo: ${_idCardPhotoPath ?? "No photo selected"}');
    // }
     Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PoliceSignUp(), 
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
            Navigator.pushReplacement(context,  MaterialPageRoute(builder: (context) => PoliceLogin()),);
          },
       )
      ),
      backgroundColor: Colors.white,
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
              Text('Add Personal Info', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField('Full Name', 'Enter your full name', 'fullName'),
                    SizedBox(height: 16),
                    _buildTextField('Badge/ID Number', 'Enter your badge/ID number', 'badgeId'),
                    SizedBox(height: 16),
                    _buildTextField('Rank/Designation', 'Enter your rank/designation', 'rank'),
                    SizedBox(height: 16),
                    _buildTextField('Phone Number', 'Enter your phone number', 'phoneNumber'),
                    SizedBox(height: 16),
                    _buildTextField('Email Address', 'Enter your email address', 'email'),
                    SizedBox(height: 16),
                    _buildDropdownField(
                      'Station Name',
                      'Select your station',
                      'stationName',
                      [
                        DropdownMenuItem(value: '', child: Text('Select your station')),
                        DropdownMenuItem(value: 'Station 1', child: Text('Station 1')),
                        DropdownMenuItem(value: 'Station 2', child: Text('Station 2')),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text('Add ID Card Photo', style: TextStyle(fontSize: 16)),
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
                          child: _idCardPhotoPath == null
                              ? Icon(Icons.camera_alt, color: Colors.grey, size: 50)
                              : Image.file(File(_idCardPhotoPath!), fit: BoxFit.cover),
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

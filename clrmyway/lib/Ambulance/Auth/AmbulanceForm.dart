import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'login.dart';
import 'DriverForm.dart';
import 'package:http_parser/http_parser.dart';



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

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final agency = _formData['agency'];
      final vehicleNo = _formData['vehicleNo'];
      final vehicleModel = _formData['vehicleModel'];
      final ownerNumber = _formData['ownerNumber'];
      final rcNo = _formData['rcNo'];
      final vehicleColor = _formData['vehicleColor'];

      // Prepare the form data for the request
      final url = Uri.parse('${dotenv.env['BASE_URL']}/api/vehicles/VehicleDetails');

      // Create multipart request
      var request = http.MultipartRequest('POST', url)
        ..fields['Agency'] = agency!
        ..fields['vehicleNumber'] = vehicleNo!
        ..fields['vehicleModel'] = vehicleModel!
        ..fields['ownerNumber'] = ownerNumber!
        ..fields['rcNumber'] = rcNo!
        ..fields['vehicleColor'] = vehicleColor!;

      // Add image as multipart file if available
      if (_vehiclePhotoPath != null) {
        var imageFile = await http.MultipartFile.fromPath(
          'vehiclePhoto', 
          _vehiclePhotoPath!,
          contentType: MediaType('image', 'png'),
        );
        request.files.add(imageFile);
      }

      try {
        // Send the request
        var response = await request.send();

        if (response.statusCode == 201) {
          print('Vehicle details submitted successfully');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDriverDetails(_formData['ownerNumber']!)),
            );
        } else {
          print('Failed to submit vehicle details: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
      }
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
                    _buildDropdownField('Agency', 'Select your agency', 'agency', [
                      DropdownMenuItem(value: '', child: Text('Select your agency')),
                      DropdownMenuItem(value: 'agency1', child: Text('Agency 1')),
                      DropdownMenuItem(value: 'agency2', child: Text('Agency 2')),
                    ]),
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

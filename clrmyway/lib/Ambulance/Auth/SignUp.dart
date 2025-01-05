import 'package:flutter/material.dart';
import 'otp.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class DriverSignUp extends StatefulWidget {
  final String ownerNumber;
  DriverSignUp(this.ownerNumber);
  @override
  _DriverSignUpState createState() => _DriverSignUpState();
}

class _DriverSignUpState extends State<DriverSignUp> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {
    'Vehicleno.': '',
    'password': '',
    'confirmPassword': '',
  };
  bool _acceptTerms = false;

 void _handleSubmit() async {
  if (_acceptTerms) {
    _formKey.currentState!.save();

    final url = 'https://clear-my-way-6.onrender.com/api/vehicles/sign-up'; 
    final Map<String, String> body = {
      'ownerNumber': widget.ownerNumber,
      'vehicleNumber': _formData['Vehicleno.']!,
      'Password': _formData['password']!,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(phoneNumber: widget.ownerNumber),
          ),
        );
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Error occurred')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error occurred')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please complete the form correctly')),
    );
  }
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
        title: Text('Driver Sign-Up'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Logo
              Image.asset(
                'assets/images/logo.png', // Replace with your logo
                height: 120,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 16),
              Text('Driver Sign-Up', style: TextStyle(fontSize: 24)),
              SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField('Vehicle no.', 'Enter your vehicle number', 'Vehicleno.'),
                    SizedBox(height: 16),
                    _buildTextField('Password', 'Enter your password', 'password', obscureText: true),
                    SizedBox(height: 16),
                    _buildTextField('Confirm password', 'Re-enter your password', 'confirmPassword', obscureText: true),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptTerms = value!;
                            });
                          },
                        ),
                        Expanded(
                          child: Text('Accept all Privacy policy & Terms & conditions'),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF008F4C),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: Center(child: Text('Verify OTP')),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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

  Widget _buildTextField(String label, String placeholder, String key, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        TextFormField(
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(),
          ),
          obscureText: obscureText,
          onSaved: (value) => _formData[key] = value!,
          validator: (value) => value?.isEmpty ?? true ? '$label is required' : null,
          keyboardType: key == 'phoneNumber' ? TextInputType.phone : TextInputType.text,
        ),
      ],
    );
  }
}

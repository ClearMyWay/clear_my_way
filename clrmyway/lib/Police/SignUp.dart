import 'package:flutter/material.dart';
import 'otp.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


class PoliceSignUp extends StatefulWidget {
  final String phoneNumber;
  PoliceSignUp({required this.phoneNumber}) ;
  @override
  _PoliceState createState() => _PoliceState();
}

class _PoliceState extends State<PoliceSignUp> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {
    'phoneNumber'
    'username': '',
    'password': '',
    'confirmPassword': '',
  };
  bool _acceptTerms = false;

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final username = _formData['username']!;
      final phoneNumber = widget.phoneNumber;  // Phone number passed from previous screen
      final password = _formData['password']!;

      // Send data to the backend API for registration
      final url = Uri.parse('${dotenv.env['BASE_URL']}/api/officer/sign-up');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'Username': username,
          'mobileNumber': phoneNumber,
          'Password': password,
        }),
      );

      if (response.statusCode == 201) {
        // Successfully created officer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(phoneNumber: widget.phoneNumber),
          ),
        );
      } else {
        // Handle errors or failure
        print('Failed to sign up: ${response.body}');
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
                'assets/images/logo.png',
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
                    _buildTextField('Username', 'Enter a new username', 'username'),
                    SizedBox(height: 16),
                    _buildTextField('PhoneNumber', 'Enter a new PhoneNumber', 'PhoneNumber'),
                    SizedBox(height: 16),
                    _buildTextField('Password', 'Enter your password', 'password', obscureText: true),
                    SizedBox(height: 16),
                    _buildTextField('Confirm password', 'Re-enter password', 'confirmPassword', obscureText: true),
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
                      child: Center(child: Text('Sign-Up')),
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
        ),
      ],
    );
  }
}

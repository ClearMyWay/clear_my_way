import 'package:flutter/material.dart';
import 'otp.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


class PoliceSignUp extends StatefulWidget {
  final String phoneNumber;
  PoliceSignUp({required this.phoneNumber});
  
  @override
  _PoliceState createState() => _PoliceState();
}

class _PoliceState extends State<PoliceSignUp> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {
    'username': '',
    'password': '',
    'confirmPassword': '',
  };
  bool _acceptTerms = false;

 Future<void> _handleSubmit() async {
  print('🔍 Validating form...'); // Log form validation process
  
  if (_formKey.currentState?.validate() ?? false) {
    print('✅ Form is valid!'); // Log successful validation
    _formKey.currentState?.save();

    final username = _formData['username']!;
    final phoneNumber = widget.phoneNumber;
    final password = _formData['password']!;

    // Prepare the URL and the request body
    print('🌐 Preparing request...'); // Log request preparation
    final url = Uri.parse('https://clear-my-way-6.onrender.com/api/officers/sign-up');
    print('🔗 Sending POST request to: $url'); // Log the URL being called

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': username,
        'mobileNumber': phoneNumber,
        'Password': password,
      }),
    );

    if (response.statusCode == 200) {
      print('✅ Sign-up successful! 🎉'); // Log success response
      // Successfully created officer, handle the JWT token response
      final responseBody = json.decode(response.body);
      final token = responseBody['token']; // JWT token from the response
      print('🎫 Received JWT Token: $token'); // Log the received token

      // Navigate to OTP screen with token if needed
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(
            phoneNumber: widget.phoneNumber,
            // Pass token if needed in OTP screen
          ),
        ),
      );
    } else {
      // Handle errors or failure
      print('❌ Error: Sign-up failed! 🛑'); // Log failure response
      final errorResponse = json.decode(response.body);
      print('⚠️ Error message: ${errorResponse['message']}'); // Log error message

      // Show error message to the user
      _showErrorDialog(errorResponse['message']);
    }
  } else {
    print('❌ Form validation failed! ⚠️'); // Log validation failure
  }
}


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
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
        title: Text('Officer Sign-Up'),
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
              Text('Officer Sign-Up', style: TextStyle(fontSize: 24)),
              SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField('email', 'Enter your email same as previous', 'username'),
                    SizedBox(height: 16),
                    _buildTextField('PhoneNumber', 'Enter your Phone Number', 'PhoneNumber'),
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
                          child: Text('Accept Privacy policy & Terms & conditions'),
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

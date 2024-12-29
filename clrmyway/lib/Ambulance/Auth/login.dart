import 'package:flutter/material.dart';
import 'AmbulanceForm.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../Map/map.dart';
import 'dart:convert';

class AmbulanceLogin extends StatefulWidget {
  @override
  _AmbulanceLoginState createState() => _AmbulanceLoginState();
}

class _AmbulanceLoginState extends State<AmbulanceLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
  final vehicleNumber = _usernameController.text;
  final password = _passwordController.text;

  if (vehicleNumber.isEmpty || password.isEmpty) {
    // Show a message if the fields are empty
    print('🚨 Error: Please enter both vehicle number and password');
    return _showError('Please enter both vehicle number and password');
  }

  // Prepare the login data
  final loginData = {
    'vehicleNumber': vehicleNumber,
    'Password': password,
  };

  // API URL from .env
  final String url = 'https://clear-my-way-6.onrender.com/api/vehicles/login';

  try {
    print('🔍 Attempting to send login request...');
    // Send POST request
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(loginData),
    );

    print('📡 Response received: Status Code ${response.statusCode}');

    // Check response status
    if (response.statusCode == 200) {
      print('✅ Login successful! Navigating to the map screen...');
      // Navigate to the Map screen on successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MapScreen()),
      );
    } else {
      // Show error message if login fails
      final responseBody = json.decode(response.body);
      print('❌ Login failed: ${responseBody['message']}');
      _showError(responseBody['message'] ?? 'Login failed');
    }
  } catch (error) {
    print('🚨 Error occurred during login: $error');
    _showError('An error occurred: $error');
  }
}


  // Function to show error message
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 400,
                  height: 200,
                ),
              ),
              SizedBox(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Vehicle Number Input
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Vehicle Number',
                          hintText: 'Enter your vehicle number',
                          prefixIcon: Icon(Icons.directions_car),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Password Input
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Handle forgot password
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      ),

                      // Login Button
                      ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF008F4C),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Signup Link
                      GestureDetector(
                        onTap: () {
                          // Navigate to Add Vehicle screen and replace the current screen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => AddVehicleDetails()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an Account? ",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: 'SignUp',
                                style: TextStyle(
                                  color: Color(0xFF008F4C),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

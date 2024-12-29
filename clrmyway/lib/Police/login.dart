import 'package:flutter/material.dart';
import 'dart:convert';
import 'PoliceDetails.dart';
import 'package:http/http.dart' as http;
import 'Police_main.dart';

class PoliceLogin extends StatefulWidget {
  @override
  _PoliceLoginState createState() => _PoliceLoginState();
}

class _PoliceLoginState extends State<PoliceLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
  final String username = _usernameController.text.trim();
  final String password = _passwordController.text.trim();
  print('$username, $password');

  if (username.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Username and password are required')),
    );
    return;
  }

  try {
    print("🔍 Sending login request...");

    final response = await http.post(
      Uri.parse('https://clear-my-way-6.onrender.com/api/officer/login'), 
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'Username': username,
        'Password': password,
      }),
    );
    print(response.statusCode);

    if (response.statusCode == 200) {
      print("✅ Login successful!");

      // You can save the token locally using shared_preferences or any other method
      // For now, just print it
      print("🎫 Token received!");

      // Navigate to the next screen after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PoliceMainScreen()), // Pass the token to the next screen
      );
    } else {
      final responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'] ?? 'Login failed')),
      );
      print("❌ Login failed: ${responseData['message']}");
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $error')),
    );
    print("⚠️ Error during login: $error");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView( // Wrap the content in SingleChildScrollView
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    'assets/images/logo.png', // Replace with police-specific logo if available
                    width: 400,
                    height: 200,
                  ),
                ),
                SizedBox(height: 40),

                // Username Input
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter your username',
                    prefixIcon: Icon(Icons.person),
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
                    // Navigate to SignUp screen for police and replace the current screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AddPersonalInfo()),
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
                          text: 'SignUP',
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
      ),
    );
  }
}

import 'dart:convert'; // For encoding the request body
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './login.dart'; // Replace with the correct path to your Login page

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  OtpScreen({required this.phoneNumber});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController _otpController = TextEditingController();

  // Function to verify OTP
  Future<void> verifyOtp() async {
    String otp = _otpController.text;
    String phoneNumber = widget.phoneNumber;

    if (otp.isEmpty) {
      print('❌ Please enter OTP'); // Log missing OTP
      return;
    }

    print('🔐 Verifying OTP...'); // Log OTP verification start

    // Send OTP and phone number to the backend
    try {
      print('🌐 Sending OTP and phone number to backend...'); // Log request to backend
      final response = await http.post(
        Uri.parse('https://clear-my-way-6.onrender.com/otp/login/verify'), // Updated API endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'otp': otp, 'number': phoneNumber}),
      );

      if (response.statusCode == 200) {
        print('✅ OTP verified successfully! 🎉'); // Log success
        // Navigate to LoginPage on success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PoliceLogin(), // Replace with your actual LoginPage widget
          ),
        );
      } else {
        // If OTP verification fails
        final responseData = json.decode(response.body);
        print('❌ Error: ${responseData['msg']} ⚠️'); // Log failure and message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text(responseData['msg']),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      print('❌ Error verifying OTP: $error ⚠️'); // Log error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Something went wrong. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Function to resend OTP
  Future<void> resendOtp() async {
    print('🔄 Resending OTP...'); // Log resend OTP request

    try {
      final response = await http.post(
        Uri.parse('https://clear-my-way-6.onrender.com/otp/sign-up'), // Updated API endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'number': widget.phoneNumber}),
      );

      if (response.statusCode == 200) {
        print('✅ OTP resent successfully to ${widget.phoneNumber} 🎉'); // Log success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP resent successfully')),
        );
      } else {
        final responseData = json.decode(response.body);
        print('❌ Error: ${responseData['msg']} ⚠️'); // Log failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['msg'])),
        );
      }
    } catch (error) {
      print('❌ Error resending OTP: $error ⚠️'); // Log error during resend
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('📲 OTP screen loaded'); // Log screen loading

    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo at the top
            Image.asset(
              'assets/images/logo.png',
              height: 200,
              width: 500,
            ),
            const SizedBox(height: 30),

            // Display phone number at the top
            Text(
              'OTP sent to Phone Number: ${widget.phoneNumber}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // OTP TextField
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(
                hintText: 'OTP',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Verify OTP Button
            ElevatedButton(
              onPressed: verifyOtp,
              child: const Text('Verify OTP'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                backgroundColor: Color(0xFF008F4C),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),

            // Resend OTP Button
            ElevatedButton(
              onPressed: resendOtp,
              child: const Text('Resend OTP'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                backgroundColor: Colors.grey,
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

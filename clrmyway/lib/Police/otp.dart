import 'dart:convert';  // For encoding the request body
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

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
      print('Please enter OTP');
      return;
    }

    // Send OTP and phone number to the backend
    try {
      final response = await http.post(
        Uri.parse('http://192.168.162.250:3000/otp/login/verify'),  // Replace with your actual API URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'otp': otp, 'number': phoneNumber}),
      );

      if (response.statusCode == 200) {
        // If the response is successful, navigate to PoliceLogin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PoliceLogin(),
          ),
        );
      } else {
        // If OTP verification fails
        final responseData = json.decode(response.body);
        print('Error: ${responseData['msg']}');
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
      print('Error verifying OTP: $error');
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
    // Add your logic here to resend OTP
    print('Resending OTP to phone number: ${widget.phoneNumber}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(  // Wrap the body in a SingleChildScrollView
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

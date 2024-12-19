import 'package:flutter/material.dart';
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
  void verifyOtp() {
    String otp = _otpController.text;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AmbulanceLogin(),
      ),
    );
    // Implement OTP verification logic here
    if (otp.isNotEmpty) {
      // For now, just print the OTP and phone number
      print('Verifying OTP: $otp for phone number: ${widget.phoneNumber}');
    } else {
      print('Please enter OTP');
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
              'otp sent to Phone Number: ${widget.phoneNumber}',
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
              onPressed: () {
                verifyOtp();
              },
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
              onPressed: () {
                resendOtp();
              },
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

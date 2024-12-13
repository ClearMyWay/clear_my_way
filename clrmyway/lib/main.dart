import 'package:flutter/material.dart';
import './Ambulance/login.dart';
import './Police/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView( // Wrap the body in SingleChildScrollView
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sign-in Text
                SizedBox(height: 20),

                // Logo Container
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 400,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 40),

                // Menu Item 1: Ambulance
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to AmbulanceLogin screen and replace the current screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => AmbulanceLogin()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE8F5E9),
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/ambulance.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Ambulance',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Menu Item 2: Traffic Police
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to PoliceLogin screen and replace the current screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => PoliceLogin()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE8F5E9),
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/officer.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Traffic Police',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF333333),
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
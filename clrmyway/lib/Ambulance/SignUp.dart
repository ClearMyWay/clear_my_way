import 'package:flutter/material.dart';
import 'login.dart';

class DriverSignUp extends StatefulWidget {
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

  void _handleSubmit() {
    // if (_formKey.currentState?.validate() ?? false) {
    //   _formKey.currentState?.save();
    //   print('Form Data: $_formData');
    //   // Add form submission logic here
    // }
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AmbulanceLogin(), 
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
                    _buildTextField('Vehicle no.', 'Enter a new Vehicle no.', 'Vehicleno.'),
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

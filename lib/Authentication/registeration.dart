import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:vedio_player/Authentication/enter_code_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = '';
  bool _isLoading = false;

  @override
  void initState() {
    // Disable screenshots and screen recording
    FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.asset(
                'assets/images/mobile_validation.jpg',
                height: MediaQuery.sizeOf(context).height / 2,
              ),
              Text(
                "Add Your Phone Number",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "Please enter your phone number",
                style: TextStyle(
                    fontWeight: FontWeight.normal, color: Colors.grey),
              ),
              SizedBox(height: 28),
              Container(
                height: 150,
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: IntlPhoneField(
                        readOnly: true,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            counterText: ''),
                        initialCountryCode: 'IN',
                        onChanged: (phone) {
                          print(phone.countryCode);
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          hintText: '0-000-00-000',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone number is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              MaterialButton(
                minWidth: MediaQuery.sizeOf(context).width,
                height: 50,
                color: Color.fromARGB(255, 17, 136, 93),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      )
                    : Text(
                        'Register',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _register() async {
    setState(() {
      _isLoading = true;
    });

    final String phoneNo = _phoneController.text.trim();

    await _auth.verifyPhoneNumber(
      phoneNumber: '+91$phoneNo',
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
        setState(() {
          _isLoading = false;
        });
      },
      verificationFailed: (exception) {
        print('Error during registration: $exception');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during registration: $exception'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      },
      codeSent: (verificationId, resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnterCodeScreen(_verificationId),
          ),
        );
      },
      codeAutoRetrievalTimeout: (verificationId) {
        setState(() {
          _isLoading = false;
        });
      },
    );
  }
}

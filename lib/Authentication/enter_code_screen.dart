import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:vedio_player/vedio_player/video_player_page.dart';

class EnterCodeScreen extends StatefulWidget {
  final String verificationId;
  const EnterCodeScreen(this.verificationId, {Key? key}) : super(key: key);

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  final OtpFieldController otpController = OtpFieldController();
  String? _otpValue;
  bool _isLoading = false;
  Timer? _resendTimer;
  int _resendIntervalInSeconds = 120; // 2 minutes

  @override
  void initState() {
    FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    startResendTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter Verification Code')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.asset(
                'assets/images/mobile_validation.jpg',
                height: MediaQuery.of(context).size.height / 2,
              ),
              Text(
                "Verification Code",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "Please enter the 6 digit number that we send to ",
                style: TextStyle(
                    fontWeight: FontWeight.normal, color: Colors.grey),
              ),
              SizedBox(height: 28),
              Container(
                height: 100,
                color: Colors.white,
                child: OTPTextField(
                  controller: otpController,
                  length: 6,
                  width: MediaQuery.of(context).size.width,
                  fieldWidth: 40,
                  style: TextStyle(fontSize: 16),
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  fieldStyle: FieldStyle.underline,
                  onCompleted: (pin) {
                    _otpValue = pin;
                    print("Completed: " + pin);
                  },
                ),
              ),
              SizedBox(height: 20),
              MaterialButton(
                minWidth: MediaQuery.of(context).size.width,
                height: 50,
                color: Color.fromARGB(255, 105, 163, 142),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onPressed: _isLoading ? null : () => _verifyCode(),
                child: _isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      )
                    : Text(
                        "Verify",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _verifyCode() async {
    setState(() {
      _isLoading = true;
    });

    final String code = _otpValue!;
    AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: code,
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VideoPlayerPage()),
      );
      print(
          'Registration successful! User ID: ${FirebaseAuth.instance.currentUser!.uid}');
    } catch (e) {
      print('Error during registration: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void startResendTimer() {
    _resendTimer = Timer.periodic(
      Duration(seconds: _resendIntervalInSeconds),
      (Timer timer) {
        print('Resending OTP...');
      },
    );
  }

  void cancelResendTimer() {
    _resendTimer?.cancel();
  }

  @override
  void dispose() {
    cancelResendTimer();
    super.dispose();
  }
}

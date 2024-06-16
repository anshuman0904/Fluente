import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

import '../../api/apis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../home_screen.dart';
import 'dart:developer';
import '../../helper/dialogs.dart';
import 'after_signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleBtnClick() {
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if (await APIs.userExists()) {
          log("User Exists");
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          log("New User");
          // await APIs.CreateUser("Spanish", "English").then((value) {
          //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          // });
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AfterSU()));
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');
      Dialogs.showSnackbar(context, 'Something went wrong! Check your internet :(');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // title: const Text('Fluente', style: TextStyle(color: Colors.white, fontSize: 30),),
        title:Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Fluente',
                      // style: TextStyle(color: Colors.white, fontFamily: 'Lobster', fontSize: 25),
                      style: GoogleFonts.lora(
                        textStyle: const TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    )
                  ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedPositioned(
            top: mq.height * .15,
            width: mq.width * .5,
            right: _isAnimate ? mq.width * .25 : -mq.width * .5,
            duration: const Duration(seconds: 1),
            child: Image.asset('images/icon.png'),
          ),
          Positioned(
            bottom: mq.height * .15,
            width: mq.width * .9,
            left: mq.width * .05,
            height: mq.height * .10,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 126, 223, 15),
                shape: const StadiumBorder(),
                elevation: 1,
              ),
              onPressed: () {
                _handleGoogleBtnClick();
              },
              icon: Image.asset(
                'images/google.png',
                height: mq.height * 0.04,
              ),
              label: RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 20),
                  children: [
                    TextSpan(text: 'Login with'),
                    TextSpan(text: ' Google', style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

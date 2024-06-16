import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api/apis.dart';
import 'home_screen.dart';
import 'auth/login_screen.dart';
import '../../main.dart';
import 'dart:developer';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        statusBarColor: Colors.black,
      ));
    Future.delayed(const Duration(seconds: 3), () {

      if (APIs.auth.currentUser != null) {
        log('\nUser: ${APIs.auth.currentUser}');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
      else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

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
                        textStyle: const TextStyle(color: Colors.white, fontSize: 30),
                      ),
                    )
                  ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: mq.height * .15,
            width: mq.width * .5,
            right: mq.width * .25,
            child: Image.asset('images/icon.png'),
          ),
          Positioned(
            bottom: mq.height * .15,
            width: mq.width,
            child: const Text(
              'Bridging Cultures 🌎',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.white, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

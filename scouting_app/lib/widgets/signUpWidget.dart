import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:scouting_demo/widgets/googleSignIn.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({super.key});

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          backgroundColor: Colors.deepOrange,
          body: SafeArea(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  const Text("5654 PHOENIX",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: '3ds',
                      )),

                  const SizedBox(
                    height: 10,
                  ),

                  const Text("Scouting App",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: '3ds',
                      )),

                  const SizedBox(
                    height: 100,
                  ),

                  // Phoenix logo
                  Image.asset(
                    'assets/Images/phoenix_logo.png',
                    height: 250,
                  ),

                  // Google sign in button
                  const SizedBox(
                    height: 150,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                      fixedSize: const Size(300, 50),
                    ),
                    onPressed: () async {
                      print("Signing up...");
                      final provider = Provider.of<GoogleSignInProviedr>(
                          context,
                          listen: false);
                      provider.googleLogin();
                    },
                    icon: const FaIcon(FontAwesomeIcons.google),
                    label: const Text("Sign in with Google"),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}

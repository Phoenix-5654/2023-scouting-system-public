import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scouting_demo/widgets/userManager.dart';

class GoogleSignInProviedr extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  // Roles data
  bool isAdmin = false;

  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    final googleUser = await GoogleSignIn(scopes: [
      'email',
      'profile',
    ]).signIn(); // Sign in with Google

    if (googleUser == null) return; // If account isn't selected, return
    _user = googleUser; // Set user to the Google account

    final googleAuth =
        await googleUser.authentication; // Get authentication token

    final credential = GoogleAuthProvider.credential(
      // Create a credential
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await UserManager()
        .instance
        .signInWithCredential(credential); // Sign in with Firebase

    notifyListeners();
  }

  Future googleLogout() async {
    await googleSignIn.disconnect().catchError((onError) {
      log(onError.toString());
    }); // Disconnect from Google
    UserManager().instance.signOut().onError(
        (error, stackTrace) => log(error.toString())); // Sign out from Firebase
    notifyListeners();
  }
}

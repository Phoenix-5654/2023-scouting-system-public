import 'dart:developer' show log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserManager {
  var user = FirebaseAuth.instance.currentUser;
  var instance = FirebaseAuth.instance;

  late Future<bool> isAuthorized;
  late Future<bool> isAdmin = Future.value(false);

  Future<bool> checkWhitelist() async {
    // Log out
    // Check if user is in the whitelist
    Future<bool> res = Future.value(false);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        res = Future.value(true);
      } else {
        log('Document does not exist on the database');
        res = Future.value(false);
      }
    });

    return res;
  }

  Future<bool> checkAdmin() async {
    Future<bool> res = Future.value(false);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot['role'] == 'admin') {
          res = Future.value(true);
        }
      } else {
        log('Document does not exist on the database');
        res = Future.value(false);
      }
    });

    return res;
  }

  Future<void> setOnlineStatus({required bool status}) async {
    // Set online status - add field 'online', and set it to 'status'
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .update({'online': status});
  }

  Future<void> signOut() async {
    await setOnlineStatus(status: false);
    await FirebaseAuth.instance.signOut();
  }
}

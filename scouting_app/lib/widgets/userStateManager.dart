import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scouting_demo/services/googleSheetsAPI.dart';
import 'package:scouting_demo/widgets/userManager.dart';

class UserStates {
  static String Online = "Online";
  static String Offline = "Offline";
  static String InMatch = "In match";
  static String InSnake = "In snake";
  static String InMatchSelection = "In match selection";
}

class UserStateManager {
  static bool isInMatch = false;

  static void setUserState(String state) async {
    log("isInMatch: $isInMatch", name: "UserStateManager");
    log("state: $state", name: "UserStateManager");
    if (state.isNotEmpty && isInMatch) {
      return;
    }

    // If the start of the state is "In match", set isInMatch to true
    if (state.startsWith(UserStates.InMatch) &&
        state != UserStates.InMatchSelection) {
      isInMatch = true;
    } else {
      isInMatch = false;
    }

    var db = FirebaseFirestore.instance;
    var user = UserManager().user;

    // Save the state to the whitelist
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.email)
        .update({'state': state});

    GoogleSheetsAPI().updateSheet(state);
  }
}

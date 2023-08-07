import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scouting_demo/pages/loggedIn.dart';
import 'package:scouting_demo/widgets/globalDataManager.dart';
import 'package:scouting_demo/widgets/googleSignIn.dart';
import 'package:scouting_demo/widgets/loadingIndicatorWidget.dart';

import '../First_api/first_api.dart';
import '../First_api/team.dart';
import '../widgets/signUpWidget.dart';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';

import '../widgets/userManager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Set 'eventYear' and 'eventKey' to be a ValueNotifier.
  // 'eventYear' default value is the current year
  var eventYear = ValueNotifier(DateTime.now().year.toString());
  var eventKey = ValueNotifier('isde3');

  FIRST_API api = FIRST_API();

  @override
  void initState() {
    super.initState();
    // Get the event year and key from the global data manager
    GlobalDataManager.getEventYearNotifier(eventYear);
    GlobalDataManager.getEventKeyNotifier(eventKey);

    api.init(eventCode: eventKey.value, year: eventYear.value);

    // Add listener to the event year notifier
    eventYear.addListener(() {
      // If the event year is not empty, get the event data
      if (eventYear.value != '') {
        setState(() {
          api.setYear(eventYear.value);
        });
      }
    });

    eventKey.addListener(() {
      if (eventKey.value != '') {
        setState(() {
          api.setEventCode(eventKey.value);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder(
            stream: UserManager().instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: LoadingIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("Error: ${snapshot.error}"),
                );
              } else if (snapshot.hasData) {
                return Center(child: checkAcces());
              } else {
                return const SignUpWidget();
              }
            }),
      );

  Widget checkAcces() {
    // Check if user is in the whitelist
    // If yes, return LoggedIn()
    // If no, show error and log out

    return FutureBuilder(
      future: UserManager().checkWhitelist(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // If 'permission-denied' is in error - show error
          if (snapshot.error.toString().contains('permission-denied')) {
            final player = AudioPlayer();
            player.play(AssetSource('enter_stranger.mp3'));

            return Container(
              alignment: Alignment.center,
              color: Colors.red,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    """Enter, stranger, but take heed
Of what awaits the sin of greed
For those who take, but do not earn
Must pay most dearly in their turn
So if you seek beneath our floors
A treasure that was never yours
Thief, you have been warned, beware
Of finding more than treasure there""",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                    ),
                    onPressed: () {
                      GoogleSignInProviedr().googleLogout();
                    },
                    child: const Text("Log out",
                        style: TextStyle(color: Colors.red)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                    ),
                    onPressed: () {
                      player.play(AssetSource('theme_01.mp3')).onError(
                          (error, stackTrace) => log(error.toString()));
                    },
                    child: const Text("Sound on",
                        style: TextStyle(color: Colors.red)),
                  )
                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      GoogleSignInProviedr().googleLogout();
                    },
                    child: const Text("Log out"),
                  )
                ],
              ),
            );
          }
        } else if (snapshot.hasData) {
          return LoggedIn(api: api);
        } else {
          return const Center(
            child: LoadingIndicator(),
          );
        }
      },
    );
  }
}

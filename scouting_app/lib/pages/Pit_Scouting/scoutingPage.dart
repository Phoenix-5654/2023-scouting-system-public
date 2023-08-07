import 'dart:developer';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:scouting_demo/First_api/first_api.dart';
import 'package:scouting_demo/pages/Pit_Scouting/autonomusPage.dart';
import 'package:scouting_demo/pages/Pit_Scouting/teamSelectionPage.dart';
import 'package:flutter/material.dart';
import 'package:scouting_demo/widgets/PitScouting/drawData.dart';
import 'package:scouting_demo/widgets/PitScouting/messagesView.dart';
import 'package:scouting_demo/widgets/PitScouting/sendMessage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:scouting_demo/widgets/loadingIndicatorWidget.dart';
import 'package:scouting_demo/widgets/orangeAppBar.dart';

import '../../First_api/team.dart';
import '../../widgets/navigationDrawer.dart' as nav;
import '../../data/teamProfile.dart';
import 'editTeam.dart';

class ScoutingPage extends StatefulWidget {
  ScoutingPage({super.key, required this.api, required schedule})
      : schedule = schedule;

  FIRST_API api;
  ValueNotifier<Map<String, List<dynamic>>> schedule;

  final Future<TeamProfile> _teamProfile =
      TeamProfile(TeamSelectionPage.selectedTeam.value.teamNum)
          .synchronizeTeam();

  @override
  State<ScoutingPage> createState() => _ScoutingPageState();
}

class _ScoutingPageState extends State<ScoutingPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Scaffold(
          backgroundColor: Colors.transparent,
          drawer: nav.NavigationDrawer(
            api: widget.api,
            schedule: widget.schedule,
          ),
          body: FutureBuilder(
            future: widget._teamProfile,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                TeamProfile teamProfile = snapshot.data as TeamProfile;

                if (teamProfile.teamData.value.isEmpty) {
                  return const Center(
                    child: LoadingIndicator(),
                  );
                }

                return (snapshot.data!.doesExist)
                    ? drawPage(
                        snapshot.data!) // If team exists - drawing the data
                    : EditTeamPage(
                        // If team doesn't exist - creating a new team
                        teamProfile: teamProfile,
                        teamNum: TeamSelectionPage.selectedTeam.value.teamNum,
                        doesExist: teamProfile.doesExist,
                      );
              } else {
                return const Center(
                  child: LoadingIndicator(),
                );
              }
            },
          )),
    );
  }

  Widget drawPage(TeamProfile teamProfile) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      //bottomNavigationBar: drawNavigation(teamProfile),
      drawer: nav.NavigationDrawer(
        api: widget.api,
        schedule: widget.schedule,
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              // Add orange gradient background
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: <Color>[
                    Colors.orange.shade800,
                    Colors.orange.shade700,
                    Colors.orange.shade600,
                    Colors.orange.shade500,
                    Colors.orange.shade400,
                  ],
                ),
              ),
              height: MediaQuery.of(context).size.height * 0.2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Team number (e.g 5654)
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Text(
                      "Team ${TeamSelectionPage.selectedTeam.value.teamNum}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Team nickname (e.g Phoenix)
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Text(
                      TeamSelectionPage.selectedTeam.value.teamNickname,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Edit team data button
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: Scaffold(
                            appBar: orangeAppBar('עריכת נתוני קבוצה'),
                            body: EditTeamPage(
                              teamProfile: teamProfile,
                              teamNum:
                                  TeamSelectionPage.selectedTeam.value.teamNum,
                              doesExist: teamProfile.doesExist,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: Colors.grey[400]!)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "עריכת נתוני קבוצה",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.arrow_right,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: FutureBuilder(
                future: widget._teamProfile,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return drawTeamData(snapshot.data!);
                  } else {
                    return const Center(
                      child: LoadingIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// --- Draw team data ---
  /// This function draws the team data, from a given profile
  ///
  /// @param givenProfile - The team profile to draw
  Widget drawTeamData(TeamProfile teamProfile) {
    Map<QuestionData, TextEditingController> controllers = {};

    // Saving to the controllers map the answers

    for (var entry in teamProfile.teamData.value.entries) {
      controllers[entry.key] = TextEditingController(text: entry.value);
    }

    return FutureBuilder(
        future: widget._teamProfile,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return (snapshot.data!.doesExist)
                ? SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: DrawData(
                      baseData: snapshot.data!.teamData.value,
                      isEdit: false,
                      controlers: controllers,
                      teamProfile: snapshot.data!,
                    ),
                  )
                : const Text("Test");
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

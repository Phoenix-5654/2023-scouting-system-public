import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:scouting_demo/First_api/match.dart';
import 'package:scouting_demo/First_api/team.dart';
import 'package:scouting_demo/data/teamProfile.dart';
import 'package:scouting_demo/pages/Pit_Scouting/autonomusPage.dart';
import 'package:scouting_demo/pages/Scouting/matchScouting.dart';
import 'package:scouting_demo/widgets/orangeAppBar.dart';
import 'package:scouting_demo/widgets/userStateManager.dart';

import '../../widgets/counterWidget.dart';
import '../../widgets/countingTable.dart';
import '../../widgets/questionDrawer.dart';

class MatchScoutingAutonomus extends StatefulWidget {
  MatchScoutingAutonomus({
    super.key,
    required this.selectedMatch,
    required this.scoutedTeam,
    required this.eventCode,
    required this.year,
    required this.teamIndex,
  });

  match selectedMatch;
  int scoutedTeam;
  String eventCode;
  String year;
  String teamIndex;

  @override
  State<MatchScoutingAutonomus> createState() => _MatchScoutingAutonomusState();
}

class _MatchScoutingAutonomusState extends State<MatchScoutingAutonomus> {
  var coneAmount = ValueNotifier(<int>[0, 0, 0]);
  var cubeAmount = ValueNotifier(<int>[0, 0, 0]);
  var linkCounter = ValueNotifier(0);

  late TeamProfile teamProfile;

  @override
  void initState() {
    super.initState();
    teamProfile = TeamProfile(widget.scoutedTeam, isMatch: true);
    teamProfile.synchronizeTeam();

    UserStateManager.setUserState(
        "${UserStates.InMatch}: Match #${widget.selectedMatch.matchNumber} | ${widget.scoutedTeam}");
  }

  @override
  Widget build(BuildContext context) {
    String alliance = " ";

    if (widget.selectedMatch.redAlliance.contains(widget.scoutedTeam)) {
      alliance = "red";
    } else if (widget.selectedMatch.blueAlliance.contains(widget.scoutedTeam)) {
      alliance = "blue";
    }

    var autonomousPage = AutonomusPage(
      teamProfile: TeamProfile(widget.scoutedTeam),
      selectedMatch: widget.selectedMatch,
      alliance: alliance,
      isMatch: true,
    );

    return Scaffold(
      appBar: orangeAppBar('Match Scouting'),
      body: Container(
          // Set width and height of the container to the size of the screen
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Text(
                      'Match: ${widget.selectedMatch.description}',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  Container(
                    // Round the corners of the container
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: (alliance == "red"
                            ? Colors.red.shade700
                            : alliance == "blue"
                                ? Colors.blue.shade700
                                : Colors.grey)),
                    padding: const EdgeInsets.all(10),
                    child: Text(
                        'Team: ${widget.scoutedTeam} | ${widget.teamIndex}',
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                  ),

                  drawPieceTable(),

                  // Add gap
                  const SizedBox(height: 10),

                  // autonomousPage,

                  ValueListenableBuilder(
                      valueListenable: teamProfile.autonomusQuestions,
                      builder: (context, value, child) {
                        // Add loading animation
                        if (value.isEmpty) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.orange.shade600,
                            ),
                          );
                        }
                        log("Val: " + value.toString());
                        return ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            for (var key in value)
                              Container(
                                margin:
                                    const EdgeInsets.fromLTRB(15, 5, 15, 20),
                                child: QuestionDrawer(
                                  questionData: key,
                                  teamProfile: teamProfile,
                                  drawQuestion: true,
                                ),
                              ),
                          ],
                        );
                      }),

                  // Text Button - Go to the next page
                  TextButton(
                    onPressed: () {
                      // Check if all the questions have been answered
                      // and the user has selected a pattern

                      for (var entry in teamProfile.teamData.value.entries) {
                        // If entry is not a title, and is inside 'autonomusQuestions'
                        // check whether it has been answered

                        if (!entry.key.isTitle &&
                            teamProfile.autonomusQuestions.value
                                .contains(entry.key)) {
                          if (entry.value == "N/A") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'אנא מלא את כל השאלות - "${entry.key.text}"',
                                ),
                                duration: Duration(seconds: 1),
                              ),
                            );
                            return;
                          }
                        }
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          var icons = autonomousPage.getIcons();
                          var comments = autonomousPage.getIconsComments();

                          return Directionality(
                              textDirection: TextDirection.rtl,
                              child: MatchScouting(
                                selectedMatch: widget.selectedMatch,
                                selectedTeam: widget.scoutedTeam,
                                autonomousConeAmount: coneAmount,
                                autonomousCubeAmount: cubeAmount,
                                linkCount: linkCounter,
                                autonomusPattern: AutonomusPattern(
                                    comments: comments, data: icons),
                                teamProfile: teamProfile,
                                eventCode: widget.eventCode,
                                year: widget.year,
                                teamIndex: widget.teamIndex,
                              ));
                        }),
                      );
                    },
                    child: Text('המשך',
                        style: TextStyle(
                            fontSize: 20, color: Colors.orange.shade700)),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Container drawLinkCounter(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: CounterView(
                initNumber: 0,
                counterCallback: ((p0) {
                  log("Link counter: $p0");
                }),
                increaseCallback: (() {
                  linkCounter.value++;
                }),
                decreaseCallback: (() {
                  linkCounter.value++;
                }),
                minNumber: 0),
          ),
          const Text(
            "Link Support",
          )
        ],
      ),
    );
  }

  Container drawPieceTable() {
    return Container(
      constraints: const BoxConstraints.expand(height: 200),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CountingTable(
            data: coneAmount,
            imagePath: 'assets/Images/cone_grey.png',
          ),
          CountingTable(
            data: cubeAmount,
            imagePath: 'assets/Images/cube_grey.png',
          ),
          Container(
            // Set the height of the container to the height of the counting table
            height: 150,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(""),
                Text("High"),
                Text("Mid"),
                Text("Low"),
              ],
            ),
          )
        ],
      ),
    );
  }
}

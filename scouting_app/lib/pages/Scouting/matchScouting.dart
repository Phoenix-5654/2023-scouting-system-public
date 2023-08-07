import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:scouting_demo/First_api/match.dart';
import 'package:scouting_demo/services/notification_service.dart';
import 'package:scouting_demo/widgets/counterWidget.dart';
import 'package:scouting_demo/widgets/countingTable.dart';
import 'package:scouting_demo/services/googleSheetsAPI.dart';
import 'package:scouting_demo/widgets/orangeAppBar.dart';
import 'package:scouting_demo/widgets/questionDrawer.dart';
import 'package:scouting_demo/widgets/userManager.dart';
import 'package:scouting_demo/widgets/userStateManager.dart';

import '../../data/teamProfile.dart';
import '../Pit_Scouting/autonomusPage.dart';

class MatchScouting extends StatefulWidget {
  MatchScouting({
    super.key,
    required this.selectedTeam,
    required this.selectedMatch,
    required this.autonomousConeAmount,
    required this.autonomousCubeAmount,
    required this.linkCount,
    required this.autonomusPattern,
    required this.teamProfile,
    required this.eventCode,
    required this.year,
    required this.teamIndex,
  });

  ValueNotifier<List<int>> autonomousConeAmount;
  ValueNotifier<List<int>> autonomousCubeAmount;
  ValueNotifier<int> linkCount;
  final AutonomusPattern autonomusPattern;
  TeamProfile teamProfile;
  int selectedTeam;
  match selectedMatch;
  String eventCode;
  String year;
  String teamIndex;

  @override
  State<MatchScouting> createState() => _MatchScoutingState();
}

class _MatchScoutingState extends State<MatchScouting> {
  var matchData = ValueNotifier(<String, dynamic>{});
  var coneAmount = ValueNotifier(<int>[0, 0, 0]);
  var cubeAmount = ValueNotifier(<int>[0, 0, 0]);
  var linkCounter = ValueNotifier(0);

  String alliance = " ";

  late TeamProfile teamProfile;

  @override
  void initState() {
    super.initState();

    setState(() {
      teamProfile = widget.teamProfile;

      coneAmount.value[0] = widget.autonomousConeAmount.value[0];
      coneAmount.value[1] = widget.autonomousConeAmount.value[1];
      coneAmount.value[2] = widget.autonomousConeAmount.value[2];

      cubeAmount.value[0] = widget.autonomousCubeAmount.value[0];
      cubeAmount.value[1] = widget.autonomousCubeAmount.value[1];
      cubeAmount.value[2] = widget.autonomousCubeAmount.value[2];

      // Save the question data to the matchData notifier
      teamProfile.teamData.addListener(() {
        matchData.value = {
          'coneAmount': coneAmount.value,
          'cubeAmount': cubeAmount.value,
          'linkCounter': linkCounter.value,
          'autonomusPattern': widget.autonomusPattern,
          'teamProfile': teamProfile.teamData.value,
        };
      });

      // Adding listener to the teamProfile.teamData notifier
      teamProfile.teamData.addListener(() {
        log(teamProfile.teamData.value.toString());
      });

      if (widget.selectedMatch.redAlliance.contains(widget.selectedTeam)) {
        alliance = "red";
      } else if (widget.selectedMatch.blueAlliance
          .contains(widget.selectedTeam)) {
        alliance = "blue";
      } else {
        alliance = " ";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: orangeAppBar('Match Scouting'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
            child: Text('Team: ${widget.selectedTeam} | ${widget.teamIndex}',
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          ),

          Container(
            child: Column(
              children: [
                drawPieceTable(),
              ],
            ),
          ),

          // Link counter

          // Seperator
          Container(
            margin: const EdgeInsets.all(10),
            child: Divider(
              color: Colors.grey.shade500,
              thickness: 1,
            ),
          ),

          // Build all questions using teamProfile, and valueListenableBuilder
          // and place it an a scrollable list
          drawQuestions(),

          // Submit button
          Container(
            margin: const EdgeInsets.all(10),
            child: ElevatedButton(
              // Set color to orange
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
              ),
              onPressed: () {
                // Save the data to firestore
                // /teams/<team_number>/<match_history>/<match_number> -> matchData.value

                // Loggind all 'teamProfile' data
                for (var entry in teamProfile.teamData.value.entries) {
                  log(entry.key.text);
                  log(entry.value.toString());
                }

                var data = <String, dynamic>{};

                data['coneAmountHigh'] =
                    coneAmount.value[0] - widget.autonomousConeAmount.value[0];
                data['coneAmountMid'] =
                    coneAmount.value[1] - widget.autonomousConeAmount.value[1];
                data['coneAmountLow'] =
                    coneAmount.value[2] - widget.autonomousConeAmount.value[2];
                data['cubeAmountHigh'] =
                    cubeAmount.value[0] - widget.autonomousCubeAmount.value[0];
                data['cubeAmountMid'] =
                    cubeAmount.value[1] - widget.autonomousCubeAmount.value[1];
                data['cubeAmountLow'] =
                    cubeAmount.value[2] - widget.autonomousCubeAmount.value[2];
                data['linkAmount'] = linkCounter.value;

                data['autonomousConeHigh'] =
                    widget.autonomousConeAmount.value[0];
                data['autonomousConeMid'] =
                    widget.autonomousConeAmount.value[1];
                data['autonomousConeLow'] =
                    widget.autonomousConeAmount.value[2];
                data['autonomousCubeHigh'] =
                    widget.autonomousCubeAmount.value[0];
                data['autonomousCubeMid'] =
                    widget.autonomousCubeAmount.value[1];
                data['autonomousCubeLow'] =
                    widget.autonomousCubeAmount.value[2];

                for (var entry in data.entries) {
                  log("Entry key: ${entry.key} : Entry value: ${entry.value}");
                }

                // Saving the autonomous data to a array of strings, inside 'autonomous' field
                data['autonomous'] = <String>[];

                for (var key in AutonomusPage.currentPattern.value.data.keys) {
                  String temp = '';

                  temp += key.toString();
                  temp += ': ';
                  temp +=
                      AutonomusPage.currentPattern.value.data[key].toString();
                  temp += AutonomusPage.currentPattern.value.comments[key] == ''
                      ? ' '
                      : ' (${widget.autonomusPattern.comments[key]})';

                  data['autonomous'].add(temp);

                  log("Autonomous data: $temp");
                }

                for (var entry in teamProfile.teamData.value.entries) {
                  if (entry.key.isTitle) {
                    continue;
                  }
                  if (entry.value != "N/A") {
                    if (entry.value is Map) {
                      // Iterate over the map, and add it to the data as a string
                      String temp = '';

                      for (var mapEntry in entry.value.entries) {
                        if (mapEntry.value is bool && mapEntry.value) {
                          temp += '${mapEntry.key}, ';
                        } else if (mapEntry.value is String) {
                          temp += '${mapEntry.value}, ';
                        }
                      }

                      // Remove the last ', '
                      temp = temp.substring(0, temp.length - 2);

                      data[entry.key.text] = temp;
                    } else {
                      data[entry.key.text] = entry.value.toString();
                    }
                  } else {
                    // If the value is 'N/A', then don't save it, and show a snackbar
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('מלאו את כל השאלות - ${entry.key.text}'),
                      backgroundColor: Colors.red,
                    ));
                    return;
                  }
                }

                log("Final data:");
                // Print the final data
                for (var entry in data.entries) {
                  log("Entry key: ${entry.key} : Entry value: ${entry.value}");
                }

                // Send the data to the server
                var db = FirebaseFirestore.instance;

                // Add the data to the 'match_history' collection as a new document
                db
                    .collection('teams')
                    .doc(widget.selectedTeam.toString())
                    .collection('match_history')
                    .doc(
                        '${widget.eventCode} (${widget.year}) : ${widget.selectedMatch.description} | ${widget.selectedMatch.matchNumber} - ${UserManager().user!.email!}')
                    .set(data);

                // Adding the data directly to the sheets (as backup)

                data['Team Number'] = widget.teamProfile.teamNum;
                data['Year'] = widget.year;
                data['Event Code'] = widget.eventCode;
                data['Match Data'] =
                    widget.selectedMatch.description.toUpperCase();
                data['Author'] = UserManager().user!.email!;

                log("Savig changes to: RegResponses_${widget.teamIndex}_CMPTX}");

                GoogleSheetsAPI().saveBackupData(
                    data: data, name: "${widget.teamIndex}_CMPTX");

                GoogleSheetsAPI().updateSheet(UserStates.Online);
                UserStateManager.setUserState(UserStates.Online);

                // Update the 'match' field at the 'users/<user_email>' document
                // to be '' (empty string)

                db
                    .collection('users')
                    .doc(UserManager().user!.email)
                    .update({'match': ''});

                // Go back to 'scouting' page
                Navigator.pop(context);
                Navigator.pop(context);

                // Show snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('הנתונים נשמרו בהצלחה'),
                  ),
                );
              },
              child: const Text("שלח"),
            ),
          ),
        ],
      ),
    );
  }

  ValueListenableBuilder<List<QuestionData>> drawQuestions() {
    return ValueListenableBuilder(
        valueListenable: teamProfile.mainQuestions,
        builder: (context, value, child) {
          log("Val: $value");
          return Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (var key in value)
                  Container(
                    margin: const EdgeInsets.fromLTRB(15, 5, 15, 20),
                    child: QuestionDrawer(
                      questionData: key,
                      teamProfile: teamProfile,
                      drawQuestion: true,
                    ),
                  ),
              ],
            ),
          );
        });
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
              initNumber: widget.linkCount.value,
              counterCallback: ((p0) {
                log("Link counter: $p0");
              }),
              increaseCallback: (() {
                linkCounter.value++;
              }),
              decreaseCallback: (() {
                linkCounter.value++;
              }),
              minNumber: widget.linkCount.value,
            ),
          ),
          const Text(
            "Links",
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

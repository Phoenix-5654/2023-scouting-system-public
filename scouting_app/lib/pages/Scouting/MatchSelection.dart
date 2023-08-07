import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:scouting_demo/First_api/first_api.dart';
import 'package:scouting_demo/First_api/match.dart';
import 'package:scouting_demo/data/scheduleData.dart';
import 'package:scouting_demo/pages/Scouting/matchScoutingAutonomous.dart';
import 'package:scouting_demo/widgets/globalDataManager.dart';
import 'package:scouting_demo/widgets/loadingIndicatorWidget.dart';
import 'package:scouting_demo/widgets/navigationDrawer.dart';
import 'package:scouting_demo/widgets/orangeAppBar.dart';
import 'package:scouting_demo/widgets/userManager.dart';
import 'package:scouting_demo/widgets/userStateManager.dart';

import 'matchScoutingAutonomous.dart';
import '../../First_api/match.dart' as m;

class MatchSelectionPage extends StatefulWidget {
  MatchSelectionPage({super.key, required this.api, required this.schedule});

  FIRST_API api;
  ValueNotifier<Map<String, List<dynamic>>> schedule;

  @override
  State<MatchSelectionPage> createState() => _MatchSelectionPageState();
}

class _MatchSelectionPageState extends State<MatchSelectionPage> {
  String _input = '1';
  Future<List<match>> _matches = Future.value([]);
  var eventKey = ValueNotifier('jcmp');
  var eventYear = ValueNotifier('2023');
  Map<String, List<dynamic>> _schedule = {};

  late FIRST_API api;

  @override
  void initState() {
    super.initState();

    GlobalDataManager.getEventKeyNotifier(eventKey);

    api = widget.api;

    setState(() {
      _matches = Future.value(List<match>.empty());
      _matches = api.getMatches(int.parse(_input.substring(0, 1)));
    });

    eventKey.addListener(() {
      if (eventKey.value != '') {
        setState(() {
          _matches = Future.value(List<match>.empty());
          _matches = api.getMatches(int.parse(_input.substring(0, 1)));
        });
      }
    });

    widget.schedule.addListener(() {
      setState(() {
        _schedule = widget.schedule.value;
      });
    });

    UserStateManager.setUserState(UserStates.InMatchSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: orangeAppBar(''),
        body: Container(
          margin: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('סוג מקצה: ',
                        style: TextStyle(
                          fontSize: 20,
                        )),

                    // Add gap
                    const SizedBox(width: 10),

                    DropdownButton<String>(
                      value: _input,
                      items: <String>['0', '1', '2', '3']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(getGameType(value)),
                        );
                      }).toList(),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      disabledHint: const Text('לא נבחר סוג מקצה',
                          style: TextStyle(
                            fontSize: 20,
                          )),
                      onChanged: (String? newValue) {
                        if (newValue == null) return;
                        if (newValue == '3') {
                          // Showing manual team selection dialog
                          // the page will contain 6 input fields
                          // for R1, R2, R3, B1, B2, B3
                          // and a button to submit
                          // The submit button will take the user to the match scouting page

                          var practiceTeamController = TextEditingController();

                          createMatch(context, practiceTeamController);
                        }
                        setState(() {
                          _input = newValue;

                          if (_input != '3') {
                            _matches = api
                                .getMatches(int.parse(_input.substring(0, 1)));
                          }
                        });
                      },
                    ),
                  ],
                ),

                // Divider
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  // Width - 60% of the screen
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 1,
                  color: Colors.black38,
                ),

                // Show the matches
                FutureBuilder(
                  future: _matches,
                  builder: (context, snapshot) {
                    try {
                      if (snapshot.hasData) {
                        // Log the matches

                        List<bool> isTeamInMatch = List.filled(
                            snapshot.data!.length, false,
                            growable: true);

                        // Check if the team is in the match
                        for (int i = 0; i < snapshot.data!.length; i++) {
                          for (int j = 0;
                              j < snapshot.data![i].blueAlliance.length;
                              j++) {
                            if (snapshot.data![i].blueAlliance[j] == 5654) {
                              isTeamInMatch[i] = true;
                            }
                          }

                          for (int j = 0;
                              j < snapshot.data![i].redAlliance.length;
                              j++) {
                            if (snapshot.data![i].redAlliance[j] == 5654) {
                              isTeamInMatch[i] = true;
                            }
                          }
                        }

                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                bool isTimeNear = false;
                                var time = snapshot.data![index].time
                                    .substring(11, 16);

                                // Check if the match is in the next 30 minutes
                                if (DateTime.now().isBefore(DateTime.parse(
                                        '${snapshot.data![index].time.substring(0, 10)} ${time.substring(0, 2)}:${time.substring(3, 5)}:00')
                                    .add(const Duration(minutes: 30)))) {
                                  isTimeNear = true;
                                }

                                bool isScheduled = false;

                                // Check if the match is scheduled
                                if (_schedule.containsKey(snapshot
                                    .data![index].description
                                    .toUpperCase())) {
                                  isScheduled = true;
                                }

                                var scheduledTeam = 0;

                                // If the match is scheduled, get the team number of the scheduled team
                                if (isScheduled) {
                                  scheduledTeam = _schedule[snapshot
                                      .data![index].description
                                      .toUpperCase()]![1];
                                }

                                String scheduledTeamIndex = '';

                                // If the match is scheduled, get the team index of the scheduled team
                                // In the format: B1, B2, B3, R1, R2, R3

                                if (isScheduled) {
                                  if (snapshot.data![index].blueAlliance
                                      .contains(scheduledTeam)) {
                                    scheduledTeamIndex =
                                        'B${snapshot.data![index].blueAlliance.indexOf(scheduledTeam) + 1}';
                                  } else {
                                    scheduledTeamIndex =
                                        'R${snapshot.data![index].redAlliance.indexOf(scheduledTeam) + 1}';
                                  }
                                }

                                var textColor = Colors.grey.shade700;

                                if (isScheduled) {
                                  if (scheduledTeamIndex.startsWith('B')) {
                                    textColor = Colors.blue.shade200;
                                  } else {
                                    textColor = Colors.red.shade200;
                                  }
                                }

                                return Opacity(
                                  opacity: isScheduled ? 1 : 0.5,
                                  child: Card(
                                    shadowColor: Colors.transparent,
                                    borderOnForeground: true,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    color: isTeamInMatch[index]
                                        ? Colors.orange.shade200
                                        : Colors.transparent,
                                    margin: isScheduled
                                        ? const EdgeInsets.fromLTRB(0, 3, 20, 5)
                                        : const EdgeInsets.all(5),
                                    child: ListTile(
                                      title: Text(
                                          isTeamInMatch[index]
                                              ? 'משחק ${snapshot.data![index].matchNumber} - 5654'
                                              : 'משחק ${snapshot.data![index].matchNumber}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: textColor,
                                          )),
                                      subtitle: Text(
                                          '${snapshot.data![index].description.toUpperCase()} : ${snapshot.data![index].time.substring(11, 16)}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: textColor,
                                          )),
                                      leading: isTimeNear
                                          ? const Icon(Icons.timer)
                                          : null,
                                      trailing: isScheduled
                                          ? Text(
                                              scheduledTeamIndex,
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: textColor,
                                              ),
                                            )
                                          : null,
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return buildMatchSelectionMenu(
                                                  snapshot,
                                                  index,
                                                  scheduledTeam);
                                            });
                                      },
                                    ),
                                  ),
                                );
                              }),
                        );
                      } else {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: const Center(
                            child: LoadingIndicator(),
                          ),
                        );
                      }
                    } catch (e) {
                      return const Text('אין תוצאות');
                    }
                  },
                ),
              ],
            ),
          ),
        ));
  }

  void createMatch(BuildContext context, TextEditingController controller) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('הכנס מספר קבוצה'),
            content: SizedBox(
              height: 500,
              child: Column(children: [
                // Input field for the team number to add
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'מספר קבוצה',
                  ),
                ),
              ]),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('ביטול'),
              ),
              TextButton(
                onPressed: () {
                  // Iterate over the controllers
                  // and check if they are empty

                  var blueAlliance = <int>[int.parse(controller.text)];
                  var redAlliance = <int>[];

                  var match = m.match(
                    blueAlliance: blueAlliance,
                    redAlliance: redAlliance,
                    matchNumber: 0,
                    // Set the description to "PRACTICE | PRACTICE <time>"
                    description:
                        "PRACTICE | PRACTICE ${DateTime.now().toString()}",
                    time: "           00:00",
                  );

                  Navigator.pop(context);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: MatchScoutingAutonomus(
                                  scoutedTeam: int.parse(controller.text),
                                  selectedMatch: match,
                                  year: widget.api.getYear(),
                                  eventCode: widget.api.getEventCode(),
                                  teamIndex: 'PRACTICE',
                                ),
                              ))).then((value) {
                    // This will be executed when the MatchScoutingAutonomus screen is closed
                    UserStateManager.setUserState(UserStates.InMatchSelection);

                    Navigator.pop(context);
                  });
                },
                child: const Text('אישור'),
              ),
            ],
          );
        });
  }

  StatefulBuilder buildMatchSelectionMenu(
      AsyncSnapshot<List<match>> snapshot, int index, int scheduledTeam) {
    var selectedTeam = 0;
    var teamIndex = "";

    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('מקצה- ${snapshot.data![index].matchNumber}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),

                // Add gap
                const SizedBox(height: 30),

                const Text("זמן התחלה משוער",
                    style: TextStyle(
                      fontSize: 12,
                    )),
                Text(snapshot.data![index].time.substring(11, 16),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    )),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (var team in snapshot.data![index].blueAlliance)
                      Opacity(
                        opacity: scheduledTeam == team ? 1 : 0.5,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTeam = team;
                              teamIndex =
                                  "B${snapshot.data![index].blueAlliance.indexOf(team) + 1}";
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              children: [
                                Text(
                                  team.toString(),
                                  style: TextStyle(
                                      color: selectedTeam == team
                                          ? Colors.blue.shade800
                                          : Colors.blue.shade400,
                                      fontWeight: selectedTeam == team
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontStyle: selectedTeam == team
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                      fontSize: selectedTeam == team ? 20 : 18),
                                ),

                                // Show team type (Blue1, Blue2, Blue3) by index

                                Text(
                                  snapshot.data![index].blueAlliance
                                              .indexOf(team) ==
                                          0
                                      ? 'B1'
                                      : snapshot.data![index].blueAlliance
                                                  .indexOf(team) ==
                                              1
                                          ? 'B2'
                                          : 'B3',
                                  style: TextStyle(
                                      color: selectedTeam == team
                                          ? Colors.blue.shade800
                                          : Colors.blue.shade400,
                                      fontWeight: selectedTeam == team
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontStyle: selectedTeam == team
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                      fontSize: selectedTeam == team ? 16 : 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  child: const Text("VS",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      )),
                ), //amogus 5654

                // Red alliance
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (var team in snapshot.data![index].redAlliance)
                      Opacity(
                        opacity: scheduledTeam == team ? 1 : 0.5,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTeam = team;
                              teamIndex =
                                  "R${snapshot.data![index].redAlliance.indexOf(team) + 1}";
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              children: [
                                Text(
                                  team.toString(),
                                  style: TextStyle(
                                      color: selectedTeam == team
                                          ? Colors.red.shade800
                                          : Colors.red.shade400,
                                      fontWeight: selectedTeam == team
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontStyle: selectedTeam == team
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                      fontSize: selectedTeam == team ? 20 : 18),
                                ),

                                // Show team type (Red1, Red2, Red3) by index
                                Text(
                                  snapshot.data![index].redAlliance
                                              .indexOf(team) ==
                                          0
                                      ? 'R1'
                                      : snapshot.data![index].redAlliance
                                                  .indexOf(team) ==
                                              1
                                          ? 'R2'
                                          : 'R3',
                                  style: TextStyle(
                                      color: selectedTeam == team
                                          ? Colors.red.shade800
                                          : Colors.red.shade400,
                                      fontWeight: selectedTeam == team
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontStyle: selectedTeam == team
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                      fontSize: selectedTeam == team ? 16 : 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // Add gap
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('לא',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ))),
                    TextButton(
                        onPressed: () {
                          // If no team was selected, show error
                          if (selectedTeam == 0) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('שגיאה'),
                                    content: const Text('אנא בחר קבוצה'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('אישור'))
                                    ],
                                  );
                                });
                            return;
                          }

                          // Close the dialog
                          Navigator.pop(context);

                          showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  alignment: Alignment.center,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  insetAnimationCurve: Curves.easeInOut,
                                  insetAnimationDuration:
                                      const Duration(milliseconds: 100),
                                  insetPadding: const EdgeInsets.fromLTRB(
                                      75, 230, 75, 230),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Center(
                                    child: checkSelectionValidityWidget(
                                      selectedTeam,
                                      teamIndex,
                                      snapshot.data![index],
                                    ),
                                  ),
                                );
                              });
                        },
                        child: const Text('כן',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ))),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  String getGameType(String value) {
    switch (value) {
      case '0':
        return 'Practice - אימונים';
      case '1':
        return 'Qualification - קבוצות';
      case '2':
        return 'Playoff - גמר';
      case '3':
        return 'יצירת מקצה ידנית';
      default:
        return 'N/A';
    }
  }

  Widget checkSelectionValidityWidget(
      var selectedTeam, var teamIndex, var selectedMatch) {
    bool allowOverride = false;
    return FutureBuilder(
      future: checkTeamAvilability(selectedTeam, selectedMatch),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!) {
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pop(context);

              UserStateManager.setUserState(
                  '${UserStates.InMatch} - ${selectedMatch.description} | $selectedTeam');

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Directionality(
                            textDirection: TextDirection.rtl,
                            child: MatchScoutingAutonomus(
                              scoutedTeam: selectedTeam,
                              selectedMatch: selectedMatch,
                              year: widget.api.getYear(),
                              eventCode: widget.api.getEventCode(),
                              teamIndex: teamIndex,
                            ),
                          ))).then((value) {
                // This will be executed when the MatchScoutingAutonomus screen is closed
                UserStateManager.setUserState(UserStates.InMatchSelection);
              });
            });

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "הקבוצה זמינה",
                  style: TextStyle(color: Colors.green.shade600, fontSize: 20),
                ),
                const SizedBox(height: 20),
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 50,
                ),

                // After 2 seconds, continue to the next screen

                const SizedBox(height: 20),
                Text(
                  "...ממשיכים לפתיחת המשחק",
                  style: TextStyle(color: Colors.green.shade600, fontSize: 14),
                ),
              ],
            );
          } else {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "הקבוצה כבר נבחרה",
                    style:
                        TextStyle(color: Colors.yellow.shade800, fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Icon(
                    Icons.warning_rounded,
                    color: Colors.yellow.shade800,
                    size: 50,
                  ),

                  // Add tickbox to allow the user to continue anyway

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "להמשיך בכל זאת",
                        style: TextStyle(
                          color: Colors.yellow.shade800,
                          fontSize: 14,
                        ),
                      ),
                      Checkbox(
                        activeColor: Colors.yellow.shade800,
                        fillColor:
                            MaterialStateProperty.all(Colors.yellow.shade800),
                        value: allowOverride,
                        onChanged: (bool? value) {
                          setState(() {
                            allowOverride = value ?? false;
                          });
                          log("Allow override: $allowOverride",
                              name: "OVERRIDE");
                        },
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "ביטול",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.yellow.shade800,
                            ),
                          )),
                      TextButton(
                          onPressed: () {
                            if (!allowOverride) {
                              return;
                            }
                            Navigator.pop(context);

                            UserStateManager.setUserState(
                                '${UserStates.InMatch} - ${selectedMatch.description} | $selectedTeam');

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: MatchScoutingAutonomus(
                                            scoutedTeam: selectedTeam,
                                            selectedMatch: selectedMatch,
                                            year: widget.api.getYear(),
                                            eventCode:
                                                widget.api.getEventCode(),
                                            teamIndex: teamIndex,
                                          ),
                                        ))).then((value) {
                              // This will be executed when the MatchScoutingAutonomus screen is closed

                              UserStateManager.setUserState(
                                  UserStates.InMatchSelection);
                              log("Cleared user match", name: "Exit Match");
                            });
                          },
                          child: Text(
                            "המשך למקצה",
                            style: TextStyle(
                              fontSize: 14,
                              color: allowOverride
                                  ? Colors.orange.shade800
                                  : Colors.grey,
                            ),
                          ))
                    ],
                  )
                ],
              );
            });
          }
        } else {
          return const LoadingIndicator();
        }
      },
    );
  }

  Future<bool> checkTeamAvilability(var selectedTeam, var selectedMatch) {
    var db = FirebaseFirestore.instance;

    // Access the 'users' collection, and check if there is a user with the 'match'
    // field that matches: 'selectedMatch.description | selectedTeam'

    return db
        .collection('users')
        .where('state',
            isEqualTo:
                '${UserStates.InMatch} - ${selectedMatch.description} | $selectedTeam')
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        log("Team already scouted");
        return false;
      } else {
        return true;
      }
    });
  }
}

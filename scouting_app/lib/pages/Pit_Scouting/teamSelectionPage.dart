import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scouting_demo/First_api/first_api.dart';
import 'package:scouting_demo/pages/Pit_Scouting/scoutingMainPage.dart';
import 'package:scouting_demo/widgets/PitScouting/selectTeam.dart';
import 'package:scouting_demo/widgets/orangeAppBar.dart';

import '../../First_api/team.dart';
import '../../widgets/globalDataManager.dart';
import '../../widgets/navigationDrawer.dart' as nav;
import 'scoutingPage.dart';

class TeamSelectionPage extends StatefulWidget {
  TeamSelectionPage({super.key, required this.api, required schedule})
      : schedule = schedule;

  FIRST_API api;
  ValueNotifier<Map<String, List<dynamic>>> schedule;

  static ValueNotifier<Team> selectedTeam = ValueNotifier(
      Team(teamNum: 0, teamName: '', teamNickname: '', encodedAvatar: ''));

  @override
  State<TeamSelectionPage> createState() => _TeamSelectionPageState();
}

class _TeamSelectionPageState extends State<TeamSelectionPage> {
  var _canContinue = false;
  var eventKey = ValueNotifier('jcmp');
  Future<List<Team>> teams = Future.value([]);

  @override
  void initState() {
    super.initState();
    // Clear the selected team
    TeamSelectionPage.selectedTeam.value =
        Team(teamNum: 0, teamName: '', teamNickname: '', encodedAvatar: '');

    // Adding listener to the selected team
    TeamSelectionPage.selectedTeam.addListener(() {
      setState(() {
        _canContinue = TeamSelectionPage.selectedTeam.value.teamNum != 0;
      });
    });

    GlobalDataManager.getEventKeyNotifier(eventKey);

    setState(() {
      teams = widget.api.getTeams();
    });

    eventKey.addListener(() {
      setState(() {
        teams = widget.api.getTeams();
      });
      log("Saving teams");
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: orangeAppBar(''),
      drawer: nav.NavigationDrawer(
        api: widget.api,
        schedule: widget.schedule,
      ),
      body: SafeArea(
        child: Center(
          child: Column(children: [
            // Title
            const Padding(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 5),
              child: Text(
                "סקאוטינג פיטים",
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'rubik',
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // Team number input and logo image
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  drawTeams(),
                ],
              ),
            ),

            // Button to continue to the scouting
            Visibility(
              visible: _canContinue,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      height: 50,
                      width: 300,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.orange[600],
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                        ),
                        onPressed: () => (_canContinue)
                            ? (() {
                                log('Continue to scouting');
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: ScoutingMain(
                                          api: widget.api,
                                          schedule: widget.schedule,
                                        )),
                                  ),
                                );
                              })()
                            : (() {
                                log('Can\'t continue to scouting.You totally shouldn\'t see this!');
                              })(),
                        child: const Text(
                          'המשך',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'rubik',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ));

  Expanded drawTeams() {
    return Expanded(
      child: SizedBox(
        height: 500,
        width: 500,
        child: SelectTeam(
          api: widget.api,
        ),
      ),
    );
  }
}

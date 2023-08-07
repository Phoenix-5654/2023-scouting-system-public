import 'dart:math';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:scouting_demo/First_api/first_api.dart';
import 'package:scouting_demo/First_api/match.dart';
import 'package:scouting_demo/pages/Pit_Scouting/photoPage.dart';
import 'package:scouting_demo/pages/Pit_Scouting/scoutingPage.dart';
import 'package:scouting_demo/pages/Pit_Scouting/teamSelectionPage.dart';
import 'package:scouting_demo/widgets/orangeAppBar.dart';

import '../../First_api/team.dart';
import '../../data/teamProfile.dart';
import '../../widgets/PitScouting/messagesView.dart';
import 'autonomusPage.dart';

class ScoutingMain extends StatefulWidget {
  ScoutingMain({
    super.key,
    required this.api,
    required this.schedule,
  });

  FIRST_API api;
  ValueNotifier<Map<String, List<dynamic>>> schedule;

  final Future<TeamProfile> _teamProfile =
      TeamProfile(TeamSelectionPage.selectedTeam.value.teamNum)
          .synchronizeTeam();

  late Widget _selected;

  @override
  State<ScoutingMain> createState() => _ScoutingMainState();
}

class _ScoutingMainState extends State<ScoutingMain> {
  @override
  void initState() {
    super.initState();

    widget._selected = ScoutingPage(
      api: widget.api,
      schedule: widget.schedule,
    );
  }

  Widget drawNavigation(TeamProfile teamProfile) {
    List<Widget> pages = [
      ScoutingPage(
        api: widget.api,
        schedule: widget.schedule,
      ),
      MessagesView(teamProfile: teamProfile),
      PhotoPage(
        teamNumber: TeamSelectionPage.selectedTeam.value.teamNum.toString(),
      ),
    ];

    return Container(
      color: Colors.transparent,
      child: CurvedNavigationBar(
        color: Colors.orange.shade600,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.orange.shade600,
        animationCurve: Curves.easeInOut,
        // Set height to 10% of the screen height or 75 pixels, whichever is smaller.
        height: min(MediaQuery.of(context).size.height * 0.1, 75),
        items: const <Widget>[
          Icon(Icons.article, size: 30, color: Colors.white),
          Icon(Icons.message, size: 30, color: Colors.white),
          Icon(Icons.data_usage, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            widget._selected = pages[index];
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TeamProfile>(
      future: widget._teamProfile,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: orangeAppBar('Pit Scouting'),
            bottomNavigationBar: drawNavigation(snapshot.data!),
            body: widget._selected,
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

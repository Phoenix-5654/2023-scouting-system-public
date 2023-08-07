import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:scouting_demo/First_api/first_api.dart';
import 'package:scouting_demo/First_api/team.dart';
import 'package:scouting_demo/widgets/loadingIndicatorWidget.dart';

import '../../pages/Pit_Scouting/teamSelectionPage.dart';

class SelectTeam extends StatefulWidget {
  SelectTeam({super.key, required this.api});

  FIRST_API api;

  @override
  State<SelectTeam> createState() => _SelectTeamState();
}

class _SelectTeamState extends State<SelectTeam> {
  late List<Team> teams = [];
  late List<Team> shownTeams = [];
  late Future<List<Team>> allTeams = Future.value([]);
  String query = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.api.getTeams(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingIndicator();
        }

        teams = snapshot.data as List<Team>;

        if (query == '') {
          shownTeams = teams;
        }

        // Print all teams
        for (var team in teams) {
          log(team.teamNum);
        }

        return Column(
          children: [
            SearchBar(
              text: query,
              onChanged: ((value) {
                final res = teams.where((team) {
                  final teamNumberLower = team.teamNum.toString();
                  final teamNickNameLower = team.teamNickname.toLowerCase();
                  final queryLower = query.toLowerCase();

                  return teamNumberLower.contains(queryLower) ||
                      teamNickNameLower.contains(queryLower);
                }).toList();

                setState(() {
                  query = value;
                  shownTeams = res;
                });
              }),
              hintText: "חיפוש קבוצה",
            ),

            // Add space
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: shownTeams.length,
                itemBuilder: (context, index) {
                  final team = shownTeams[index];

                  return buildTeam(team);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildTeam(Team team) => ListTile(
        leading: Image.memory(base64Decode(team.encodedAvatar),
            height: 50,
            width: 50,
            errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/Images/no_logo.png',
                  height: 50,
                  width: 50,
                )),
        title: Text(
          team.teamNickname,
          style: TextStyle(
              color:
                  (TeamSelectionPage.selectedTeam.value.teamNum == team.teamNum)
                      ? Colors.orange[700]
                      : Colors.grey[600]),
        ),
        subtitle: Text(
          team.teamNum.toString(),
          style: TextStyle(
              color:
                  (TeamSelectionPage.selectedTeam.value.teamNum == team.teamNum)
                      ? Colors.orange[700]
                      : Colors.grey[600]),
        ),
        onTap: () {
          // Update the list
          setState(() {
            if (TeamSelectionPage.selectedTeam.value.teamNum == team.teamNum) {
              TeamSelectionPage.selectedTeam.value = Team(
                  teamNum: 0,
                  teamNickname: '',
                  encodedAvatar: '',
                  teamName: '');
            } else {
              TeamSelectionPage.selectedTeam.value = team;
            }
          });
        },
      );
}

class SearchBar extends StatefulWidget {
  final String text;
  final ValueChanged<String> onChanged;
  final String hintText;

  const SearchBar({
    Key? key,
    required this.text,
    required this.onChanged,
    required this.hintText,
  }) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: const Icon(Icons.search),
          suffixIcon: widget.text.isNotEmpty
              ? GestureDetector(
                  child: Icon(
                    Icons.close,
                    color: Colors.grey[350],
                  ),
                  onTap: () {
                    controller.clear();
                    widget.onChanged('');
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                )
              : null,
          hintText: widget.hintText,
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}

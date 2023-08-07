import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:scouting_demo/data/teamProfile.dart';
import 'package:scouting_demo/widgets/PitScouting/drawData.dart';

class EditTeamPage extends StatefulWidget {
  final bool doesExist;
  final int teamNum;
  final TeamProfile teamProfile;

  // Creating list of TextEditingControllers
  late Map<QuestionData, TextEditingController> controllers = {};

  EditTeamPage(
      {super.key,
      required this.teamProfile,
      required this.doesExist,
      required this.teamNum}) {
    for (var entry in teamProfile.teamData.value.entries) {
      controllers[entry.key] = TextEditingController();
    }
  }

  @override
  State<EditTeamPage> createState() => _EditTeamPageState();
}

class _EditTeamPageState extends State<EditTeamPage> {
  @override
  Widget build(BuildContext context) {
    bool isPressed = false;
    widget.teamProfile.synchronizeTeam();
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            DrawData(
              baseData: widget.teamProfile.teamData.value,
              isEdit: true,
              controlers: widget.controllers,
              teamProfile: widget.teamProfile,
            ),
            const SizedBox(
              height: 20,
            ),

            // Submit button
            ElevatedButton(
              onPressed: () async {
                if (isPressed) {
                  return;
                }

                isPressed = true;

                // Saving the team profile
                await widget.teamProfile
                    .updateTeamData(addTeam: !widget.doesExist);

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    (isPressed) ? Colors.grey.shade500 : Colors.orange[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
              child: const Text('Submit'),
            )
          ],
        ),
      ),
    );
  }
}

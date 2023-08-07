import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:scouting_demo/data/teamProfile.dart';
import 'package:scouting_demo/widgets/questionDrawer.dart';

class DrawData extends StatelessWidget {
  var baseData = <QuestionData, dynamic>{};
  var teamProfile;
  final bool isEdit;
  final Map<QuestionData, TextEditingController> controlers;
  DrawData({
    super.key,
    required this.baseData,
    required this.isEdit,
    required this.controlers,
    required this.teamProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5))
      ]),
      child: SizedBox(
        height: (isEdit)
            ? MediaQuery.of(context).size.height * 0.65
            : min(MediaQuery.of(context).size.height * 0.65,
                baseData.entries.length * 50.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            // Calling to 'buildRow' for each key and value in the 'baseData'
            // Map.

            for (var entry in baseData.entries)
              buildRow(entry.key, entry.value.toString(), context,
                  (isEdit) ? controlers[entry.key]! : TextEditingController()),
          ],
        ),
      ),
    );
  }

  Widget buildRow(QuestionData question, String value, BuildContext context,
          TextEditingController controller) =>
      Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width / 4),
                    child: Text(
                      question.text,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600),
                    ),
                  ),
                  (isEdit)
                      ? QuestionDrawer(
                          questionData: question,
                          teamProfile: teamProfile,
                          drawQuestion: false,
                        )
                      : Text(
                          value,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                ],
              ),

              // Show a line between each row.
              Container(
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                height: 0.5,
                color: Colors.grey.shade300,
              )
            ],
          ));
}

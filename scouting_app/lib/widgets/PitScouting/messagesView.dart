import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:scouting_demo/data/teamProfile.dart';
import 'package:scouting_demo/widgets/PitScouting/sendMessage.dart';

class MessagesView extends StatelessWidget {
  final TeamProfile teamProfile;
  const MessagesView({super.key, required this.teamProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Make body move on keyboard open
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ValueListenableBuilder(
                  valueListenable: teamProfile.comments,
                  builder: ((context, value, child) => ListView.builder(
                        shrinkWrap: true,
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          final comment = teamProfile.comments.value[index];
                          return buildComment(comment);
                        },
                      )),
                ),
              ),
            ),

            // Comment input
            SendMessage(teamProfile: teamProfile),
          ],
        ),
      ),
    );
  }

  Widget buildComment(Comment comment) => Container(
        margin: const EdgeInsets.fromLTRB(5, 15, 5, 5),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(0),
          ),
        ),
        child: ListTile(
          title: Text(comment.getComment()),
          subtitle: Text(" ${comment.getAuthor()} \n ${comment.getTime()}"),
        ),
      );
}

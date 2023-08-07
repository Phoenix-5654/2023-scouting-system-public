import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:scouting_demo/data/teamProfile.dart';

class SendMessage extends StatefulWidget {
  final TeamProfile teamProfile;
  SendMessage({super.key, required this.teamProfile});
  final messages = ValueNotifier(<String>[]);

  @override
  State<SendMessage> createState() => _SendMessageState();
}

class _SendMessageState extends State<SendMessage> {
  final _controller = TextEditingController();
  String message = '';

  void sendMessage() async {
    FocusScope.of(context).unfocus();

    await widget.teamProfile.addCommment(message);

    // Update the messages list.
    widget.teamProfile.synchronizeTeam();

    message = '';
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: _controller,
                autocorrect: true,
                enableSuggestions: true,
                decoration: InputDecoration(
                  hintText: 'הכנס הערה',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    gapPadding: 5,
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => message = value),
              ),
            ),
            IconButton(
              onPressed: message.trim().isEmpty ? null : sendMessage,
              icon: Icon(
                Icons.send,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:scouting_demo/widgets/robotPhotoWidget.dart';

class PhotoPage extends StatefulWidget {
  const PhotoPage({super.key, required this.teamNumber});

  final teamNumber;

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  var isCm = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RobotPhotoWidget(
          teamNumber: widget.teamNumber,
        ),
      ],
    );
  }
}

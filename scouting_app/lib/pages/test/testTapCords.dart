import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class TestTapCord extends StatefulWidget {
  TestTapCord({super.key, required this.selectedIcon});

  Icon selectedIcon;

  @override
  State<TestTapCord> createState() => _TestTapCordState();
}

class _TestTapCordState extends State<TestTapCord> {
  int marker_x = 0, marker_y = 0;
  bool isPlased = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: GestureDetector(
          // On tap down, print the tap coordinates
          onTapDown: (TapDownDetails details) {
            // Save the tap coordinates relative to the image
            var rel_x = details.localPosition.dx.round();
            var rel_y = details.localPosition.dy.round();

            // Check if coordinates are within the range:
            // 35 <= x <= 400
            // 95 <= y <= 235

            bool inRange = (0 <= rel_x && rel_x <= 115) &&
                    (0 <= rel_y && rel_y <= 90) ||
                (90 <= rel_y && rel_y <= 240) && (0 <= rel_x && rel_x <= 90) ||
                (240 <= rel_y && rel_y <= 330) && (0 <= rel_x && rel_x <= 210);

            log("Tap coordinates: ($rel_x, $rel_y)\nIn range: $inRange");

            if (inRange) {
              setState(() {
                // Saving the coordinates - if they are in range
                marker_x = rel_x;
                marker_y = rel_y;

                // Setting the marker to be placed
                isPlased = true;
              });
            }
          },
          child: Stack(
            children: [
              // The image
              Image.asset(
                'assets/Images/game_field.png',
                fit: BoxFit.scaleDown,
                width: 732,
                height: 586,
                alignment: Alignment.topCenter,
              ),

              // The marker
              if (isPlased)
                Positioned(
                  left: marker_x.toDouble(),
                  top: marker_y.toDouble(),
                  child: Container(
                    width: 10,
                    height: 10,
                    child: widget.selectedIcon,
                  ),
                ),
            ],
          )),
    );
  }
}

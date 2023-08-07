import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:scouting_demo/widgets/counterWidget.dart';

class CountingTable extends StatefulWidget {
  CountingTable({super.key, required this.data, required this.imagePath});

  var data = ValueNotifier(<int>[3]);
  String imagePath;

  @override
  State<CountingTable> createState() => _CountingTableState();
}

class _CountingTableState extends State<CountingTable> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      // Width - 20% of the screen width
      width: math.min(MediaQuery.of(context).size.width * 0.3, 200),
      // Height - 30% of the screen height
      height: math.min(MediaQuery.of(context).size.height * 0.3, 250),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            height: 40,
            width: 40,
            child: Image.asset(widget.imagePath, fit: BoxFit.fill),
          ),
          CounterView(
            initNumber: widget.data.value[0],
            counterCallback: ((p0) {
              log("Updated data: $p0");
            }),
            increaseCallback: () {
              widget.data.value[0]++;
            },
            decreaseCallback: () {
              widget.data.value[0]--;
            },
            minNumber: widget.data.value[0],
          ),
          CounterView(
            initNumber: widget.data.value[1],
            counterCallback: ((p0) {
              log("Updated data: $p0");
            }),
            increaseCallback: () {
              widget.data.value[1]++;
            },
            decreaseCallback: () {
              widget.data.value[1]--;
            },
            minNumber: widget.data.value[1],
          ),
          CounterView(
            initNumber: widget.data.value[2],
            counterCallback: ((p0) {
              log("Updated data: $p0");
            }),
            increaseCallback: () {
              widget.data.value[2]++;
            },
            decreaseCallback: () {
              widget.data.value[2]--;
            },
            minNumber: widget.data.value[2],
          ),
        ],
      ),
    );
  }
}

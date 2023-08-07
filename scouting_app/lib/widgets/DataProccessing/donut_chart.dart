import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class DataItem {
  DataItem({required this.name, required this.value, required this.color});

  String name;
  int value;
  Color color;
}

class DonutChartWidget extends StatefulWidget {
  DonutChartWidget({super.key, required this.data, required this.title});

  List<DataItem> data;
  String title;

  @override
  State<DonutChartWidget> createState() => _DonutChartWidgetState();
}

class _DonutChartWidgetState extends State<DonutChartWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomPaint(
        painter: DonutChartPainter(
          data: widget.data,
          title: widget.title,
        ),
        child: Container(
          width: 200,
          height: 200,
          child: Center(
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  DonutChartPainter({required this.data, required this.title});

  final List<DataItem> data;
  final String title;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);

    final radius = size.width * 0.9;
    final rect = Rect.fromCenter(center: center, width: radius, height: radius);

    var startAngle = 0.0;
    data.forEach((dataItem) {
      log("dataItem.value: ${dataItem.value} | dataItem.name: ${dataItem.name} | dataItem.color: ${dataItem.color}");
      final sweepAngle = (dataItem.value / 100) * 2 * math.pi;
      final paint = Paint()
        ..color = dataItem.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);

      // Draw lines from center to the edge of the chart
      drawLines(radius, startAngle, center, canvas);

      // Draw the text labels
      final textPainter = measureText(
          dataItem.name, TextStyle(color: Colors.white, fontSize: 6));
      final textAngle = startAngle + sweepAngle / 2;
      final dx = radius * 0.8 * math.cos(textAngle);
      final dy = radius * 0.8 * math.sin(textAngle);
      final textOffset = Offset(dx, dy);
      textPainter.paint(
          canvas,
          center +
              textOffset -
              Offset(textPainter.width / 2, textPainter.height / 2));

      startAngle += sweepAngle;
    });

    canvas.drawCircle(center, radius * 0.3, Paint()..color = Colors.white);
  }

  TextPainter measureText(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter;
  }

  void drawLines(
      double radius, double startAngle, Offset center, Canvas canvas) {
    final dx = radius / 2.0 * math.cos(startAngle);
    final dy = radius / 2.0 * math.sin(startAngle);
    final p2 = center + Offset(dx, dy);
    canvas.drawLine(
        center,
        p2,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

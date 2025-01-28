import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pcaweb/controller/ui_controller.dart';

class RankLetter extends StatelessWidget {
  final int overall;
  final double fontSize;
  late final String text2;
  late final Color fillColor;
  late final Color strokeColor;

  RankLetter({
    super.key,
    required this.overall,
    this.fontSize = 50.0, // Default value
  }) {
    if (overall >= 90) {
      text2 = "S";
      fillColor = Colors.black;
      strokeColor = Colors.red;
    } else if (overall >= 80) {
      text2 = "A";
      fillColor = Colors.purple[900]!;
      strokeColor = Colors.grey;
    } else if (overall >= 70) {
      text2 = "B";
      // fillColor = Colors.red;
      // strokeColor = Colors.grey;

      // ---
      fillColor = Colors.yellow[800]!;
      strokeColor = Colors.brown;
    } else if (overall >= 60) {
      text2 = "C";
      fillColor = Colors.grey[700]!;
      strokeColor = Colors.grey;
    } else {
      text2 = "D";
      fillColor = Colors.grey[800]!;
      strokeColor = Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Text(
          text2,
          style: TextStyle(
            fontSize: fontSize.sp,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = isMobile(context) ? 3 : 15
              ..color = strokeColor,
          ),
        ),
        Text(
          text2,
          style: TextStyle(
            fontSize: fontSize.sp,
            fontWeight: FontWeight.bold,
            color: fillColor,
          ),
        ),
      ],
    );
  }
}

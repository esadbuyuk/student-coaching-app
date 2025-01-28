import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/my_constants.dart';

class SkillCard extends StatelessWidget {
  const SkillCard({
    Key? key,
    required this.stat,
    required this.skillName,
  }) : super(key: key);

  final int stat;
  final String skillName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      child: Column(
        children: [
          FittedBox(
            child: Text(
              skillName, // burası responsive hale getirilecek.
              style: myThightStyle(color: mySecondaryTextColor, fontSize: 7),
            ),
          ),
          Text(
            stat.toInt().toString(),
            style: myDigitalStyle(fontSize: 21, color: mySecondaryTextColor),

            // fontStyle: digital eklenecek
          ),
        ],
      ),
    );
  }
}

class TonicSkillCard extends StatelessWidget {
  const TonicSkillCard({
    Key? key,
    required this.stat,
    required this.skillName,
  }) : super(key: key);

  final int stat;
  final String skillName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width: 40.w,
      child: Column(
        children: [
          FittedBox(
            child: Text(
              skillName, // burası responsive hale getirilecek.
              style: myTonicStyle(myTextColor, fontSize: 13),
            ),
          ),
          Text(
            stat.toInt().toString(),
            style: myDigitalStyle(color: myTextColor, fontSize: 11),

            // fontStyle: digital eklenecek
          ),
        ],
      ),
    );
  }
}

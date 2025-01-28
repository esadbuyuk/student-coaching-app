
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/my_constants.dart';
import '../../model/disciple.dart';

class PlayerCard extends StatelessWidget {
  const PlayerCard({
    Key? key,
    required this.playerData,
    required this.playerCardHeight,
    this.color = Colors.transparent,
  }) : super(key: key);

  final Disciple playerData;
  final double playerCardHeight;
  final Color color;

  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: myPrimaryColor),
        borderRadius: BorderRadius.all(Radius.circular(11.r)),
      ),
      height: playerCardHeight,
      alignment: Alignment.centerLeft,
      child: buildCardContent(context),
    );
  }

  Widget buildCardContent(BuildContext context) {
    return Text(style: myThightStyle(), playerData.surname);
  }
}

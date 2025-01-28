import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/my_constants.dart';

class OverallButton extends StatefulWidget {
  final String skillName;
  final String currentScore;
  final Color color;
  final dynamic onTapFunc;
  final bool showScores;

  const OverallButton({
    Key? key,
    required this.skillName,
    required this.currentScore,
    required this.onTapFunc,
    this.color = myPrimaryColor,
    this.showScores = true,
  }) : super(key: key);

  @override
  State<OverallButton> createState() => _OverallButtonState();
}

class _OverallButtonState extends State<OverallButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: myPrimaryColor,
      onTap: () {
        widget.onTapFunc();
      },
      child: SizedBox(
        width: 116.w,
        // height: 120.h,
        child: Card(
          color: widget.color,
          shadowColor: mySecondaryColor,
          elevation: 3.h,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(0),
            child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    style: myTonicStyle(myTextColor, fontSize: 11),
                    widget.skillName,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  if (widget.showScores)
                    Text(
                      style: myDigitalStyle(color: myTextColor, fontSize: 11),
                      widget.currentScore,
                    ),
                  SizedBox(
                    height: 10.h,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

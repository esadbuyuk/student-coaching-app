import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pcaweb/controller/ui_controller.dart';

import '../../model/my_constants.dart';

class CardNameText extends StatelessWidget {
  const CardNameText({
    super.key,
    required this.textColors,
    required this.name,
    this.darkMode = true,
  });

  final Color textColors;
  final String name;
  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: isMobile(context) ? 15.w : 5.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 4.h,
              height: 4.h,
              color: darkMode ? myPrimaryColor : myBackgroundColor,
            ),
          ),
          SizedBox(
            width: isMobile(context) ? 9.w : 3.w,
          ),
          SizedBox(
            height: 17.h,
            child: FittedBox(
              child: Text(
                name.toUpperCase(),
                style: myTonicStyle(textColors, fontSize: 7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

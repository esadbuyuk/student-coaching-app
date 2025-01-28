import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/my_constants.dart';

class CardNameText extends StatelessWidget {
  const CardNameText({
    super.key,
    required this.textColors,
    required this.name,
  });

  final Color textColors;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 5.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 4.h,
              height: 4.h,
              color: myPrimaryColor,
            ),
          ),
          SizedBox(
            width: 3.w,
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

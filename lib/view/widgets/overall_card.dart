import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/my_constants.dart';
import '../../view/widgets/rank_letter.dart';

class OverallCard extends StatelessWidget {
  const OverallCard({
    Key? key,
    required this.overall,
  }) : super(key: key);

  final int? overall;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 95.w,
      decoration: BoxDecoration(
        color: darkMode
            ? Colors.black.withOpacity(0.2)
            : Colors.white.withOpacity(0.2),
        border: Border.all(
            color: darkMode ? myPrimaryColor : myPrimaryColor, width: 0.8),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(5),
          bottomRight: Radius.circular(5),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 15.h,
          ),
          Text(
            style: myThightStyle(color: mySecondaryTextColor),
            'TOTAL',
          ),
          SizedBox(
            height: 38.h,
            child: Text(
              style: myDigitalStyle(
                fontSize: 21,
                color: mySecondaryTextColor,
              ),
              overall == null ? "0" : overall.toString(),
            ),
          ),
          Expanded(
            child: SizedBox(
              child: FittedBox(
                // fit: BoxFit.fitHeight,
                child: RankLetter(
                  overall: overall ?? 0,
                  //fontSize: 40.sp,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
        ],
      ),
    );
  }
}

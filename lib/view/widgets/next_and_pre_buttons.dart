import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../controller/string_operations.dart';
import '../../model/my_constants.dart';

class NextAndPreButtons extends StatelessWidget {
  final void Function() nextFunc;
  final void Function() previousFunc;
  final bool displayName;
  final bool isPaddingOn;
  final String? name;
  final String? surname;

  const NextAndPreButtons({
    Key? key,
    required this.nextFunc,
    required this.previousFunc,
    this.displayName = false,
    this.isPaddingOn = false,
    this.name,
    this.surname,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color iconsColor = myAccentColor;
    return SizedBox(
      height: 60.h,
      width: 300,
      child: Padding(
        padding: EdgeInsets.only(
            left: isPaddingOn ? 30.h : 0, right: isPaddingOn ? 30.h : 0),
        child: Row(
          // mainAxisSize: MainAxisSize.max,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: previousFunc,
              icon: SvgPicture.asset(
                'assets/icons/previous_icon.svg',
                color: iconsColor,
                width: 25.h,
                height: 25.h,
              ),
            ),
            Expanded(
              child: displayName
                  ? Container(
                      alignment: Alignment.center,
                      child: Text(
                        getTruncateNameSurname(name!, surname!),
                        style: myTonicStyle(mySecondaryTextColor),
                      ),
                    )
                  : const SizedBox(),
            ),
            IconButton(
              onPressed: nextFunc,
              icon: SvgPicture.asset(
                'assets/icons/next_icon.svg',
                color: iconsColor,
                width: 25.h,
                height: 25.h,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../controller/image_clipper.dart';
import '../../controller/string_operations.dart';
import '../../model/disciple.dart';
import '../../model/my_constants.dart';
import '../../view/widgets/player_card.dart';

class PlayerProfileCard extends PlayerCard {
  const PlayerProfileCard({
    Key? key,
    required Disciple playerData,
    required double playerCardHeight,
  }) : super(
            key: key,
            playerData: playerData,
            playerCardHeight: playerCardHeight);

  @override
  Widget buildCardContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 30.w,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // Profile Photo
          children: [
            SizedBox(
              // profile Photo
              width: 58.w,
              height: 60.h,
              child: PentagonImage(imagePath: playerData.profilePicture),
            ),
          ],
        ),
        SizedBox(
          width: 30.w,
        ),
        buildProfileTexts(playerData)
      ],
    );
  }

  Column buildProfileTexts(Disciple playerData) {
    double spaceBetween = 5.h;
    // double topAndBottomSpace = 4.h;
    TextStyle styleOfDarkTexts = myThightStyle(color: myPrimaryColor);
    TextStyle styleOfLightTexts = myThightStyle(color: mySecondaryTextColor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // builtSpacer(topAndBottomSpace),
        Row(
          children: [
            Text(
              "NAME: ",
              style: styleOfDarkTexts,
            ),
            Text(
              getTruncateName(playerData.name, maxLength: 15).toUpperCase(),
              style: styleOfLightTexts,
            ),
          ],
        ),
        builtSpacer(spaceBetween),
        Row(
          children: [
            Text(
              "SURNAME: ",
              style: styleOfDarkTexts,
            ),
            Text(
              getTruncateName(playerData.surname, maxLength: 11).toUpperCase(),
              style: styleOfLightTexts,
            ),
          ],
        ),
        builtSpacer(spaceBetween),
        Row(
          children: [
            Text(
              "AGE: ",
              style: styleOfDarkTexts,
            ),
            builtSpacer(spaceBetween),
            Text(
              playerData.age == null ? "-" : "${playerData.age}".toUpperCase(),
              style: styleOfLightTexts,
            ),
            builtSpacer(spaceBetween),
          ],
        ),
        builtSpacer(spaceBetween),
        Row(
          children: [
            Text(
              "POSITION: ",
              style: styleOfDarkTexts,
            ),
            builtSpacer(spaceBetween),
            Text(
              getTruncateName(playerData.position!, maxLength: 11)
                  .toUpperCase(),
              style: styleOfLightTexts,
            ),
            // builtSpacer(topAndBottomSpace),
          ],
        ),
      ],
    );
  }

  Row buildProfileTexts2(Disciple playerData) {
    // max length' lere tekrar bakman gerekebilir.
    double spaceBetween = 5.h;
    TextStyle styleOfDarkTexts = myThightStyle(color: myTextColor);
    TextStyle styleOfLightTexts = myThightStyle(color: mySecondaryTextColor);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "NAME: ",
              style: styleOfDarkTexts,
            ),
            builtSpacer(spaceBetween),
            Text(
              "SURNAME: ",
              style: styleOfDarkTexts,
            ),
            builtSpacer(spaceBetween),
            Text(
              "AGE: ",
              style: styleOfDarkTexts,
            ),
            builtSpacer(spaceBetween),
            Text(
              "POSITION: ",
              style: styleOfDarkTexts,
            ),
          ],
        ),
        SizedBox(
          width: 10.h,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getTruncateName(playerData.name, maxLength: 10).toUpperCase(),
              style: styleOfLightTexts,
            ),
            builtSpacer(spaceBetween),
            Text(
              playerData.surname.toUpperCase(),
              style: styleOfLightTexts,
            ),
            builtSpacer(spaceBetween),
            Text(
              "${playerData.age}".toUpperCase(),
              style: styleOfLightTexts,
            ),
            builtSpacer(spaceBetween),
            Text(
              "${playerData.position}".toUpperCase(),
              style: styleOfLightTexts,
            ),
          ],
        ),
      ],
    );
  }

  SizedBox builtSpacer(double spaceBetween) {
    return SizedBox(
      height: spaceBetween,
    );
  }

  Divider buildDivider() {
    return Divider(
      color: myDividerColor,
      thickness: 2.h,
    );
  }
}

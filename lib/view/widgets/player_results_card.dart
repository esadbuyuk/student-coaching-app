import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../controller/image_clipper.dart';
import '../../controller/string_operations.dart';
import '../../model/disciple.dart';
import '../../model/my_constants.dart';
import '../../view/widgets/player_card.dart';

class PlayerResultsCard extends PlayerCard {
  final Color textColor;

  const PlayerResultsCard({
    Key? key,
    required Disciple playerData,
    required double playerCardHeight,
    Color color = Colors
        .transparent, // Burada varsayılan bir renk değeri belirtebilirsiniz.
    this.textColor = mySecondaryTextColor, // Default value for textColor
  }) : super(
          key: key,
          playerData: playerData,
          playerCardHeight: playerCardHeight,
          color: color, // Üst sınıfın color parametresine geçiriyoruz.
        );

  @override
  Widget buildCardContent(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20.w,
        ),
        buildNameAndPhoto(),
        Expanded(
          child: SizedBox(
            width: 30.w,
          ),
        ),
        Text(style: myThightStyle(color: textColor), "WRITE NEW RESULTS"),
        SizedBox(
          width: 30.w,
        ),
      ],
    );
  }

  SizedBox buildNameAndPhoto() {
    return SizedBox(
      width: 65.w,
      child: Column(
        // Profile Photo and Name
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          FittedBox(
            fit: (getTruncateName(playerData.name).length > 10)
                ? BoxFit.fitWidth
                : BoxFit.none,
            child: Text(
              style: myTonicStyle(textColor),
              getTruncateName(playerData.name),
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
          SizedBox(
            // profile Photo
            width: 48.w,
            height: 50.h,
            child: PentagonImage(imagePath: playerData.profilePicture),
          ),
        ],
      ),
    );
  }
}

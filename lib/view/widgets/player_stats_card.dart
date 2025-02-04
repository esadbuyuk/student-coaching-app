import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../controller/disciple_controller.dart';
import '../../controller/image_clipper.dart';
import '../../controller/string_operations.dart';
import '../../model/disciple.dart';
import '../../model/my_constants.dart';
import '../../model/score.dart';
import '../../view/widgets/rank_letter.dart';
import 'hexagon_chart.dart';
import 'player_card.dart';

class PlayerStatsCard extends PlayerCard {
  const PlayerStatsCard({
    Key? key,
    required final Disciple playerData,
    required final double playerCardHeight,
  }) : super(
            key: key,
            playerData: playerData,
            playerCardHeight: playerCardHeight);

  @override
  Widget buildCardContent(BuildContext context) {
    Future<List<Score>> skillsDataFuture;

    skillsDataFuture =
        DiscipleController(playerData.id).fetchDiscipleSkillsData();

    return ConstrainedBox(
      constraints:
          BoxConstraints(maxWidth: discipleCardWidth.w), // Max width specified

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(width: 20.w),
          buildNameAndPhoto(),
          const Expanded(
            child: SizedBox(),
          ),
          FutureBuilder<List<Score>>(
            future: skillsDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'No Connection',
                    style: myTonicStyle(myAccentColor, fontSize: 10),
                  ),
                );
              } else if (snapshot.hasData) {
                final skillsData = snapshot.data!;
                List<double> skillScores =
                    skillsData.map((score) => score.score.toDouble()).toList();
                // Eleman sayıları 5'ten azsa, 5 elemana tamamla
                while (skillScores.length < 5) {
                  skillScores.add(0.0);
                }

                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: SizedBox(
                      height: 70.h,
                      width: 70.w,
                      child: PolygonChart(
                        data: skillScores,
                        numberOfSides: 5,
                      )),
                );
              } else {
                return const Center(child: Text('No data available'));
              }
            },
          ),
          const Expanded(
            child: SizedBox(),
          ),
          SizedBox(
            width: 30.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 13.h,
                  child: FittedBox(
                    child: Text(
                      style: myThightStyle(color: mySecondaryTextColor),
                      'TOTAL',
                    ),
                  ),
                ),
                SizedBox(
                  height: 28.h,
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: Text(
                      style: myDigitalStyle(
                          fontSize: 16, color: mySecondaryTextColor),
                      playerData.overall == null
                          ? "0"
                          : playerData.overall.toString(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50.h,
                  child: FittedBox(
                    child: RankLetter(
                      overall: playerData.overall ?? 0,
                      fontSize: 32,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5.h,
                )
              ],
            ),
          ),
          SizedBox(width: 25.w),
        ],
      ),
    );
  }

  SizedBox buildNameAndPhoto() {
    return SizedBox(
      width: 65.w,
      child: Column(
        // Profile Photo and Name
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          FittedBox(
            fit: (getTruncateName(playerData.name).length > 10)
                ? BoxFit.fitWidth
                : BoxFit.none,
            child: Text(
              style: myTonicStyle(mySecondaryTextColor),
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
          SizedBox(
            height: 15.h,
          )
        ],
      ),
    );
  }
}

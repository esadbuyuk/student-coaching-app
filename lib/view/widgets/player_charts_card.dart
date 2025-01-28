import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../controller/image_clipper.dart';
import '../../controller/score_controller.dart';
import '../../controller/string_operations.dart';
import '../../model/disciple.dart';
import '../../model/my_constants.dart';
import '../../model/score.dart';
import '../../view/widgets/rank_letter.dart';
import '../../view/widgets/score_chart2.dart';

class PlayerChartsCard extends StatefulWidget {
  final Disciple playerData;
  final double playerCardHeight;

  const PlayerChartsCard({
    Key? key,
    required this.playerData,
    required this.playerCardHeight,
  }) : super(key: key);

  @override
  PlayerChartsCardState createState() => PlayerChartsCardState();
}

class PlayerChartsCardState extends State<PlayerChartsCard> {
  late Future<List<Score>> scoresFuture;
  late ScoreController scoreController;

  @override
  void initState() {
    super.initState();
    scoreController = ScoreController();
    scoresFuture =
        scoreController.fetchOverallScoresWithDates(widget.playerData.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: myPrimaryColor),
        borderRadius: BorderRadius.all(Radius.circular(11.r)),
      ),
      height: widget.playerCardHeight,
      alignment: Alignment.centerLeft,
      child: buildCardContent(),
    );
  }

  Row buildCardContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 20.w,
        ),
        buildNameAndPhoto(),
        const Expanded(
          child: SizedBox(),
        ),
        FutureBuilder(
          future: scoresFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text(
                'No Connection',
                style: myTonicStyle(myAccentColor, fontSize: 10),
              ));
            } else if (snapshot.hasData) {
              final scoresData = snapshot.data as List<Score>;
              return Padding(
                padding: EdgeInsets.only(bottom: 18.h),
                child: SizedBox(
                    width: chartWidthCalculator(scoresData.length),
                    height: 60.h,
                    child: ScoreChart2(
                      scores: scoresData,
                      showTags: false,
                    )),
              );
            } else {
              return const Center(child: Text('Player not found.'));
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
                    widget.playerData.overall == null
                        ? "0"
                        : widget.playerData.overall.toString(),
                  ),
                ),
              ),
              SizedBox(
                height: 50.h,
                child: FittedBox(
                  child: RankLetter(
                    overall: widget.playerData.overall ?? 0,
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
        SizedBox(
          width: 20.w,
        ),
      ],
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
            fit: (getTruncateName(widget.playerData.name).length > 10)
                ? BoxFit.fitWidth
                : BoxFit.none,
            child: Text(
              style: myTonicStyle(mySecondaryTextColor),
              getTruncateName(widget.playerData.name),
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
          SizedBox(
            // profile Photo
            width: 48.w,
            height: 50.h,
            child: PentagonImage(imagePath: widget.playerData.profilePicture),
          ),
          SizedBox(
            height: 15.h,
          )
        ],
      ),
    );
  }

  double chartWidthCalculator(int length) {
    return 72.w;
  }
}

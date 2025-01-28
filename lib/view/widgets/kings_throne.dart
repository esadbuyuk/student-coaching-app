import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pcaweb/view/widgets/multi_line_chart.dart';

import '../../model/my_constants.dart';

class KingsThrone extends StatefulWidget {
  const KingsThrone({
    super.key,
    required this.lessonName,
    required this.discipleName,
  });
  final String lessonName;
  final String discipleName;

  @override
  State<KingsThrone> createState() => _KingsThroneState();
}

class _KingsThroneState extends State<KingsThrone> {
  double verticalSpace = 20.h;
  double lateralSpace = 20.h;
  int rank = 1;
  String nameSurname = "Sedat";
  String net = "114";
  Color? thirdColor = Colors.brown[900];
  Color? firstColor = Colors.orange[300];
  Color secondColor = Colors.grey;
  @override
  Widget build(BuildContext context) {
    Color? lessonColor =
        MultiLineScoreChartPainter.colorMap[widget.lessonName.toLowerCase()];

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4), // Gölge rengi ve opaklığı
            blurRadius: 10, // Gölgenin yayılma miktarı
            offset: const Offset(5, 5), // Gölgenin x ve y eksenindeki kayması
          ),
        ],
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
        border: Border.all(
          color: myPrimaryColor,
          width: 0.8,
        ),
        color: darkMode ? myBackgroundColor : myPrimaryColor,
      ),
      child: Column(
        children: [
          buildVerticalSpacer(),
          Text(
            widget.lessonName.toUpperCase(),
            style: myTonicStyle(mySecondaryTextColor),
          ),
          buildSpacer(),

          // Second Place
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildSpacer(),

              // First Place
              buildNameColumn(widget.lessonName, lessonColor ?? myAccentColor,
                  widget.discipleName),
              buildSpacer(),
            ],
          ),
        ],
      ),
    );
  }

  Column buildNameColumn(
      String lessonName, Color lessonColor, String nameSurname) {
    return Column(
      children: [
        buildCrown(lessonName, lessonColor),
        SizedBox(height: 10.h),
        Text(
          nameSurname,
          style: myTonicStyle(mySecondaryTextColor),
        ),
        Row(
          children: [
            Text(
              net,
              style: myDigitalStyle(color: mySecondaryTextColor),
            ),
            SizedBox(
              width: 1.w,
            ),
            Text(
              "net ortalaması",
              style: myTonicStyle(mySecondaryTextColor),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        buildThrone(lessonColor, lessonName),
      ],
    );
  }

  Container buildThrone(Color lessonColor, String lessonName) {
    return Container(
      height: 60,
      width: 250,
      decoration: BoxDecoration(
        color: lessonColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
        border: Border.all(
          color: mySecondaryColor,
          width: 0.8,
        ),
      ),
      child: Center(
        child: Text(
          ("kral" + " tahtı").toUpperCase(),
          style: myTonicStyle(myTextColor, fontSize: 15),
        ),
      ),
    );
  }

  Center buildCrown(String lessonName, lessonColor) {
    return Center(
      child: Image(
        width: 200.h,
        height: 100.h,
        color: Colors.orangeAccent,
        image: const AssetImage("assets/icons/kings_crown.png"),
      ),
    );
  }

  Container buildVerticalSpacer() {
    return Container(
      height: verticalSpace,
    );
  }

  Container buildLateralSpacer() {
    return Container(
      width: lateralSpace,
    );
  }
}

Expanded buildSpacer() => Expanded(
      child: Container(),
    );

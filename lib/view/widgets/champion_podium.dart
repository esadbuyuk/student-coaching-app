import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pcaweb/view/widgets/multi_line_chart.dart';

import '../../model/my_constants.dart';

class ChampionPodium extends StatefulWidget {
  const ChampionPodium({
    super.key,
    required this.lessonName,
    required this.discipleName,
  });
  final String lessonName;
  final String discipleName;

  @override
  State<ChampionPodium> createState() => _ChampionPodiumState();
}

class _ChampionPodiumState extends State<ChampionPodium> {
  double verticalSpace = 20.h;
  double lateralSpace = 20.h;
  int rank = 1;
  String nameSurname = "Sedat";
  String net = "24";
  Color? thirdColor = Colors.brown[900];
  Color? firstColor = Colors.orange[300];
  double shadowBoxWidths = 200;
  Color secondColor = Colors.grey;
  @override
  Widget build(BuildContext context) {
    Random random = Random();
    int randomNumber = random.nextInt(10);
    net = "${15 + randomNumber}";

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildVerticalSpacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
              border: Border.all(
                color: mySecondaryColor,
                width: 0.8,
              ),
            ),
            width: shadowBoxWidths,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Text(
                  widget.lessonName.toUpperCase(),
                  style: myTonicStyle(lessonColor!),
                ),
              ),
            ),
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
        selectTrophy(lessonName, lessonColor),
        SizedBox(height: 10.h),
        Text(
          nameSurname,
          style: myTonicStyle(myIconsColor),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              net,
              style: myDigitalStyle(
                  color: darkMode ? mySecondaryTextColor : myTextColor,
                  fontSize: 20),
            ),
            SizedBox(
              width: 1.w,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 3.0),
              child: Text(
                "net artışı",
                style: myTonicStyle(
                    darkMode ? mySecondaryTextColor : myTextColor,
                    fontSize: 9),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        //buildPodium(lessonColor, lessonName),
      ],
    );
  }

  Center selectTrophy(String lessonName, lessonColor) {
    Color cupColor = lessonColor;
    String cupName = "assets/icons/trophy_5.png";
    return buildTrophy(lessonColor, cupName);
  }

  Center buildTrophy(Color cupColor, String cupName) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow Effect - Blur Effect with BackdropFilter
          Container(
            width: 80.h, // Biraz daha büyük yaparak glow efekti veririz
            height: 120.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: cupColor.withOpacity(0.3), // Glow Rengi
                  blurRadius: 35, // Ne kadar yayılacağını belirler
                  spreadRadius: 1, // Parlaklığın yayılma oranı
                ),
              ],
            ),
          ),
          // Actual Image Widget
          Image(
            width: 100.h,
            height: 100.h,
            color: cupColor,
            image: AssetImage(cupName),
          ),
        ],
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

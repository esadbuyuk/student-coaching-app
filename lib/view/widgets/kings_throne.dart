import 'dart:math';

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
  double shadowBoxWidths = 200;

  @override
  Widget build(BuildContext context) {
    Random random = Random();
    int randomNumber = random.nextInt(20);
    net = "${15 + randomNumber}";

    Color? lessonColor =
        MultiLineScoreChartPainter.colorMap[widget.lessonName.toLowerCase()];
    String lessonThroneName;
    if (widget.lessonName.toLowerCase() == "matematik") {
      lessonThroneName = "assets/images/thrones/islamic_throne_7.png";
    } else if (widget.lessonName.toLowerCase() == "türkçe") {
      lessonThroneName = "assets/images/thrones/islamic_throne_6_clipped.png";
    } else if (widget.lessonName.toLowerCase() == "fizik") {
      lessonThroneName = "assets/images/thrones/islamic_throne_9.png";
    } else if (widget.lessonName.toLowerCase() == "biyoloji") {
      lessonThroneName =
          "assets/images/thrones/islamic_throne_1_clipped.png"; // 10
    } else if (widget.lessonName.toLowerCase() == "kimya") {
      lessonThroneName =
          "assets/images/thrones/islamic_throne_8_clipped.png"; // 8
    } else if (widget.lessonName.toLowerCase() == "sosyal") {
      lessonThroneName =
          "assets/images/thrones/islamic_throne_10_clipped.png"; // 1
    } else {
      lessonThroneName = "assets/images/thrones/islamic_throne_7.png";
    }
    return Container(
      decoration: BoxDecoration(
        // image: DecorationImage(
        //   fit: BoxFit.cover,
        //   image: AssetImage(lessonThroneName),
        // ),
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
          Container(
            alignment: Alignment.center,
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
              child: Text(
                widget.lessonName.toUpperCase(),
                style: myTonicStyle(lessonColor!),
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

  Column buildNameColumn2(
      String lessonName, Color lessonColor, String nameSurname) {
    return Column(
      children: [
        Container(
          width: shadowBoxWidths,
          // decoration: BoxDecoration(
          //   color: Colors.black.withOpacity(0.5),
          //   borderRadius: const BorderRadius.only(
          //     topLeft: Radius.circular(5),
          //     topRight: Radius.circular(5),
          //   ),
          //   border: Border.all(
          //     color: mySecondaryColor,
          //     width: 0.8,
          //   ),
          // ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 22.0),
            child: Column(
              children: [
                buildCrown(lessonName, lessonColor),
                SizedBox(height: 0.h),
                Text(
                  nameSurname,
                  style: myTonicStyle(myIconsColor),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 60.h),
        buildNameColumn(lessonName, lessonColor, nameSurname),
      ],
    );
  }

  Column buildNameColumn(
      String lessonName, Color lessonColor, String nameSurname) {
    return Column(
      children: [
        buildCrown(lessonName, lessonColor), SizedBox(height: 10.h),
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
                "net ortalaması",
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

  SizedBox buildThrone(
      Color lessonColor, String lessonName, String nameSurname) {
    return SizedBox(
      height: 60.h,
      width: shadowBoxWidths,
      // decoration: BoxDecoration(
      //   color: Colors.black.withOpacity(0.3),
      //   borderRadius: const BorderRadius.only(
      //     topLeft: Radius.circular(5),
      //     topRight: Radius.circular(5),
      //   ),
      //   border: Border.all(
      //     color: mySecondaryColor,
      //     width: 0.8,
      //   ),
      // ),

      child: Center(
        child: Column(
          children: [
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
                    "net ortalaması",
                    style: myTonicStyle(
                        darkMode ? mySecondaryTextColor : myTextColor,
                        fontSize: 9),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
      // child: Center(
      //   child: Text(
      //     ("kral" + " tahtı").toUpperCase(),
      //     style: myTonicStyle(myTextColor, fontSize: 15),
      //   ),
      // ),
    );
  }

  Center buildCrown(String lessonName, Color lessonColor) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow Effect - Blur Effect with BackdropFilter
          Container(
            width: 120.h, // Biraz daha büyük yaparak glow efekti veririz
            height: 60.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.orangeAccent.withOpacity(0.5), // Glow Rengi
                  blurRadius: 35, // Ne kadar yayılacağını belirler
                  spreadRadius: 1, // Parlaklığın yayılma oranı
                ),
              ],
            ),
          ),
          // Actual Image Widget
          Image(
            width: 200.h,
            height: 100.h,
            color: Colors.orangeAccent,
            image: const AssetImage("assets/icons/kings_crown.png"),
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

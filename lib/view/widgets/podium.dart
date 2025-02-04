import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/my_constants.dart';

class Podium extends StatefulWidget {
  const Podium({
    super.key,
  });

  @override
  State<Podium> createState() => _PodiumState();
}

class _PodiumState extends State<Podium> {
  double verticalSpace = 20.h;

  double lateralSpace = 50.h;
  int rank = 1;
  String nameSurname = "Sedat";
  String net = "114";
  Color? thirdColor = Colors.brown[900];
  Color? firstColor = Colors.orange[300];
  Color secondColor = Colors.grey;
  @override
  Widget build(BuildContext context) {
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
          buildSpacer(),

          // Second Place
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildSpacer(),

              // Second Place
              buildNameColumn(2, "Zahit Ertuğrul"),
              buildLateralSpacer(),

              // First Place
              buildNameColumn(1, "Yusuf Biber"),
              buildLateralSpacer(),

              // Third Place
              buildNameColumn(3, "Mehmet Toprak"),
              buildSpacer(),
            ],
          ),
        ],
      ),
    );
  }

  Column buildNameColumn(int rank, String nameSurname) {
    Random random = Random();
    int randomNumber = random.nextInt(20);
    net = "${100 + randomNumber}";

    return Column(
      children: [
        selectTrophy(rank),
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
              style: myDigitalStyle(color: mySecondaryTextColor, fontSize: 20),
            ),
            SizedBox(
              width: 1.w,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 3.0),
              child: Text(
                "net",
                style: myTonicStyle(mySecondaryTextColor, fontSize: 9),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        buildPodium(rank),
      ],
    );
  }

  Container buildPodium(rank) {
    switch (rank) {
      case 2:
        return Container(
          height: 60,
          width: 50,
          decoration: BoxDecoration(
            color: secondColor,
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
              "2",
              style: myDigitalStyle(fontSize: 20),
            ),
          ),
        );
      case 1:
        return Container(
            height: 80,
            width: 70,
            decoration: BoxDecoration(
              color: firstColor,
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
                "1",
                style: myDigitalStyle(fontSize: 24),
              ),
            ));
      case 3:
        return Container(
          height: 40,
          width: 50,
          decoration: BoxDecoration(
            color: thirdColor,
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
              "3",
              style: myDigitalStyle(fontSize: 18, color: mySecondaryTextColor),
            ),
          ),
        );
      default:
        return Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: thirdColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
            ),
            border: Border.all(
              color: mySecondaryColor,
              width: 0.8,
            ),
          ),
          child: const Center(
            child: Text(
              "3",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
    }
  }

  Center selectTrophy(int rank) {
    String firstCup = "assets/icons/trophy_7_fixed.png";
    String secondCup = "assets/icons/trophy_6.png";
    String thirdCup = "assets/icons/trophy_3.png";

    Color firstCupColor = firstColor ?? myAccentColor;
    Color secondCupColor = secondColor ?? myAccentColor;
    Color thirdCupColor = thirdColor ?? myAccentColor;

    switch (rank) {
      case 1:
        return buildTrophy(firstCupColor, firstCup);

      case 2:
        return buildTrophy(secondCupColor, secondCup);
      default:
        return buildTrophy(thirdCupColor, thirdCup);
    }
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

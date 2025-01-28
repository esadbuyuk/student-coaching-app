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

  double lateralSpace = 20.h;
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
              buildNameColumn(1, "Ali Cabbar"),
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
    return Column(
      children: [
        buildTrophy(rank),
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
              "net",
              style: myTonicStyle(mySecondaryTextColor),
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
          child: const Center(
            child: Text(
              "2",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: myIconsColor,
              ),
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
            child: const Center(
              child: Text(
                "1",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: myIconsColor,
                ),
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
          child: const Center(
            child: Text(
              "3",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: myIconsColor,
              ),
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

  Center buildTrophy(int rank) {
    switch (rank) {
      case 1:
        return Center(
          child: Image(
            width: 100.h,
            height: 100.h,
            color: firstColor,
            image: const AssetImage("assets/icons/trophy_7_fixed.png"),
          ),
        );
      case 2:
        return Center(
          child: Image(
            width: 100.h,
            height: 100.h,
            color: secondColor,
            image: const AssetImage("assets/icons/trophy_6.png"),
          ),
        );
      default:
        return Center(
          child: Image(
            width: 100.h,
            height: 100.h,
            color: thirdColor,
            image: const AssetImage("assets/icons/trophy_3.png"),
          ),
        );
    }
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pcaweb/controller/ui_controller.dart';
import 'package:pcaweb/view/widgets/champion_podium.dart';

import '../../controller/disciple_controller.dart';
import '../../controller/score_controller.dart';
import '../../controller/user_controller.dart';
import '../../model/disciple.dart';
import '../../model/my_constants.dart';
import '../../model/score.dart';
import '../widgets/kings_throne.dart';
import '../widgets/multi_line_chart.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/podium.dart';

class MonthlyAwardsPage extends StatefulWidget {
  const MonthlyAwardsPage({Key? key}) : super(key: key);

  @override
  MonthlyAwardsPageState createState() => MonthlyAwardsPageState();
}

class MonthlyAwardsPageState extends State<MonthlyAwardsPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool _showSubSkills = true;
  late Future<Disciple> playerFuture;
  late Future<List<Score>> skillsDataFuture;
  late Future<List<Score>>? subStatsFuture;
  double indicatorRadius = 60.h;
  double appBarHeight = 80.h;
  int animationTime = 900;
  int initialItemIndex = 0;
  int selectedItemIndex = 0; // initialItemIndex ile aynı olmalı!
  int? selectedItemID; // initialItemIndex ile aynı olmalı!
  Curve animationType = Curves.easeInOut;
  late FixedExtentScrollController _wheelScrollController;
  late DiscipleController playerController;
  late int currentPlayerID;
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<double>? subValuesList;
  List<String>? subKeysList;
  Key subStatsFutureResetterKey = UniqueKey();
  late int playerID;
  final UserController _userController = UserController();
  late Future<List<Score>> scoresFuture;
  late Future<Map<String, List<Score>>> multiScoresFuture;
  late ScoreController scoreController;
  double verticalSpace = 140.h;
  double lateralSpace = 40.h;
  int? headersStatValue;
  String? headersLabel;
  int totalQuestions = 20;
  int correct = 14;
  int wrong = 2;
  int empty = 4;

  @override
  void initState() {
    super.initState();
    MultiLineScoreChartPainter.resetColors();
  }

  @override
  Widget build(BuildContext context) {
    double leftPaddingSize = 40.w;
    // height lengths
    double columnHeight = 630.h;
    double singleLineChartHeight = 150.h;
    double multiLineHeight =
        columnHeight - (singleLineChartHeight + verticalSpace);
    double subStatsHeight = multiLineHeight;
    double headerHeight = singleLineChartHeight;

    double indicatorHeight =
        subStatsHeight - headerHeight - verticalSpace; // 250.h;
    double miniBoxHeights = multiLineHeight - (indicatorHeight + verticalSpace);
    double idCardHeight = columnHeight - (miniBoxHeights + verticalSpace);

    // width lengths
    double subStatsWidth = 60.w;
    double firstColumnWidth = 35.w;
    double secondColumnWidth = 140.w;
    double thirdColumnWidth = subStatsWidth + indicatorHeight + lateralSpace;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: buildAppBar(context, true),
        backgroundColor: darkMode
            ? myBackgroundColor.withOpacity(0.93)
            : myBackgroundColor.withOpacity(0.8),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildVerticalSpacer(),

              Padding(
                padding: EdgeInsets.only(left: leftPaddingSize * 2),
                child: Text(
                  "Son Denemenİn İlk üçü".toUpperCase(),
                  style: myTonicStyle(mySecondaryTextColor),
                ),
              ),
              Divider(
                color: mySecondaryColor,
                height: 30.h,
                endIndent: 60.w,
                indent: 60.w,
                thickness: 0.2,
              ),
              SizedBox(
                height: 40.h,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLeftSpacer(leftPaddingSize),
                  Column(
                    children: [
                      SizedBox(
                        width: getScreenWidth(context) - (leftPaddingSize * 2),
                        height: 320.h,
                        child: const Podium(),
                      ),
                    ],
                  ),
                  buildSpacer(),
                ],
              ),
              buildVerticalSpacer(),

              Padding(
                padding: EdgeInsets.only(left: leftPaddingSize * 2),
                child: Text(
                  "Her Ana Branşın En İyİsİ".toUpperCase(),
                  style: myTonicStyle(mySecondaryTextColor),
                ),
              ),
              Divider(
                color: mySecondaryColor,
                height: 30.h,
                endIndent: 60.w,
                indent: 60.w,
                thickness: 0.2,
              ),
              SizedBox(
                height: 40.h,
              ),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildLeftSpacer(leftPaddingSize),
                    Column(
                      children: [
                        SizedBox(
                          width: 600,
                          height: 400.h,
                          child: const KingsThrone(
                            lessonName: "matematik",
                            discipleName: 'Fatih Alemdar',
                          ),
                        ),
                      ],
                    ),
                    buildLateralSpacer(),
                    Column(
                      children: [
                        SizedBox(
                          width: 600,
                          height: 400.h,
                          child: const KingsThrone(
                            lessonName: "türkçe",
                            discipleName: 'Harun Kavak',
                          ),
                        ),
                      ],
                    ),
                    buildLateralSpacer(),
                    Column(
                      children: [
                        SizedBox(
                          width: 600,
                          height: 400.h,
                          child: const KingsThrone(
                            discipleName: 'Süeda Ormancı',
                            lessonName: "fizik",
                          ),
                        ),
                      ],
                    ),
                    buildLateralSpacer(),
                    Column(
                      children: [
                        SizedBox(
                          width: 600,
                          height: 400.h,
                          child: const KingsThrone(
                            discipleName: 'Salih Kocaçınar',
                            lessonName: "kimya",
                          ),
                        ),
                      ],
                    ),
                    buildLateralSpacer(),
                    Column(
                      children: [
                        SizedBox(
                          width: 600,
                          height: 400.h,
                          child: const KingsThrone(
                            discipleName: 'Hasan Kurtulmuş',
                            lessonName: "biyoloji",
                          ),
                        ),
                      ],
                    ),
                    buildLateralSpacer(),
                    Column(
                      children: [
                        SizedBox(
                          width: 600,
                          height: 400.h,
                          child: const KingsThrone(
                            discipleName: 'Erdal Şahin',
                            lessonName: "sosyal",
                          ),
                        ),
                      ],
                    ),
                    buildLateralSpacer(),
                    buildLateralSpacer(),
                    buildLateralSpacer(),
                    buildLateralSpacer(),
                  ],
                ),
              ),
              buildVerticalSpacer(),

              Padding(
                padding: EdgeInsets.only(left: leftPaddingSize * 2),
                child: Text(
                  "Her Ana Branşın En çok gelişme kateden öğrencisi"
                      .toUpperCase(),
                  style: myTonicStyle(mySecondaryTextColor),
                ),
              ),
              Divider(
                color: mySecondaryColor,
                height: 30.h,
                endIndent: 60.w,
                indent: 60.w,
                thickness: 0.2,
              ),
              SizedBox(
                height: 40.h,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildLeftSpacer(leftPaddingSize),
                    Column(
                      children: [
                        SizedBox(
                          width: 600,
                          height: 400.h,
                          child: const ChampionPodium(
                            lessonName: "matematik",
                            discipleName: 'Fatih Alemdar',
                          ),
                        ),
                      ],
                    ),
                    buildLateralSpacer(),
                    Column(
                      children: [
                        SizedBox(
                          width: 600,
                          height: 400.h,
                          child: const ChampionPodium(
                            lessonName: "türkçe",
                            discipleName: 'Harun Kavak',
                          ),
                        ),
                      ],
                    ),
                    buildLateralSpacer(),
                    Column(
                      children: [
                        SizedBox(
                          width: 600,
                          height: 400.h,
                          child: const ChampionPodium(
                            discipleName: 'Süeda Ormancı',
                            lessonName: "fizik",
                          ),
                        ),
                      ],
                    ),
                    buildLateralSpacer(),
                    Column(
                      children: [
                        SizedBox(
                          width: 600,
                          height: 400.h,
                          child: const ChampionPodium(
                            discipleName: 'Salih Kocaçınar',
                            lessonName: "kimya",
                          ),
                        ),
                      ],
                    ),
                    buildLateralSpacer(),
                    Column(
                      children: [
                        SizedBox(
                          width: 600,
                          height: 400.h,
                          child: const ChampionPodium(
                            discipleName: 'Hasan Kurtulmuş',
                            lessonName: "biyoloji",
                          ),
                        ),
                      ],
                    ),
                    buildLateralSpacer(),
                    Column(
                      children: [
                        SizedBox(
                          width: 600,
                          height: 400.h,
                          child: const ChampionPodium(
                            discipleName: 'Erdal Şahin',
                            lessonName: "sosyal",
                          ),
                        ),
                      ],
                    ),
                    buildLateralSpacer(),
                    buildLateralSpacer(),
                    buildLateralSpacer(),
                    buildLateralSpacer(),
                  ],
                ),
              ),
              // divider
              buildVerticalSpacer(),
              buildVerticalSpacer(),
              buildVerticalSpacer(),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox buildLeftSpacer(double size) {
    return SizedBox(
      width: size,
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

  Expanded buildSpacer() => Expanded(
        child: Container(),
      );
}

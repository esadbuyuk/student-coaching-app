import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pcaweb/controller/ui_controller.dart';

import '../../controller/disciple_controller.dart';
import '../../controller/score_controller.dart';
import '../../controller/string_operations.dart';
import '../../controller/user_controller.dart';
import '../../model/disciple.dart';
import '../../model/my_constants.dart';
import '../../model/score.dart';
import '../widgets/card_name_text.dart';
import '../widgets/hexagon_chart.dart';
import '../widgets/multi_line_chart.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/my_card_clippers.dart';
import '../widgets/player_id_card.dart';
import '../widgets/question_stats.dart';
import '../widgets/score_chart.dart';
import '../widgets/skill_card.dart';
import '../widgets/widget_decorations.dart';

class ChartsPage extends StatefulWidget {
  final int? playerId;

  const ChartsPage({Key? key, this.playerId}) : super(key: key);

  @override
  ChartsPageState createState() => ChartsPageState();
}

class ChartsPageState extends State<ChartsPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool _showSubSkills = true;
  late Future<Disciple> playerFuture;
  late Future<List<Score>> skillsDataFuture;
  Future<List<Score>>? subStatsFuture;
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
  List<int?>? subIdsList;
  Key subStatsFutureResetterKey = UniqueKey();
  late int playerID;
  final UserController _userController = UserController();
  late Future<List<Score>> scoresFuture;
  late Future<Map<String, List<Score>>> multiScoresFuture;
  late ScoreController scoreController;
  double verticalSpace = 20.h;
  double lateralSpace = 20.h;
  int? headersStatValue;
  String? headersLabel;
  int totalQuestions = 20;
  int correct = 14;
  int wrong = 2;
  int empty = 4;
  int? hoveredSubSkillIndex;
  int? selectedSubSkill;

  @override
  void initState() {
    super.initState();
    if (widget.playerId == null) {
      playerID = _userController.getUserID();
    } else {
      playerID = widget.playerId!;
    }
    MultiLineScoreChartPainter.selectColor("total".toLowerCase());

    scoreController = ScoreController();
    currentPlayerID = playerID;
    playerController = DiscipleController(playerID);
    playerFuture = playerController.fetchPlayerData();
    skillsDataFuture = playerController.fetchDiscipleSkillsData();
    subStatsFuture = null;
    // _getSubStatsFuture(playerID, 1); // 0 dı burası gözükmüyordu hiç
    _wheelScrollController =
        FixedExtentScrollController(initialItem: initialItemIndex);
    scoresFuture = scoreController.fetchOverallScoresWithDates(playerID);
    multiScoresFuture = scoreController.fetchMultiScoresWithDates(playerID);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    // Klavye durumunu dinlemek için WidgetsBinding kullanıyoruz.
    WidgetsBinding.instance.addObserver(this);
    _animationController.forward();
  }

  @override
  void didChangeMetrics() {
    // burada didChangeMetrics in içerisinde kullanmak mantıklı değil gibi!
    if (_showSubSkills) {
      _animationController
          .forward(); // daire sağ üste gittiğinde kartları göster
    } else {
      _animationController.reverse(); // daire geri geldiğinde kartları kapat
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _previousPlayer() async {
    final previousPlayerData = await playerController.fetchPreviousPlayerData();
    _wheelScrollController =
        FixedExtentScrollController(initialItem: selectedItemIndex);

    setState(() {
      playerFuture = Future.value(previousPlayerData);
      _getMainSkillsFuture();
      _getSubStatsFuture(playerController.getDiscipleID(), selectedItemID ?? 1);
    });
  }

  void _nextPlayer() async {
    final nextPlayerData = await playerController.fetchNextPlayerData();
    _wheelScrollController =
        FixedExtentScrollController(initialItem: selectedItemIndex);
    setState(() {
      playerFuture = Future.value(nextPlayerData);

      _getMainSkillsFuture();
      _getSubStatsFuture(playerController.getDiscipleID(), selectedItemID ?? 1);
    });
  }

  void _updateSubStats(int skillId) {
    setState(() {
      selectedItemID = skillId;
      _showSubSkills = true;
    });
    _getSubStatsFuture(playerController.getDiscipleID(), skillId ?? 1);
    _animationController.forward(); // daire sağ üste gittiğinde kartları göster
  }

  void _updateSingleLineChart({int? clickedSkillId, String? clickedSkillName}) {
    //şu an sadece overall grafiğini çekiyorum.
    setState(() {
      selectedItemID = clickedSkillId;
      _showSubSkills = true;
    });
    scoresFuture = scoreController
        .fetchOverallScoresWithDates(playerController.getDiscipleID());
  }

  void _updateHeaderFromIndicator(
      {int? clickedSkillId, int? clickedSkillStat, String? clickedSkillName}) {
    setState(() {
      MultiLineScoreChartPainter.selectColor(clickedSkillName!.toLowerCase());

      selectedSubSkill = null;
      if (clickedSkillStat != null && clickedSkillName != null) {
        headersStatValue = clickedSkillStat;
        headersLabel = clickedSkillName;
      }
      Random random = Random();

      totalQuestions = 40;
      correct = random.nextInt(30);
      wrong = random.nextInt(10);
    });

    if (selectedSubSkill == null) {
      _updateSubStats(clickedSkillId!);
    }
    _updateSingleLineChart();
  }

  void _updateHeaderFromMultiLine(
      {int? clickedSkillId, int? clickedSkillStat, String? clickedSkillName}) {
    setState(() {
      MultiLineScoreChartPainter.selectColor(clickedSkillName!.toLowerCase());

      selectedSubSkill = null;
      if (clickedSkillStat != null && clickedSkillName != null) {
        headersStatValue = clickedSkillStat;
        headersLabel = clickedSkillName;
      }
      Random random = Random();

      totalQuestions = 40;
      correct = random.nextInt(30);
      wrong = random.nextInt(10);
    });

    if (clickedSkillName?.toLowerCase() == "total") {
      _resetSubStatsFuture();
      print("burada");
    } else if (selectedSubSkill == null) {
      _updateSubStats(clickedSkillId!);
    }
    _updateSingleLineChart();
  }

  void _updateHeaderFromSubStats(
      {int? clickedSkillId, int? clickedSkillStat, String? clickedSkillName}) {
    setState(() {
      if (clickedSkillStat != null && clickedSkillName != null) {
        headersStatValue = clickedSkillStat;
        headersLabel = clickedSkillName;
      }
      Random random = Random();

      totalQuestions = 40;
      correct = random.nextInt(30);
      wrong = random.nextInt(10);
    });
    _updateSingleLineChart();
  }

  void _getMainSkillsFuture() {
    setState(() {
      skillsDataFuture = playerController.fetchDiscipleSkillsData();
    });
  }

  void _getSubStatsFuture(int playerID, int skillID) {
    setState(() {
      subStatsFuture = scoreController.fetchSkillContentData(playerID, skillID);
    });
  }

  void _resetSubStatsFuture() {
    subStatsFutureResetterKey = UniqueKey(); // FutureBuilder'ı sıfırlar
    subStatsFuture = null;
    subKeysList = null;
    subValuesList = null;
  }

  // void _onEmptySpaceTap() {
  //   if (_showSubSkills) {
  //     _resetSubStatsFuture();
  //     _moveIndicator();
  //     // initialItem ı resetledim
  //     _wheelScrollController =
  //         FixedExtentScrollController(initialItem: initialItemIndex);
  //   }
  // }

  void _wheelFirstScroll(int itemToScroll) {
    if (itemToScroll == initialItemIndex) {
      Future.delayed(const Duration(milliseconds: 10), () {
        _wheelScrollController
            .animateToItem(
          itemToScroll + 1,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
        )
            .then((_) {
          Future.delayed(const Duration(milliseconds: 10), () {
            _wheelScrollController.animateToItem(
              itemToScroll,
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeInOut,
            );
          });
        });
      });
    } else {
      Future.delayed(const Duration(milliseconds: 25), () {
        _wheelScrollController.animateToItem(
          itemToScroll,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildSpacer(),
            Column(
              children: [
                buildVerticalSpacer(),

                // ID Card
                Container(
                  width: firstColumnWidth,
                  height: idCardHeight,
                  decoration: buildBorderDecoration(),
                  child: FuturePlayerIDCard(
                    playerID: playerController.getDiscipleID(),
                    playerController: playerController,
                  ),
                ),
                // buildVerticalSpacer(),
                // NextAndPreButtons(
                //   nextFunc: _nextPlayer,
                //   previousFunc: _previousPlayer,
                //   isPaddingOn: true,
                // ),
                buildVerticalSpacer(),

                // Awards Button
                Container(
                  width: firstColumnWidth,
                  height: miniBoxHeights,
                  decoration: buildBorderDecoration(),
                  padding: EdgeInsetsDirectional.only(
                    top: 20.h,
                    //start: 5.w,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CardNameText(
                          textColors: mySecondaryTextColor,
                          name: "Ödül Köşesi"),
                      SizedBox(
                        height: 10.h,
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 2.w),
                          child: Container(
                            decoration: buildInsideShadow(),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.all(3.h),
                              child: Image(
                                width: firstColumnWidth / 3 * 2,
                                height: miniBoxHeights / 3 * 1.3,
                                color: myPrimaryColor,
                                image: const AssetImage(
                                    "assets/icons/trophy_3.png"),
                              ),

                              // SvgPicture.asset(
                              //   'assets/icons/trophy_7.png', // SVG dosyasının yolu
                              //   color: myPrimaryColor,
                              //   width: firstColumnWidth / 3 * 2,
                              //   height: firstColumnWidth / 3 * 2,
                              // ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                buildSpacer(),
              ],
            ),
            buildLateralSpacer(),
            Column(
              children: [
                buildVerticalSpacer(),

                // SingleLine Chart
                Container(
                  width: secondColumnWidth,
                  height: singleLineChartHeight,
                  decoration: buildBorderDecoration(),
                  child: FutureBuilder(
                    future: scoresFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        final scoresData = snapshot.data as List<Score>;
                        return Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 16.w, right: 8.w),
                              child: SizedBox(
                                width: secondColumnWidth / 7,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: secondColumnWidth / 7,
                                      decoration: const BoxDecoration(
                                          border: BorderDirectional(
                                              bottom: BorderSide(
                                                  color: myAccentColor))),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            SizedBox(
                                              width: 8.w,
                                              child: FittedBox(
                                                child: Text(
                                                  "4.8",
                                                  style: myDigitalStyle(
                                                      color:
                                                          mySecondaryTextColor,
                                                      fontSize: 32),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 1.w,
                                            ),
                                            SizedBox(
                                              width: 6.w,
                                              child: const FittedBox(
                                                child: Icon(
                                                  Icons.upgrade_outlined,
                                                  color: myAccentColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    FittedBox(
                                      child: Text(
                                        "${capitalize((headersLabel ?? "total").toLowerCase())} puanlarının \n ortalama artış miktarı",
                                        style: myThightStyle(
                                          color: mySecondaryTextColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 25.h,
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: FittedBox(
                                        fit: BoxFit.fitHeight,
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 15.h),
                                          child: Text(
                                            "Tüm denemelerdeki ${(headersLabel ?? "total").toLowerCase()} puanları",
                                            style: myThightStyle(
                                              color: mySecondaryTextColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.white.withOpacity(0.35),
                                        Colors.white.withOpacity(0.7),
                                        Colors.white.withOpacity(1),
                                        Colors.white.withOpacity(0.7),
                                        Colors.white.withOpacity(0.35),
                                      ],
                                      stops: const [0.0, 0.05, 0.5, 0.95, 1],
                                    ).createShader(bounds),
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      padding: isMobile(context)
                                          ? EdgeInsetsDirectional.only(
                                              start: 50.w,
                                              end: 75.w,
                                              top: 5,
                                              bottom: 18)
                                          : EdgeInsetsDirectional.only(
                                              start: 5.w,
                                              end: 25.w,
                                              top: 0,
                                              bottom: 18),
                                      scrollDirection: Axis.horizontal,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: 5.h,
                                        ),
                                        child: SizedBox(
                                          width: chartWidthCalculator(
                                              scoresData.length),
                                          height: 90.h,
                                          child: ScoreChart(scores: scoresData),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const Center(child: Text('Player not found.'));
                      }
                    },
                  ),
                ),
                buildVerticalSpacer(),

                // MultiLine Chart
                Container(
                  width: secondColumnWidth,
                  height: multiLineHeight,
                  decoration: buildBorderDecoration(),
                  child: FutureBuilder(
                    future: multiScoresFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        final multiScoresData = snapshot.data;

                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 20, top: 50, bottom: 50, right: 20),
                          child: FittedBox(
                            child: MultiLineScoreChart(
                              showTags: true,
                              scoreMap: multiScoresData!,
                              callbackFunct: _updateHeaderFromMultiLine,
                              // scoreMap: {
                              //   "Türkçe": [
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 99),
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 69),
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 79),
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 29),
                              //   ],
                              //   "Matematik": [
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 59),
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 39),
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 19),
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 29),
                              //   ],
                              //   "Fizik": [
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 59),
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 69),
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 12),
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 79),
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 59),
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 69),
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 12),
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 79),
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 59),
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 69),
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 12),
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 79),
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 59),
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 69),
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 12),
                              //     Score(
                              //         name: "name",
                              //         discipleID: 8,
                              //         skillID: 2,
                              //         score: 79),
                              //   ],
                              // },
                            ),
                          ),
                        );
                      } else {
                        return const Center(child: Text('Player not found.'));
                      }
                    },
                  ),
                ),
                buildSpacer(),
              ],
            ),
            buildLateralSpacer(),
            Column(
              children: [
                buildVerticalSpacer(),

                Row(
                  children: [
                    // SubStats
                    Container(
                      width: subStatsWidth,
                      height: subStatsHeight,
                      decoration: buildBorderDecoration(),
                      child: FadeTransition(
                        opacity: _animation,
                        child: SizedBox(
                          height: 265.h,
                          width: 155,
                          child: (subStatsFuture != null)
                              ? Padding(
                                  padding: EdgeInsetsDirectional.only(
                                    top: 10.w,
                                    bottom: 0.w, // 10.w
                                    end: 40.h,
                                    start: 50.h,
                                  ),
                                  child: FutureBuilder<List<Score>>(
                                    key: subStatsFutureResetterKey,
                                    future: subStatsFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Error: ${snapshot.error}'));
                                      } else if (snapshot.hasData) {
                                        final subStatsData = snapshot.data!;
                                        subValuesList = subStatsData
                                            .map((score) =>
                                                score.score.toDouble())
                                            .toList();
                                        subKeysList = subStatsData
                                            .map((score) => score.name)
                                            .toList();
                                        subIdsList = subStatsData
                                            .map((score) => score.skillID)
                                            .toList();

                                        return ListView.builder(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: subStatsData.length,
                                          itemBuilder: (context, index) {
                                            return MouseRegion(
                                              onEnter: (_) {
                                                setState(() {
                                                  hoveredSubSkillIndex =
                                                      index; // Hover olan index'i ayarla
                                                });
                                              },
                                              onExit: (_) {
                                                setState(() {
                                                  hoveredSubSkillIndex =
                                                      null; // Hover olmayan durumda null yap
                                                });
                                              },
                                              child: GestureDetector(
                                                onTapUp: (details) {
                                                  setState(() {
                                                    selectedSubSkill = index;
                                                    _updateHeaderFromSubStats(
                                                      clickedSkillId:
                                                          subIdsList![index],
                                                      clickedSkillName:
                                                          subKeysList![index],
                                                      clickedSkillStat:
                                                          subValuesList![index]
                                                              .toInt(),
                                                    );
                                                  });
                                                },
                                                child: Container(
                                                  // decoration: index == selectedIndex
                                                  //     ? buildSelectedDecoration()
                                                  //     : BoxDecoration(
                                                  //         border: Border.all(
                                                  //             color: myPrimaryColor,
                                                  //             width: 0.8),
                                                  //       ),
                                                  margin: EdgeInsets.only(
                                                    bottom: 15.h,
                                                    left: index ==
                                                                hoveredSubSkillIndex ||
                                                            index ==
                                                                selectedSubSkill
                                                        ? 10
                                                        : 0,
                                                    right: index ==
                                                                hoveredSubSkillIndex ||
                                                            index ==
                                                                selectedSubSkill
                                                        ? 0
                                                        : 10,
                                                    // left: (index % 2 == 1) ? 10 : 0,
                                                    // right: (index % 2 == 0) ? 10 : 0,
                                                  ),
                                                  child: ClipPath(
                                                    clipper:
                                                        MySubSkillCardClipper(),
                                                    child: Container(
                                                      height: 27.h,
                                                      width: 120,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                myPrimaryColor,
                                                            width: 0.8),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 20,
                                                          ),
                                                          Expanded(
                                                            child: ShaderMask(
                                                              shaderCallback:
                                                                  (bounds) {
                                                                return LinearGradient(
                                                                  begin: Alignment
                                                                      .centerLeft,
                                                                  end: Alignment
                                                                      .centerRight,
                                                                  colors: [
                                                                    Colors.white
                                                                        .withOpacity(
                                                                            0.9), // Left fade
                                                                    Colors
                                                                        .white, // Center fully visible
                                                                    Colors.white
                                                                        .withOpacity(
                                                                            0.1), // Right fade
                                                                  ],
                                                                  stops: const [
                                                                    0.0,
                                                                    0.80,
                                                                    1.0
                                                                  ],
                                                                ).createShader(
                                                                    bounds);
                                                              },
                                                              blendMode:
                                                                  BlendMode
                                                                      .dstIn,
                                                              child:
                                                                  SingleChildScrollView(
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      right:
                                                                          8.0,
                                                                      left:
                                                                          1.0),
                                                                  child: Text(
                                                                    subKeysList![
                                                                        index],
                                                                    // subStatsData[index].name, böyle yapabilirsin

                                                                    style: myTonicStyle(
                                                                        mySecondaryTextColor,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          ClipPath(
                                                            clipper:
                                                                MyScoreFieldClipper(),
                                                            child: Container(
                                                              width: 40,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: darkMode
                                                                    ? Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.4)
                                                                    : Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.2),
                                                                // border:
                                                                //     const BorderDirectional(
                                                                //   top: BorderSide(
                                                                //       color: myPrimaryColor,
                                                                //       width: 0),
                                                                // ),
                                                              ),
                                                              child: Text(
                                                                subValuesList![
                                                                        index]
                                                                    .toInt()
                                                                    .toString(),
                                                                style: myDigitalStyle(
                                                                    color:
                                                                        mySecondaryTextColor),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      } else {
                                        return const Center(
                                            child: Text('No data'));
                                      }
                                    },
                                  ),
                                )
                              : Padding(
                                  padding: EdgeInsetsDirectional.only(
                                    top: 40.h,
                                    bottom: 0.w, // 10.w
                                    start: 5.w,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 20.h),
                                        child: const CardNameText(
                                            textColors: mySecondaryTextColor,
                                            name: "güçlü konular"),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(
                                          end: 8.w,
                                          start: 5.w,
                                        ),
                                        child: SizedBox(
                                          height: 120.h,
                                          width: subStatsWidth - 0,
                                          child: ListView.builder(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemCount: 3,
                                            itemBuilder: (context, index) {
                                              return Container(
                                                margin: EdgeInsets.only(
                                                  bottom: 15.h,
                                                  left: 0,
                                                  right: 10,
                                                ),
                                                child: ClipPath(
                                                  clipper:
                                                      MySubSkillCardClipper(),
                                                  child: Container(
                                                    height: 27.h,
                                                    width: 120,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: myAccentColor,
                                                          width: 0.8),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const SizedBox(
                                                          width: 20,
                                                        ),
                                                        Expanded(
                                                          child: ShaderMask(
                                                            shaderCallback:
                                                                (bounds) {
                                                              return LinearGradient(
                                                                begin: Alignment
                                                                    .centerLeft,
                                                                end: Alignment
                                                                    .centerRight,
                                                                colors: [
                                                                  Colors.white
                                                                      .withOpacity(
                                                                          0.9), // Left fade
                                                                  Colors
                                                                      .white, // Center fully visible
                                                                  Colors.white
                                                                      .withOpacity(
                                                                          0.1), // Right fade
                                                                ],
                                                                stops: const [
                                                                  0.0,
                                                                  0.80,
                                                                  1.0
                                                                ],
                                                              ).createShader(
                                                                  bounds);
                                                            },
                                                            blendMode:
                                                                BlendMode.dstIn,
                                                            child:
                                                                SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            8.0,
                                                                        left:
                                                                            1.0),
                                                                child: Text(
                                                                  (index == 1
                                                                          ? "Yazım kuralları"
                                                                          : index == 2
                                                                              ? "Paragraf"
                                                                              : "Türev")
                                                                      .toUpperCase(),
                                                                  // subStatsData[index].name, böyle yapabilirsin

                                                                  style: myTonicStyle(
                                                                      mySecondaryTextColor,
                                                                      fontSize:
                                                                          12),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        ClipPath(
                                                          clipper:
                                                              MyScoreFieldClipper(),
                                                          child: Container(
                                                            width: 40,
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: darkMode
                                                                  ? Colors.black
                                                                      .withOpacity(
                                                                          0.4)
                                                                  : Colors.white
                                                                      .withOpacity(
                                                                          0.2),
                                                              // border:
                                                              //     const BorderDirectional(
                                                              //   top: BorderSide(
                                                              //       color: myPrimaryColor,
                                                              //       width: 0),
                                                              // ),
                                                            ),
                                                            child: Text(
                                                              "88",
                                                              style: myDigitalStyle(
                                                                  color:
                                                                      mySecondaryTextColor),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            bottom: 15.h, top: 25.h),
                                        child: const CardNameText(
                                            textColors: mySecondaryTextColor,
                                            name: "zayıf konular"),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(
                                          end: 8.w,
                                          start: 5.w,
                                        ),
                                        child: SizedBox(
                                          height: 120.h,
                                          width: subStatsWidth - 0,
                                          child: ListView.builder(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemCount: 3,
                                            itemBuilder: (context, index) {
                                              return Container(
                                                margin: EdgeInsets.only(
                                                  bottom: 15.h,
                                                  left: 0,
                                                  right: 10,
                                                ),
                                                child: ClipPath(
                                                  clipper:
                                                      MySubSkillCardClipper(),
                                                  child: Container(
                                                    height: 27.h,
                                                    width: 120,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: myPrimaryColor,
                                                          width: 0.8),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const SizedBox(
                                                          width: 20,
                                                        ),
                                                        Expanded(
                                                          child: ShaderMask(
                                                            shaderCallback:
                                                                (bounds) {
                                                              return LinearGradient(
                                                                begin: Alignment
                                                                    .centerLeft,
                                                                end: Alignment
                                                                    .centerRight,
                                                                colors: [
                                                                  Colors.white
                                                                      .withOpacity(
                                                                          0.9), // Left fade
                                                                  Colors
                                                                      .white, // Center fully visible
                                                                  Colors.white
                                                                      .withOpacity(
                                                                          0.1), // Right fade
                                                                ],
                                                                stops: const [
                                                                  0.0,
                                                                  0.80,
                                                                  1.0
                                                                ],
                                                              ).createShader(
                                                                  bounds);
                                                            },
                                                            blendMode:
                                                                BlendMode.dstIn,
                                                            child:
                                                                SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            8.0,
                                                                        left:
                                                                            1.0),
                                                                child: Text(
                                                                  (index == 1
                                                                          ? "olasılık"
                                                                          : index == 2
                                                                              ? "trigonometri"
                                                                              : "Denklem ve Eşitsizlikler")
                                                                      .toUpperCase(),
                                                                  // subStatsData[index].name, böyle yapabilirsin

                                                                  style: myTonicStyle(
                                                                      mySecondaryTextColor,
                                                                      fontSize:
                                                                          12),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        ClipPath(
                                                          clipper:
                                                              MyScoreFieldClipper(),
                                                          child: Container(
                                                            width: 40,
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: darkMode
                                                                  ? Colors.black
                                                                      .withOpacity(
                                                                          0.4)
                                                                  : Colors.white
                                                                      .withOpacity(
                                                                          0.2),
                                                              // border:
                                                              //     const BorderDirectional(
                                                              //   top: BorderSide(
                                                              //       color: myPrimaryColor,
                                                              //       width: 0),
                                                              // ),
                                                            ),
                                                            child: Text(
                                                              "55",
                                                              style: myDigitalStyle(
                                                                  color:
                                                                      mySecondaryTextColor),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      buildSpacer(),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 5.w, bottom: 15.h),
                                        child: SizedBox(
                                          height: 30.h,
                                          width: 35.w,
                                          child: FittedBox(
                                            child: Text(
                                              "Tüm denemelerdeki istatistiklere göre",
                                              style: myThightStyle(
                                                color: mySecondaryTextColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),

                    buildLateralSpacer(),
                    Column(
                      children: [
                        // Ana Beceri Başlığı
                        Container(
                          width: indicatorHeight,
                          height: headerHeight,
                          decoration: buildBorderDecoration(),
                          child: Container(
                            decoration: buildSelectedDecoration(),
                            margin: EdgeInsetsDirectional.symmetric(
                                vertical: 25.h, horizontal: 50.h),
                            padding: EdgeInsetsDirectional.symmetric(
                                vertical: 15.h, horizontal: 20.h),
                            child: FittedBox(
                              child: Column(
                                children: [
                                  Text(
                                    headersStatValue != null
                                        ? headersStatValue.toString()
                                        : "",
                                    style: myDigitalStyle(
                                        color: mySecondaryTextColor,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    headersLabel ?? "Bir ders seçin.",
                                    style: myTonicStyle(mySecondaryTextColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        buildVerticalSpacer(),
                        // StatsIndicator
                        Container(
                          width:
                              indicatorHeight, // yükseklik ile eşit olmak zorunda.
                          height: indicatorHeight,
                          decoration: buildBorderDecoration(),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.transparent, // Dairenin iç rengi
                              shape: BoxShape.circle, // Daire şekli
                            ),
                            //margin: const EdgeInsetsDirectional.all(60),
                            child: buildFutureStatsIndicator(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                buildVerticalSpacer(),
                // ScoreExplanation
                Container(
                  width: thirdColumnWidth,
                  height: miniBoxHeights,
                  decoration: buildBorderDecoration(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20.h,
                      ),
                      CardNameText(
                          textColors: mySecondaryTextColor,
                          name: "${(headersLabel ?? "total")} Puan Analizi"),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          buildSpacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  textAlign: TextAlign.end,
                                  "zorluk : ",
                                  style: myThightStyle(
                                      color: mySecondaryTextColor),
                                ),
                              ),
                              SizedBox(
                                width: 2.w,
                              ),
                              Text(
                                "+9.2",
                                style: myDigitalStyle(
                                    color: mySecondaryTextColor, fontSize: 22),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 20.w,
                          ),
                          SizedBox(
                            // width: indicatorHeight,
                            height: miniBoxHeights - 42.h,
                            child: QuestionStatsCard(
                              totalQuestions: totalQuestions,
                              correct: correct,
                              wrong: wrong,
                              empty: totalQuestions - (correct + wrong),
                            ),
                          ),
                          buildSpacer(),
                        ],
                      ),
                    ],
                  ),
                ),

                buildSpacer(),
              ],
            ),
            buildSpacer(),
          ],
        ),
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

  Expanded buildSpacer() => Expanded(
        child: Container(),
      );

  double chartWidthCalculator(int length) {
    double width;

    if (length > 12) {
      width = isMobile(context) ? length * 70.w : length * 15.w;
    } else if (length > 6) {
      width = isMobile(context) ? length * 150.w : length * 30.w;
    } else {
      width = isMobile(context) ? 900.w : 200.w;
    }

    return width;
  }

  FutureBuilder<List<Score>> buildFutureStatsIndicator() {
    return FutureBuilder<List<Score>>(
      future: skillsDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildStatsIndicatorMessage(
            Colors.grey,
            const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return buildStatsIndicatorMessage(
              Colors.red, const Center(child: Text('Error')));
        } else if (snapshot.hasData) {
          final statsData = snapshot.data!;
          List<double> valuesList =
              statsData.map((score) => score.score.toDouble()).toList();
          List<String> keysList = statsData.map((score) => score.name).toList();
          List<int?> idsList = statsData.map((score) => score.skillID).toList();
          // Eleman sayıları 5'ten azsa, 5 elemana tamamla
          while (valuesList.length < 5) {
            valuesList.add(0.0);
          }
          while (keysList.length < 5) {
            keysList.add("-");
          }
          return PolygonContainer(
            radius: 150.h,
            labels: keysList,
            data: valuesList,
            ids: idsList,
            numberOfSides: 6,
            callbackFunct: _updateHeaderFromIndicator,
          );
        } else {
          return buildStatsIndicatorMessage(
              Colors.yellow, const Center(child: Text('No data')));
        }
      },
    );
  }

  Container buildSkillListWheel(List<Score> statsData) {
    List<double> valuesList =
        statsData.map((score) => score.score.toDouble()).toList();
    List<String> keysList = statsData.map((score) => score.name).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: mySecondaryColor.withOpacity(0.5), // Gölgenin rengi
            spreadRadius: 95, // Gölgenin yayılma miktarı
            blurRadius: 92, // Gölgenin bulanıklığı
            offset: const Offset(145, -115), // Gölgenin konumu (x, y)
          ),
        ],
      ),
      height: indicatorRadius - 35,
      width: indicatorRadius + 35,
      child: ListWheelScrollView(
        itemExtent: 50,
        offAxisFraction: -2.2, // yamuklaştırıyor.
        squeeze: 0.60, // aralarındaki mesafeyi arttırıyor.
        physics: const FixedExtentScrollPhysics(),
        controller: _wheelScrollController,
        onSelectedItemChanged: (index) {
          _getSubStatsFuture(
              playerController.getDiscipleID(), statsData[index].skillID!);
          setState(() {
            selectedItemIndex = index;
            selectedItemID = statsData[index].skillID;
          });
        },
        children: List.generate(
          valuesList.length,
          (index) => TonicSkillCard(
            stat: valuesList[index].toInt(),
            skillName: keysList[index],
          ),
        ),
      ),
    );
  }

  Container buildStatsIndicatorMessage(Color color, Center message) {
    return Container(
      // width: 277,
      // height: 277,
      // decoration: BoxDecoration(
      //   shape: BoxShape.circle,
      //   color: color,
      // ),
      child: message,
    );
  }
}

// class IrregularPentagonGridPainter extends CustomPainter {
//   final double spacing;
//   final Random random = Random();
//
//   IrregularPentagonGridPainter(
//       {this.spacing = 310}); // Varsayılan boşluk miktarı
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color =
//           mySecondaryColor.withOpacity(0.9) // Beşgenlerin rengi ve şeffaflığı
//       ..style = PaintingStyle.stroke;
//
//     for (double x = 0; x < size.width; x += spacing) {
//       for (double y = 0; y < size.height; y += spacing) {
//         // Rastgele bir büyüklük varyasyonu (örneğin %70 ile %130 arası)
//         final radius =
//             80.0 + random.nextDouble() * 110.0; // 20 ile 40 arasında değişir
//
//         // Rastgele bir kaydırma varyasyonu (pozisyonu biraz kaydırır)
//         final offsetX =
//             x + random.nextDouble() * 20 - 30; // -10 ile +10 arası kaydırma
//         final offsetY =
//             y + random.nextDouble() * 20 - 30; // -10 ile +10 arası kaydırma
//
//         // Beşgen çizmek için Path oluştur
//         final path = Path();
//
//         // Beşgenin her köşesini hesapla
//         for (int i = 0; i < 5; i++) {
//           final angle =
//               (2 * pi / 5) * i - pi / 2; // Her köşe için 72 derece fark
//           final pointX = offsetX + radius * cos(angle);
//           final pointY = offsetY + radius * sin(angle);
//           if (i == 0) {
//             path.moveTo(pointX, pointY);
//           } else {
//             path.lineTo(pointX, pointY);
//           }
//         }
//         path.close(); // Beşgeni tamamla
//
//         // Beşgeni canvas üzerine çiz
//         canvas.drawPath(path, paint);
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

//
// class PentagonGridPainter extends CustomPainter {
//   final double spacing;
//
//   PentagonGridPainter({this.spacing = 50}); // Boşluk miktarı ayarlanabilir
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color =
//           mySecondaryColor.withOpacity(0.3) // Beşgenlerin rengi ve şeffaflığı
//       ..style = PaintingStyle.stroke;
//
//     for (double x = -25; x < size.width; x += spacing) {
//       for (double y = -25; y < size.height; y += spacing) {
//         // Beşgen çizmek için path oluştur
//         final path = Path();
//         const radius = 5.0; // Beşgen yarıçapı (her bir beşgenin boyutu)
//
//         // Beşgenin her köşesini hesapla
//         for (int i = 0; i < 5; i++) {
//           final angle =
//               (2 * pi / 5) * i - pi / 2; // Her köşe için 72 derece fark
//           final offsetX = x + radius * cos(angle);
//           final offsetY = y + radius * sin(angle);
//           if (i == 0) {
//             path.moveTo(offsetX, offsetY);
//           } else {
//             path.lineTo(offsetX, offsetY);
//           }
//         }
//         path.close(); // Beşgeni tamamla
//
//         // Beşgeni canvas üzerine çiz
//         canvas.drawPath(path, paint);
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
//
// class BackgroundPatternPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     // Paint nesnesi, çizim özelliklerini belirler
//     final paint = Paint()
//       ..color = mySecondaryColor.withOpacity(0.3) // Renk ve şeffaflık
//       ..style = PaintingStyle.stroke; // Daireyi dolu olarak çizme
//
//     // Çizimlerde kullanılacak aralık
//     const spacing = 50.0;
//
//     for (double x = -25; x < size.width; x += spacing) {
//       for (double y = -25; y < size.height; y += spacing) {
//         canvas.drawCircle(Offset(x, y), 2, paint);
//       }
//     }
//   }
//
//   // Bu fonksiyon, çizimi tekrar etmemiz gerekip gerekmediğini belirler
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
//
// class IrregularPentagonsPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white.withOpacity(0.1) // Beşgen rengi ve şeffaflık
//       ..style = PaintingStyle.fill; // Beşgenlerin içi dolu
//
//     final random = Random();
//     const numberOfPentagons = 30; // Çizilecek beşgen sayısı
//
//     for (int i = 0; i < numberOfPentagons; i++) {
//       // Rastgele bir konum seç
//       final centerX = random.nextDouble() * size.width;
//       final centerY = random.nextDouble() * size.height;
//
//       // Rastgele bir boyut belirle (çap olarak)
//       final pentagonRadius =
//           20 + random.nextDouble() * 30; // 20-50 piksel arası boyut
//
//       // Beşgenin köşelerini hesapla
//       final path = Path();
//       for (int j = 0; j < 5; j++) {
//         final angle = (2 * pi / 5) * j - pi / 2; // Açı, her köşe için 72 derece
//         final x = centerX + pentagonRadius * cos(angle);
//         final y = centerY + pentagonRadius * sin(angle);
//         if (j == 0) {
//           path.moveTo(x, y); // İlk köşe
//         } else {
//           path.lineTo(x, y); // Diğer köşeler
//         }
//       }
//       path.close();
//
//       // Beşgeni çiz
//       canvas.drawPath(path, paint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
//
// class IrregularLinesPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white.withOpacity(0.2) // Çizgi rengi ve şeffaflığı
//       ..strokeWidth = 2.0 // Çizgi kalınlığı
//       ..strokeCap = StrokeCap.round; // Çizgilerin uçlarını yuvarlatma
//
//     final random = Random();
//     const numberOfLines = 10; // Çizilecek toplam çizgi sayısı
//
//     for (int i = 0; i < numberOfLines; i++) {
//       // Rastgele bir başlangıç noktası seç
//       final startX = random.nextDouble() * size.width;
//       final startY = random.nextDouble() * size.height;
//
//       // Rastgele bir uzunluk ve açı seç
//       final lineLength =
//           80 + random.nextDouble() * 50; // Çizgi uzunluğu 30-80 piksel arasında
//       const angle = 60; // Açı (0 ile 2π arası)
//
//       // Açıya göre bitiş noktasını hesapla
//       final endX = startX + lineLength * cos(angle);
//       final endY = startY + lineLength * sin(angle);
//
//       // Çizgiyi çiz
//       canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

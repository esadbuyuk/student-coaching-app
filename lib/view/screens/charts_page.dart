import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pcaweb/controller/ui_controller.dart';

import '../../controller/disciple_controller.dart';
import '../../controller/score_controller.dart';
import '../../controller/user_controller.dart';
import '../../model/disciple.dart';
import '../../model/my_constants.dart';
import '../../model/score.dart';
import '../widgets/card_name_text.dart';
import '../widgets/deep_line_chart.dart';
import '../widgets/hexagon_chart.dart';
import '../widgets/multi_line_chart.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/my_card_clippers.dart';
import '../widgets/negatif_multi_line_chart.dart';
import '../widgets/player_id_card.dart';
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
  double lateralSpace = 20.h; // buraya elleme
  int? headersStatValue;
  String? headersLabel;
  bool subHeaderActivated = false;
  int totalQuestions = 20;
  int correct = 14;
  int wrong = 2;
  int empty = 4;
  int? hoveredSubSkillIndex;
  int? selectedSubSkill;
  Offset _mousePosition = Offset.zero;
  OverlayEntry? currentOverlayEntry; // Aktif overlay'i takip eden değişken
  OverlayEntry? _overlayEntry;
  OverlayEntry? _indicatorOverlayEntry;
  bool _isOverlayVisible = false;
  bool _isIndicatorVisible = false;
  bool dontReloadFlag = false;
  List<Score> scoresData1 = [];
  List<Score>? scoresData2;
  List<Score>? scoresData3;
  @override
  void initState() {
    super.initState();
    _mousePosition = const Offset(-500, -500); // Başlangıçta görünmez
    dontReloadFlag = true;
    if (widget.playerId == null) {
      playerID = _userController.getUserID();
    } else {
      playerID = widget.playerId!;
    }
    MultiLineScoreChartPainter.selectColor("total".toLowerCase());
    DeepLineCartPainter.selectColor("total".toLowerCase());

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
    _removeOverlay();
    _removeIndicatorOverlay();

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
      dontReloadFlag = true;
    });
    scoresFuture = scoreController
        .fetchOverallScoresWithDates(playerController.getDiscipleID());
  }

  void _updateHeaderFromIndicator(
      {int? clickedSkillId, int? clickedSkillStat, String? clickedSkillName}) {
    setState(() {
      MultiLineScoreChartPainter.selectColor(clickedSkillName!.toLowerCase());
      DeepLineCartPainter.selectColor(clickedSkillName!.toLowerCase());

      selectedSubSkill = null;
      if (clickedSkillStat != null && clickedSkillName != null) {
        headersStatValue = clickedSkillStat;
        headersLabel = clickedSkillName;
      }
      Random random = Random();
      subHeaderActivated = false;

      totalQuestions = 40;
      correct = random.nextInt(30);
      wrong = random.nextInt(10);
    });
    dontReloadFlag = true;

    if (selectedSubSkill == null) {
      _updateSubStats(clickedSkillId!);
    }
    _updateSingleLineChart();
    _removeIndicatorOverlay();
    _removeOverlay();
    _showOverlay(context, clickedSkillName ?? "Bir Ders Seçin");
  }

  void _updateHeaderFromMultiLine(
      {int? clickedSkillId, int? clickedSkillStat, String? clickedSkillName}) {
    setState(() {
      MultiLineScoreChartPainter.selectColor(clickedSkillName!.toLowerCase());
      DeepLineCartPainter.selectColor(clickedSkillName!.toLowerCase());

      selectedSubSkill = null;
      if (clickedSkillStat != null && clickedSkillName != null) {
        headersStatValue = clickedSkillStat;
        headersLabel = clickedSkillName;
      }
      Random random = Random();
      subHeaderActivated = false;
      totalQuestions = 40;
      correct = random.nextInt(30);
      wrong = random.nextInt(10);
    });

    if (clickedSkillName?.toLowerCase() == "total") {
      _resetSubStatsFuture();
    } else if (selectedSubSkill == null) {
      _updateSubStats(clickedSkillId!);
    }
    _removeIndicatorOverlay();

    _removeOverlay();
    dontReloadFlag = true;
    _showOverlay(context, clickedSkillName ?? "Bir Ders Seçin");
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
      subHeaderActivated = true;
      totalQuestions = 40;
      correct = random.nextInt(30);
      wrong = random.nextInt(10);
    });
    _updateSingleLineChart();
    _removeOverlay();

    _showOverlay(context, clickedSkillName ?? "Bir Ders Seçin");
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

  void _showOverlay(BuildContext context, String selectedName) {
    if (!isMobile(context)) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: appBarHeight + 1.h,
        left: lateralSpace,
        right: lateralSpace,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTapUp: (details) {
              _removeOverlay();

              _showOverlay(context, "Bir Ders Seçin");

              _showStatsIndicator(context, 200);
            },
            child:
                // Ana Beceri Başlığı
                Container(
              height: 80.h,
              decoration: buildOverlayDecoration(),
              margin: EdgeInsetsDirectional.symmetric(
                  vertical: 0.h, horizontal: 0.h), // 25.h
              padding: EdgeInsetsDirectional.symmetric(
                  vertical: 15.h, horizontal: 20.h),
              child: FittedBox(
                child: Column(
                  children: [
                    Text(
                      _isIndicatorVisible
                          ? ""
                          : (headersStatValue != null
                              ? headersStatValue.toString()
                              : ""),
                      style: myDigitalStyle(
                          color: mySecondaryTextColor, fontSize: 16),
                    ),
                    Text(
                      _isIndicatorVisible
                          ? "Bir ders seçin."
                          : (headersLabel ?? "Bir ders seçin."),
                      style: myTonicStyle(mySecondaryTextColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isOverlayVisible = true;
  }

  void _showStatsIndicator(BuildContext context, double sidePadding) {
    if (_isIndicatorVisible) return;

    _indicatorOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: getScreenHeight(context) / 3,
        left: (getScreenWidth(context) - 220) /
            2, // 220 = stacksWidth of polyChart
        // right: 50.w,
        child: Material(
          color: Colors.transparent,
          child: // StatsIndicator
              Column(
            children: [
              Container(
                // width: 210, // yükseklik ile eşit olmak zorunda.
                //height: 150,
                decoration: buildOverlayDecoration(),
                child: Center(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent, // Dairenin iç rengi
                      shape: BoxShape.circle, // Daire şekli
                    ),
                    //margin: const EdgeInsetsDirectional.all(60),
                    child: buildFutureStatsIndicator(),
                  ),
                ),
              ),
              buildVerticalSpacer(),
              GestureDetector(
                onTapUp: (details) {
                  _updateHeaderFromMultiLine(
                      clickedSkillStat: 78, clickedSkillName: "TOTAL");
                },
                child: Container(
                  width: 70, // yükseklik ile eşit olmak zorunda.
                  height: 70,
                  decoration: buildOverlayDecoration(),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.transparent, // Dairenin iç rengi
                      shape: BoxShape.circle, // Daire şekli
                    ),
                    //margin: const EdgeInsetsDirectional.all(60),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                          child: FittedBox(
                              child: SkillCard(stat: 78, skillName: "TOTAL"))),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_indicatorOverlayEntry!);
    _isIndicatorVisible = true;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOverlayVisible = false;
  }

  void _removeIndicatorOverlay() {
    _indicatorOverlayEntry?.remove();
    _indicatorOverlayEntry = null;
    _isIndicatorVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = getScreenWidth(context);
    double screenHeight = getScreenHeight(context);

    // height lengths
    double columnHeight = 630.h;
    double singleLineChartHeight = isMobile(context) ? 240.h : 150.h;
    double multiLineHeight = isMobile(context)
        ? singleLineChartHeight * 2 - 10.h
        : columnHeight - (singleLineChartHeight + verticalSpace);
    double subStatsHeight =
        isMobile(context) ? (screenHeight / 10) * 6 : multiLineHeight;
    double headerHeight = singleLineChartHeight;

    double indicatorHeight =
        subStatsHeight - headerHeight - verticalSpace; // 250.h;
    double miniBoxHeights = isMobile(context)
        ? (screenHeight / 11) * 4
        : multiLineHeight - (indicatorHeight + verticalSpace);
    double idCardHeight = columnHeight - (miniBoxHeights + verticalSpace);

    // width lengths
    double subStatsWidth = 60.w;
    double sidePaddings = lateralSpace;
    double mobileContainerWidths = screenWidth - sidePaddings * 2;
    double firstColumnWidth = 35.w;
    double thirdColumnWidth = 140.w;
    double secondColumnWidth = indicatorHeight + subStatsWidth + lateralSpace;

    double edgeMargin = screenWidth -
        (firstColumnWidth +
            thirdColumnWidth +
            secondColumnWidth +
            lateralSpace * 4); // Kenarlardan kaç piksel içinde ışık kaybolsun?

    return LayoutBuilder(
      builder: (context, constraints) {
        if (isMobile(context)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _removeOverlay();

            _showOverlay(context, "Bir Ders Seçin");
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _removeOverlay();
            _removeIndicatorOverlay();
          });
        }

        return SafeArea(
          child: isMobile(context)
              ? GestureDetector(
                  onTapUp: (details) {
                    _indicatorOverlayEntry != null
                        ? _removeIndicatorOverlay()
                        : null;
                  },
                  child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    appBar: buildAppBar(context, true),
                    backgroundColor: darkMode
                        ? myBackgroundColor.withOpacity(0.93)
                        : myBackgroundColor.withOpacity(0.8),
                    body: ScrollbarTheme(
                      data: ScrollbarThemeData(
                          thumbColor: WidgetStateProperty.all(myBackgroundColor
                              .withOpacity(0.5)), // ScrollBar rengi mavi
                          radius: const Radius.circular(0),
                          thickness: WidgetStateProperty.all(5),
                          interactive: true // Kalınlık
                          ),
                      child: Scrollbar(
                        thumbVisibility: true,
                        thickness: 5,
                        radius: const Radius.circular(0),
                        trackVisibility: false,
                        interactive: true,
                        child: SingleChildScrollView(
                          primary: true,
                          scrollDirection: Axis.vertical,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  color: myPrimaryColor,
                                  border: BorderDirectional(
                                    bottom: BorderSide(color: myPrimaryColor),
                                    top: BorderSide(color: myPrimaryColor),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    buildVerticalSpacer(),
                                    buildVerticalSpacer(),
                                    buildVerticalSpacer(),
                                    buildVerticalSpacer(),
                                    buildVerticalSpacer(),
                                    // SubStats
                                    SizedBox(
                                      width: mobileContainerWidths,
                                      height: subStatsHeight,
                                      // decoration: buildBorderDecoration(),
                                      child: SizedBox(
                                        height: subStatsHeight,
                                        width: mobileContainerWidths,
                                        child: (subStatsFuture != null)
                                            ? Padding(
                                                padding:
                                                    EdgeInsetsDirectional.only(
                                                  top: 100.h,
                                                  bottom: 0.w, // 10.w
                                                  end: 40.h,
                                                  start: 50.h,
                                                ),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 0.w,
                                                          right: 10.w,
                                                          bottom: 20.h),
                                                      child: SizedBox(
                                                        height: 20.h,
                                                        width:
                                                            mobileContainerWidths,
                                                        child: Center(
                                                          child: Text(
                                                            "Son 5 denemenin puan ortalamaları",
                                                            style:
                                                                myThightStyle(
                                                              color:
                                                                  myTextColor,
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    FutureBuilder<List<Score>>(
                                                      key:
                                                          subStatsFutureResetterKey,
                                                      future: subStatsFuture,
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return const Center(
                                                              child:
                                                                  CircularProgressIndicator());
                                                        } else if (snapshot
                                                            .hasError) {
                                                          return Center(
                                                              child: Text(
                                                                  'Error: ${snapshot.error}'));
                                                        } else if (snapshot
                                                            .hasData) {
                                                          final subStatsData =
                                                              snapshot.data!;
                                                          subValuesList =
                                                              subStatsData
                                                                  .map((score) =>
                                                                      score
                                                                          .score
                                                                          .toDouble())
                                                                  .toList();
                                                          subKeysList =
                                                              subStatsData
                                                                  .map((score) =>
                                                                      score
                                                                          .name)
                                                                  .toList();
                                                          subIdsList = subStatsData
                                                              .map((score) =>
                                                                  score.skillID)
                                                              .toList();

                                                          return SizedBox(
                                                            height: 280.h,
                                                            width:
                                                                mobileContainerWidths,
                                                            child: ListView
                                                                .builder(
                                                              physics:
                                                                  const BouncingScrollPhysics(),
                                                              itemCount:
                                                                  subStatsData
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                return TweenAnimationBuilder(
                                                                  duration:
                                                                      Duration(
                                                                    milliseconds: 300 +
                                                                        (index *
                                                                            100),
                                                                  ), // Her öğeye gecikme ekliyoruz
                                                                  tween: Tween<
                                                                          double>(
                                                                      begin:
                                                                          -330.0,
                                                                      end:
                                                                          0.0), // Y ekseni kayma animasyonu
                                                                  builder: (context,
                                                                      double
                                                                          value,
                                                                      child) {
                                                                    return Transform
                                                                        .translate(
                                                                      offset: Offset(
                                                                          value,
                                                                          0),
                                                                      child:
                                                                          child,
                                                                    );
                                                                  },

                                                                  child:
                                                                      MouseRegion(
                                                                    onEnter:
                                                                        (_) {
                                                                      setState(
                                                                          () {
                                                                        hoveredSubSkillIndex =
                                                                            index; // Hover olan index'i ayarla
                                                                      });
                                                                    },
                                                                    onExit:
                                                                        (_) {
                                                                      setState(
                                                                          () {
                                                                        hoveredSubSkillIndex =
                                                                            null; // Hover olmayan durumda null yap
                                                                      });
                                                                    },
                                                                    child:
                                                                        GestureDetector(
                                                                      onTapUp:
                                                                          (details) {
                                                                        setState(
                                                                            () {
                                                                          selectedSubSkill =
                                                                              index;
                                                                          _updateHeaderFromSubStats(
                                                                            clickedSkillId:
                                                                                subIdsList![index],
                                                                            clickedSkillName:
                                                                                subKeysList![index],
                                                                            clickedSkillStat:
                                                                                subValuesList![index].toInt(),
                                                                          );
                                                                        });
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            mobileContainerWidths,
                                                                        // decoration: index == selectedIndex
                                                                        //     ? buildSelectedDecoration()
                                                                        //     : BoxDecoration(
                                                                        //         border: Border.all(
                                                                        //             color: myPrimaryColor,
                                                                        //             width: 0.8),
                                                                        //       ),
                                                                        margin:
                                                                            EdgeInsets.only(
                                                                          bottom:
                                                                              15.h,
                                                                          left: index == hoveredSubSkillIndex || index == selectedSubSkill
                                                                              ? 10
                                                                              : 0,
                                                                          right: index == hoveredSubSkillIndex || index == selectedSubSkill
                                                                              ? 0
                                                                              : 10,
                                                                          // left: (index % 2 == 1) ? 10 : 0,
                                                                          // right: (index % 2 == 0) ? 10 : 0,
                                                                        ),
                                                                        child:
                                                                            ClipPath(
                                                                          clipper:
                                                                              MySubSkillCardClipper(),
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                27.h,
                                                                            width:
                                                                                mobileContainerWidths,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              border: Border.all(color: myBackgroundColor, width: 1),
                                                                            ),
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                const SizedBox(
                                                                                  width: 20,
                                                                                ),
                                                                                Expanded(
                                                                                  child: ShaderMask(
                                                                                    shaderCallback: (bounds) {
                                                                                      return LinearGradient(
                                                                                        begin: Alignment.centerLeft,
                                                                                        end: Alignment.centerRight,
                                                                                        colors: [
                                                                                          Colors.white.withOpacity(0.9), // Left fade
                                                                                          Colors.white, // Center fully visible
                                                                                          Colors.white.withOpacity(0.1), // Right fade
                                                                                        ],
                                                                                        stops: const [
                                                                                          0.0,
                                                                                          0.80,
                                                                                          1.0
                                                                                        ],
                                                                                      ).createShader(bounds);
                                                                                    },
                                                                                    blendMode: BlendMode.dstIn,
                                                                                    child: SingleChildScrollView(
                                                                                      scrollDirection: Axis.horizontal,
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.only(right: 8.0, left: 1.0),
                                                                                        child: Text(
                                                                                          subKeysList![index],
                                                                                          // subStatsData[index].name, böyle yapabilirsin

                                                                                          style: myTonicStyle(myTextColor, fontSize: 12),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 5,
                                                                                ),
                                                                                ClipPath(
                                                                                  clipper: MyScoreFieldClipper(),
                                                                                  child: Container(
                                                                                    width: 40,
                                                                                    alignment: Alignment.center,
                                                                                    decoration: BoxDecoration(
                                                                                      color: darkMode ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.2),
                                                                                      // border:
                                                                                      //     const BorderDirectional(
                                                                                      //   top: BorderSide(
                                                                                      //       color: myPrimaryColor,
                                                                                      //       width: 0),
                                                                                      // ),
                                                                                    ),
                                                                                    child: Text(
                                                                                      subValuesList![index].toInt().toString(),
                                                                                      style: myDigitalStyle(color: myTextColor),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        } else {
                                                          return const Center(
                                                              child: Text(
                                                                  'No data'));
                                                        }
                                                      },
                                                    ),
                                                    buildVerticalSpacer(),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 0.w,
                                                          right: 10.w,
                                                          bottom: 0.h),
                                                      child: SizedBox(
                                                        height: 20.h,
                                                        width:
                                                            mobileContainerWidths,
                                                        child: Center(
                                                          child: Text(
                                                            "Detaylı analiz için bir konu seçin.",
                                                            style:
                                                                myThightStyle(
                                                              color:
                                                                  myTextColor,
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Padding(
                                                padding:
                                                    EdgeInsetsDirectional.only(
                                                  top: 70.h,
                                                  bottom: 0.w, // 10.w
                                                  end: 40.h,
                                                  start: 50.h,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: 10.h),
                                                      child: const CardNameText(
                                                          darkMode: false,
                                                          textColors:
                                                              myTextColor,
                                                          name:
                                                              "güçlü konular"),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .only(
                                                        end: 8.w,
                                                        start: 5.w,
                                                      ),
                                                      child: SizedBox(
                                                        height: 130.h,
                                                        width:
                                                            mobileContainerWidths,
                                                        child: ListView.builder(
                                                          itemCount: 3,
                                                          physics:
                                                              const BouncingScrollPhysics(),
                                                          itemBuilder:
                                                              (context, index) {
                                                            return TweenAnimationBuilder(
                                                              duration:
                                                                  Duration(
                                                                milliseconds:
                                                                    300 +
                                                                        (index *
                                                                            100),
                                                              ), // Her öğeye gecikme ekliyoruz
                                                              tween: Tween<
                                                                      double>(
                                                                  begin: -330.0,
                                                                  end:
                                                                      0.0), // Y ekseni kayma animasyonu
                                                              builder: (context,
                                                                  double value,
                                                                  child) {
                                                                return Transform
                                                                    .translate(
                                                                  offset:
                                                                      Offset(
                                                                          value,
                                                                          0),
                                                                  child: child,
                                                                );
                                                              },

                                                              child: Container(
                                                                margin:
                                                                    EdgeInsets
                                                                        .only(
                                                                  bottom: 15.h,
                                                                  left: 0,
                                                                  right: 10,
                                                                ),
                                                                child: ClipPath(
                                                                  clipper:
                                                                      MySubSkillCardClipper(),
                                                                  child:
                                                                      Container(
                                                                    height:
                                                                        27.h,
                                                                    width:
                                                                        mobileContainerWidths,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border: Border.all(
                                                                          color:
                                                                              myAccentColor,
                                                                          width:
                                                                              1.5),
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        const SizedBox(
                                                                          width:
                                                                              20,
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              ShaderMask(
                                                                            shaderCallback:
                                                                                (bounds) {
                                                                              return LinearGradient(
                                                                                begin: Alignment.centerLeft,
                                                                                end: Alignment.centerRight,
                                                                                colors: [
                                                                                  Colors.white.withOpacity(0.9), // Left fade
                                                                                  Colors.white, // Center fully visible
                                                                                  Colors.white.withOpacity(0.1), // Right fade
                                                                                ],
                                                                                stops: const [
                                                                                  0.0,
                                                                                  0.80,
                                                                                  1.0
                                                                                ],
                                                                              ).createShader(bounds);
                                                                            },
                                                                            blendMode:
                                                                                BlendMode.dstIn,
                                                                            child:
                                                                                SingleChildScrollView(
                                                                              scrollDirection: Axis.horizontal,
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(right: 8.0, left: 1.0),
                                                                                child: Text(
                                                                                  (index == 1
                                                                                          ? "Yazım kuralları"
                                                                                          : index == 2
                                                                                              ? "Paragraf"
                                                                                              : "Türev")
                                                                                      .toUpperCase(),
                                                                                  // subStatsData[index].name, böyle yapabilirsin

                                                                                  style: myTonicStyle(myTextColor, fontSize: 12),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        ClipPath(
                                                                          clipper:
                                                                              MyScoreFieldClipper(),
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                40,
                                                                            alignment:
                                                                                Alignment.center,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: darkMode ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.2),
                                                                              // border:
                                                                              //     const BorderDirectional(
                                                                              //   top: BorderSide(
                                                                              //       color: myPrimaryColor,
                                                                              //       width: 0),
                                                                              // ),
                                                                            ),
                                                                            child:
                                                                                Text(
                                                                              "88",
                                                                              style: myDigitalStyle(color: myTextColor),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
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
                                                          bottom: 10.h,
                                                          top: 25.h),
                                                      child: const CardNameText(
                                                          darkMode: false,
                                                          textColors:
                                                              myTextColor,
                                                          name:
                                                              "zayıf konular"),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .only(
                                                        end: 8.w,
                                                        start: 5.w,
                                                      ),
                                                      child: SizedBox(
                                                        height: 130.h,
                                                        width:
                                                            mobileContainerWidths,
                                                        child: ListView.builder(
                                                          physics:
                                                              const BouncingScrollPhysics(),
                                                          itemCount: 3,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return TweenAnimationBuilder(
                                                              duration:
                                                                  Duration(
                                                                milliseconds:
                                                                    300 +
                                                                        (index *
                                                                            100),
                                                              ), // Her öğeye gecikme ekliyoruz
                                                              tween: Tween<
                                                                      double>(
                                                                  begin: -330.0,
                                                                  end:
                                                                      0.0), // Y ekseni kayma animasyonu
                                                              builder: (context,
                                                                  double value,
                                                                  child) {
                                                                return Transform
                                                                    .translate(
                                                                  offset:
                                                                      Offset(
                                                                          value,
                                                                          0),
                                                                  child: child,
                                                                );
                                                              },
                                                              child: Container(
                                                                margin:
                                                                    EdgeInsets
                                                                        .only(
                                                                  bottom: 15.h,
                                                                  left: 0,
                                                                  right: 10,
                                                                ),
                                                                child: ClipPath(
                                                                  clipper:
                                                                      MySubSkillCardClipper(),
                                                                  child:
                                                                      Container(
                                                                    height:
                                                                        27.h,
                                                                    width: 120,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border: Border.all(
                                                                          color:
                                                                              myBackgroundColor,
                                                                          width:
                                                                              1.5),
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        const SizedBox(
                                                                          width:
                                                                              20,
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              ShaderMask(
                                                                            shaderCallback:
                                                                                (bounds) {
                                                                              return LinearGradient(
                                                                                begin: Alignment.centerLeft,
                                                                                end: Alignment.centerRight,
                                                                                colors: [
                                                                                  Colors.white.withOpacity(0.9), // Left fade
                                                                                  Colors.white, // Center fully visible
                                                                                  Colors.white.withOpacity(0.1), // Right fade
                                                                                ],
                                                                                stops: const [
                                                                                  0.0,
                                                                                  0.80,
                                                                                  1.0
                                                                                ],
                                                                              ).createShader(bounds);
                                                                            },
                                                                            blendMode:
                                                                                BlendMode.dstIn,
                                                                            child:
                                                                                SingleChildScrollView(
                                                                              scrollDirection: Axis.horizontal,
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(right: 8.0, left: 1.0),
                                                                                child: Text(
                                                                                  (index == 1
                                                                                          ? "olasılık"
                                                                                          : index == 2
                                                                                              ? "trigonometri"
                                                                                              : "Denklem ve Eşitsizlikler")
                                                                                      .toUpperCase(),
                                                                                  // subStatsData[index].name, böyle yapabilirsin

                                                                                  style: myTonicStyle(myTextColor, fontSize: 12),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        ClipPath(
                                                                          clipper:
                                                                              MyScoreFieldClipper(),
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                40,
                                                                            alignment:
                                                                                Alignment.center,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: darkMode ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.2),
                                                                              // border:
                                                                              //     const BorderDirectional(
                                                                              //   top: BorderSide(
                                                                              //       color: myPrimaryColor,
                                                                              //       width: 0),
                                                                              // ),
                                                                            ),
                                                                            child:
                                                                                Text(
                                                                              "55",
                                                                              style: myDigitalStyle(color: myTextColor),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    buildVerticalSpacer(),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 5.w,
                                                          right: 5.w,
                                                          bottom: 0.h),
                                                      child: SizedBox(
                                                        height: 20.h,
                                                        width:
                                                            mobileContainerWidths,
                                                        child: Center(
                                                          child: Text(
                                                            "Güçlü ve zayıf konular son 5 denemedeki istatistiklere göre hesaplanmaktadır.",
                                                            style:
                                                                myThightStyle(
                                                              color:
                                                                  myTextColor,
                                                              fontSize: 10,
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
                                    buildVerticalSpacer(),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // DeepLine
                                  Container(
                                    color: subHeaderActivated
                                        ? Colors.transparent
                                        : Colors.transparent,
                                    width: mobileContainerWidths +
                                        (2 * sidePaddings),
                                    height: subHeaderActivated
                                        ? multiLineHeight + 0.1
                                        : multiLineHeight * 1.2,
                                    alignment: Alignment.topCenter,
                                    child: Stack(
                                      children: [
                                        if (true)
                                          Positioned(
                                            top: 0,
                                            child: FutureBuilder(
                                              future: multiScoresFuture,
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Center(
                                                      child: SizedBox());
                                                } else if (snapshot.hasError) {
                                                  return const Center(
                                                      child: SizedBox());
                                                } else if (snapshot.hasData) {
                                                  final multiScoresData =
                                                      snapshot.data;

                                                  return Container(
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    child: FittedBox(
                                                      child: DeepLineChart(
                                                        showTags: false,
                                                        lineChart: false,
                                                        scoreMap:
                                                            multiScoresData!,
                                                        callbackFunct:
                                                            _updateHeaderFromMultiLine,
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return const Center(
                                                      child: Text(
                                                          'Player not found.'));
                                                }
                                              },
                                            ),
                                          ),
                                        // multiLine2
                                        if (!subHeaderActivated)
                                          Positioned(
                                            top: 240.h, //multiLineHeight / 1.8,
                                            child: Container(
                                              color: Colors.transparent,
                                              width: mobileContainerWidths +
                                                  (2 * sidePaddings),
                                              // height: multiLineHeight / 3 * 2 + 0.1,
                                              alignment: Alignment.bottomCenter,
                                              child: FutureBuilder(
                                                future: multiScoresFuture,
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Center(
                                                        child: SizedBox());
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Center(
                                                        child: SizedBox());
                                                  } else if (snapshot.hasData) {
                                                    final multiScoresData =
                                                        snapshot.data;

                                                    return Container(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child: FittedBox(
                                                        child: DeepLineChart(
                                                          lineChart: true,
                                                          showTags: false,
                                                          scoreMap:
                                                              multiScoresData!,
                                                          callbackFunct:
                                                              _updateHeaderFromMultiLine,
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    return const Center(
                                                        child: Text(
                                                            'Player not found.'));
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  buildVerticalSpacer(),
                                  // SingleLine Chart (puan)
                                  Container(
                                    width: mobileContainerWidths,
                                    height: multiLineHeight,
                                    decoration: buildBorderDecoration(),
                                    child: FutureBuilder(
                                      future: scoresFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  'Error: ${snapshot.error}'));
                                        } else if (snapshot.hasData) {
                                          final scoresData =
                                              snapshot.data as List<Score>;
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: 40.h, bottom: 0.h),
                                                child: SizedBox(
                                                  width: mobileContainerWidths,
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          SizedBox(
                                                            height: 58.h,
                                                            width: 80
                                                                .w, // elemanların uzunluğunun toplamı
                                                            child: Center(
                                                              child: FittedBox(
                                                                child: Text(
                                                                  "71",
                                                                  style: myDigitalStyle(
                                                                      color:
                                                                          mySecondaryTextColor,
                                                                      fontSize:
                                                                          32),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 50.w,
                                                            height: 30.h,
                                                            child: FittedBox(
                                                              child: Text(
                                                                // ${capitalize((headersLabel ?? "total").toLowerCase())}
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                "son 5 denemedeki\npuan  ortalaması",
                                                                style:
                                                                    myThightStyle(
                                                                  color:
                                                                      mySecondaryTextColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      buildLateralSpacer(),
                                                      buildLateralSpacer(),
                                                      buildLateralSpacer(),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            height: 50.h,
                                                            width: 50
                                                                .w, // elemanların uzunluğunun toplamı
                                                            decoration: const BoxDecoration(
                                                                border: BorderDirectional(
                                                                    bottom: BorderSide(
                                                                        color:
                                                                            myIconsColor))),
                                                            child: Center(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  SizedBox(
                                                                    width: 20.w,
                                                                    child:
                                                                        FittedBox(
                                                                      child:
                                                                          Text(
                                                                        "4.8",
                                                                        style: myDigitalStyle(
                                                                            color:
                                                                                mySecondaryTextColor,
                                                                            fontSize:
                                                                                32),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 3.w,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 16.w,
                                                                    child:
                                                                        const FittedBox(
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .upgrade_outlined,
                                                                        color:
                                                                            myIconsColor,
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
                                                          SizedBox(
                                                            width: 60.w,
                                                            height: 25.h,
                                                            child: FittedBox(
                                                              child: Text(
                                                                // ${capitalize((headersLabel ?? "total").toLowerCase())} puanlarının \n
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,

                                                                "ortalama \n artış miktarı",
                                                                style:
                                                                    myThightStyle(
                                                                  color:
                                                                      mySecondaryTextColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Divider(
                                                color: myPrimaryColor,
                                                thickness: 0.5,
                                                indent: 50.w,
                                                endIndent: 50.w,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      // height: 25.h,
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: FittedBox(
                                                          fit: BoxFit.fitHeight,
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 10.h),
                                                            child: Text(
                                                              "Puan Grafiği",
                                                              style:
                                                                  myThightStyle(
                                                                color:
                                                                    mySecondaryTextColor,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    ShaderMask(
                                                      shaderCallback:
                                                          (bounds) =>
                                                              LinearGradient(
                                                        begin: Alignment
                                                            .centerLeft,
                                                        end: Alignment
                                                            .centerRight,
                                                        colors: [
                                                          Colors.white
                                                              .withOpacity(
                                                                  0.35),
                                                          Colors.white
                                                              .withOpacity(0.7),
                                                          Colors.white
                                                              .withOpacity(1),
                                                          Colors.white
                                                              .withOpacity(0.7),
                                                          Colors.white
                                                              .withOpacity(
                                                                  0.35),
                                                        ],
                                                        stops: const [
                                                          0.0,
                                                          0.05,
                                                          0.5,
                                                          0.95,
                                                          1
                                                        ],
                                                      ).createShader(bounds),
                                                      child:
                                                          SingleChildScrollView(
                                                        physics:
                                                            const BouncingScrollPhysics(),
                                                        padding: isMobile(
                                                                context)
                                                            ? EdgeInsetsDirectional
                                                                .only(
                                                                    start: 50.w,
                                                                    end: 50.w,
                                                                    top: 5,
                                                                    bottom: 18)
                                                            : EdgeInsetsDirectional
                                                                .only(
                                                                    start: 5.w,
                                                                    end: 25.w,
                                                                    top: 0,
                                                                    bottom: 18),
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                            top: 5.h,
                                                          ),
                                                          child: SizedBox(
                                                            width:
                                                                chartWidthCalculator(
                                                                    scoresData
                                                                        .length),
                                                            height: 110.h,
                                                            child: ScoreChart(
                                                                scores:
                                                                    scoresData),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 45.h,
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: FittedBox(
                                                          //fit: BoxFit.fitHeight,
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 30.h),
                                                            child: Text(
                                                              "Puan hesaplanırken soruların zorluğu da değerlendirilir.",
                                                              style:
                                                                  myThightStyle(
                                                                color:
                                                                    mySecondaryTextColor,
                                                              ),
                                                            ),
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
                                          return const Center(
                                              child: Text('Player not found.'));
                                        }
                                      },
                                    ),
                                  ),

                                  buildVerticalSpacer(),
                                  // SingleLine Chart (net)
                                  Container(
                                    width: mobileContainerWidths,
                                    height: singleLineChartHeight,
                                    decoration: buildBorderDecoration(),
                                    child: FutureBuilder(
                                      future: scoresFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  'Error: ${snapshot.error}'));
                                        } else if (snapshot.hasData) {
                                          final scoresData =
                                              snapshot.data as List<Score>;

                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      // height: 25.h,
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: FittedBox(
                                                          fit: BoxFit.fitHeight,
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 10.h),
                                                            child: Text(
                                                              // "Tüm denemelerdeki ${(headersLabel ?? "total").toLowerCase()} netleri ve diğer öğrencilerin net ortalaması",
                                                              "Net Grafiği",
                                                              style:
                                                                  myThightStyle(
                                                                color:
                                                                    mySecondaryTextColor,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    ShaderMask(
                                                      shaderCallback:
                                                          (bounds) =>
                                                              LinearGradient(
                                                        begin: Alignment
                                                            .centerLeft,
                                                        end: Alignment
                                                            .centerRight,
                                                        colors: [
                                                          Colors.white
                                                              .withOpacity(
                                                                  0.35),
                                                          Colors.white
                                                              .withOpacity(0.7),
                                                          Colors.white
                                                              .withOpacity(1),
                                                          Colors.white
                                                              .withOpacity(0.7),
                                                          Colors.white
                                                              .withOpacity(
                                                                  0.35),
                                                        ],
                                                        stops: const [
                                                          0.0,
                                                          0.05,
                                                          0.5,
                                                          0.95,
                                                          1
                                                        ],
                                                      ).createShader(bounds),
                                                      child:
                                                          SingleChildScrollView(
                                                        physics:
                                                            const BouncingScrollPhysics(),
                                                        padding: isMobile(
                                                                context)
                                                            ? EdgeInsetsDirectional
                                                                .only(
                                                                    start: 50.w,
                                                                    end: 50.w,
                                                                    top: 5,
                                                                    bottom: 18)
                                                            : EdgeInsetsDirectional
                                                                .only(
                                                                    start: 5.w,
                                                                    end: 25.w,
                                                                    top: 0,
                                                                    bottom: 18),
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                            top: 5.h,
                                                          ),
                                                          child: SizedBox(
                                                            width:
                                                                chartWidthCalculator(
                                                                    scoresData
                                                                        .length),
                                                            height: 110.h,
                                                            child: ScoreChart(
                                                              scores:
                                                                  randomizeScores(
                                                                      scoresData),
                                                              scores2:
                                                                  randomizeScores(
                                                                      scoresData),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              _buildLegend(isMobile(context)),
                                              SizedBox(
                                                height: 20.h,
                                              )
                                            ],
                                          );
                                        } else {
                                          return const Center(
                                              child: Text('Player not found.'));
                                        }
                                      },
                                    ),
                                  ),
                                  buildVerticalSpacer(),
                                  // SingleLine Chart (sıralama)
                                  Container(
                                    width: mobileContainerWidths,
                                    height: singleLineChartHeight,
                                    decoration: buildBorderDecoration(),
                                    child: FutureBuilder(
                                      future: scoresFuture,
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  'Error: ${snapshot.error}'));
                                        } else if (snapshot.hasData) {
                                          final scoresData =
                                              snapshot.data as List<Score>;
                                          return Column(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      // height: 25.h,
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: FittedBox(
                                                          fit: BoxFit.fitHeight,
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 15.h),
                                                            child: Text(
                                                              // ${(headersLabel ?? "total").toLowerCase()} kaldırdım.
                                                              "Sıralama Grafiği",
                                                              style:
                                                                  myThightStyle(
                                                                color:
                                                                    mySecondaryTextColor,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    ShaderMask(
                                                      shaderCallback:
                                                          (bounds) =>
                                                              LinearGradient(
                                                        begin: Alignment
                                                            .centerLeft,
                                                        end: Alignment
                                                            .centerRight,
                                                        colors: [
                                                          Colors.white
                                                              .withOpacity(
                                                                  0.35),
                                                          Colors.white
                                                              .withOpacity(0.7),
                                                          Colors.white
                                                              .withOpacity(1),
                                                          Colors.white
                                                              .withOpacity(0.7),
                                                          Colors.white
                                                              .withOpacity(
                                                                  0.35),
                                                        ],
                                                        stops: const [
                                                          0.0,
                                                          0.05,
                                                          0.5,
                                                          0.95,
                                                          1
                                                        ],
                                                      ).createShader(bounds),
                                                      child:
                                                          SingleChildScrollView(
                                                        physics:
                                                            const BouncingScrollPhysics(),
                                                        padding: isMobile(
                                                                context)
                                                            ? EdgeInsetsDirectional
                                                                .only(
                                                                    start: 50.w,
                                                                    end: 50.w,
                                                                    top: 5,
                                                                    bottom: 18)
                                                            : EdgeInsetsDirectional
                                                                .only(
                                                                    start: 5.w,
                                                                    end: 25.w,
                                                                    top: 0,
                                                                    bottom: 18),
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                            top: 5.h,
                                                          ),
                                                          child: SizedBox(
                                                            width:
                                                                chartWidthCalculator(
                                                                    scoresData
                                                                        .length),
                                                            height: 110.h,
                                                            child: ScoreChart(
                                                                decrease: true,
                                                                scores: randomizeScores(
                                                                    scoresData)),
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
                                          return const Center(
                                              child: Text('Player not found.'));
                                        }
                                      },
                                    ),
                                  ),
                                  buildVerticalSpacer(),
                                  // Zorluk MultiLine Chart
                                  Container(
                                    width: mobileContainerWidths,
                                    height: multiLineHeight,
                                    decoration: buildBorderDecoration(),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          // height: 25.h,
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: FittedBox(
                                              fit: BoxFit.fitHeight,
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(top: 40.h),
                                                child: Text(
                                                  // "Tüm denemelerdeki ${(headersLabel ?? "total").toLowerCase()} netleri ve diğer öğrencilerin net ortalaması",
                                                  "Zorluk Grafiği",
                                                  style: myThightStyle(
                                                    color: mySecondaryTextColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        FutureBuilder(
                                          future: multiScoresFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            } else if (snapshot.hasError) {
                                              return Center(
                                                  child: Text(
                                                      'Error: ${snapshot.error}'));
                                            } else if (snapshot.hasData) {
                                              final multiScoresData =
                                                  snapshot.data;

                                              return SizedBox(
                                                height: multiLineHeight * 0.8,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 30.w,
                                                      top: 10.h,
                                                      bottom: 10.h,
                                                      right: 30.w),
                                                  child: FittedBox(
                                                    //  fit: BoxFit.fitHeight,
                                                    child: DifficultyMultiChart(
                                                      // düzgün çalışmıyor
                                                      showTags: true,
                                                      showNegative: true,
                                                      scoreMap: {
                                                        "Doğru": [
                                                          Score(
                                                              name: "name",
                                                              discipleID: 8,
                                                              skillID: 2,
                                                              score: 99),
                                                          Score(
                                                              name: "name",
                                                              discipleID: 8,
                                                              skillID: 2,
                                                              score: 69),
                                                          Score(
                                                              name: "name",
                                                              discipleID: 8,
                                                              skillID: 2,
                                                              score: 79),
                                                          Score(
                                                              name: "name",
                                                              discipleID: 8,
                                                              skillID: 2,
                                                              score: 29),
                                                        ],
                                                        "Yanlış": [
                                                          Score(
                                                              name: "name",
                                                              discipleID: 8,
                                                              skillID: 2,
                                                              score: 59),
                                                          Score(
                                                              name: "name",
                                                              discipleID: 8,
                                                              skillID: 2,
                                                              score: 39),
                                                          Score(
                                                              name: "name",
                                                              discipleID: 8,
                                                              skillID: 2,
                                                              score: 19),
                                                          Score(
                                                              name: "name",
                                                              discipleID: 8,
                                                              skillID: 2,
                                                              score: 29),
                                                        ],
                                                        "Boş": [
                                                          Score(
                                                              name: "name",
                                                              discipleID: 8,
                                                              skillID: 2,
                                                              score: 59),
                                                          Score(
                                                              name: "name",
                                                              discipleID: 8,
                                                              skillID: 2,
                                                              score: 69),
                                                          Score(
                                                              name: "name",
                                                              discipleID: 8,
                                                              skillID: 2,
                                                              score: 12),
                                                          Score(
                                                              name: "name",
                                                              discipleID: 8,
                                                              skillID: 2,
                                                              score: 79),
                                                          Score(
                                                              name: "name",
                                                              discipleID: 8,
                                                              skillID: 2,
                                                              score: 59),
                                                          Score(
                                                              name: "name",
                                                              discipleID: 8,
                                                              skillID: 2,
                                                              score: 69),
                                                          Score(
                                                              name: "name",
                                                              discipleID: 8,
                                                              skillID: 2,
                                                              score: 12),
                                                          Score(
                                                              name: "name",
                                                              discipleID: 8,
                                                              skillID: 2,
                                                              score: 79),
                                                          Score(
                                                              name: "name",
                                                              discipleID: 8,
                                                              skillID: 2,
                                                              score: 59),
                                                          Score(
                                                              name: "name",
                                                              discipleID: 8,
                                                              skillID: 2,
                                                              score: 69),
                                                        ],
                                                        "Zorluk": [
                                                          Score(
                                                              name: "name",
                                                              discipleID: 8,
                                                              skillID: 2,
                                                              score: 32),
                                                          Score(
                                                              name: "name",
                                                              discipleID: 8,
                                                              skillID: 2,
                                                              score: 69),
                                                          Score(
                                                              name: "name",
                                                              discipleID: 8,
                                                              skillID: 2,
                                                              score: 12),
                                                          Score(
                                                              name: "name",
                                                              discipleID: 8,
                                                              skillID: 2,
                                                              score: -15),
                                                        ],
                                                      },
                                                      callbackFunct:
                                                          _updateHeaderFromMultiLine,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return const Center(
                                                  child: Text(
                                                      'Player not found.'));
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  buildVerticalSpacer(),
                                  // Awards Button
                                  Container(
                                    width: mobileContainerWidths,
                                    height: miniBoxHeights,
                                    decoration: buildBorderDecoration(),
                                    padding: EdgeInsetsDirectional.only(
                                      top: 20.h,
                                      //start: 5.w,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                horizontal: 15.w,
                                                vertical: 15.h),
                                            child: Container(
                                              decoration: buildInsideShadow(),
                                              alignment: Alignment.center,
                                              child: Padding(
                                                padding: EdgeInsets.all(3.h),
                                                child: Image(
                                                  width: mobileContainerWidths,
                                                  height: miniBoxHeights * 0.6,
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
                                  buildVerticalSpacer(),
                                  buildVerticalSpacer(),
                                  buildVerticalSpacer(),
                                  buildVerticalSpacer(),
                                  buildVerticalSpacer(),
                                  buildVerticalSpacer(),
                                  buildVerticalSpacer(),
                                  buildVerticalSpacer(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Scaffold(
                  resizeToAvoidBottomInset: false,
                  appBar: buildAppBar(context, true),
                  backgroundColor: darkMode
                      ? myBackgroundColor.withOpacity(0.93)
                      : myBackgroundColor.withOpacity(0.8),
                  body: MouseRegion(
                    onHover: (event) {
                      Offset pos = event.localPosition;

                      /// Eğer fare ekranın kenarlarına çok yakınsa ışığı gizle
                      if (pos.dx < edgeMargin ||
                          pos.dx > screenWidth - edgeMargin ||
                          pos.dy > screenHeight - edgeMargin) {
                        setState(
                            () => _mousePosition = const Offset(-500, -500));
                      } else {
                        setState(() => _mousePosition = pos);
                      }
                    },
                    onExit: (_) {
                      setState(() {
                        _mousePosition = const Offset(
                            -500, -500); // Fare çıkınca ışık yok olsun
                      });
                    },
                    child: Stack(
                      children: [
                        if (darkMode)

                          /// 🔹 Işık Efekti (Arka Planda)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: LightPainter(_mousePosition),
                            ),
                          ),
                        Positioned.fill(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: firstColumnWidth +
                                  thirdColumnWidth +
                                  secondColumnWidth +
                                  secondColumnWidth +
                                  15 * lateralSpace,
                              child: Row(
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
                                          playerID:
                                              playerController.getDiscipleID(),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const CardNameText(
                                                textColors:
                                                    mySecondaryTextColor,
                                                name: "Ödül Köşesi"),
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            Center(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5.w,
                                                    vertical: 2.w),
                                                child: Container(
                                                  decoration:
                                                      buildInsideShadow(),
                                                  alignment: Alignment.center,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(3.h),
                                                    child: Image(
                                                      width: firstColumnWidth /
                                                          3 *
                                                          2,
                                                      height: miniBoxHeights /
                                                          3 *
                                                          1.3,
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

                                      Row(
                                        children: [
                                          Column(
                                            children: [
                                              // Ana Beceri Başlığı
                                              Container(
                                                width: indicatorHeight,
                                                height: headerHeight,
                                                decoration:
                                                    buildBorderDecoration(),
                                                child: Container(
                                                  decoration:
                                                      buildSelectedDecoration(
                                                          isMobile(context)),
                                                  margin: EdgeInsetsDirectional
                                                      .symmetric(
                                                          vertical: 25.h,
                                                          horizontal: 50.h),
                                                  padding: EdgeInsetsDirectional
                                                      .symmetric(
                                                          vertical: 15.h,
                                                          horizontal: 20.h),
                                                  child: FittedBox(
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          headersStatValue !=
                                                                  null
                                                              ? headersStatValue
                                                                  .toString()
                                                              : "",
                                                          style: myDigitalStyle(
                                                              color:
                                                                  mySecondaryTextColor,
                                                              fontSize: 16),
                                                        ),
                                                        Text(
                                                          headersLabel ??
                                                              "Bir ders seçin.",
                                                          style: myTonicStyle(
                                                              mySecondaryTextColor),
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
                                                decoration:
                                                    buildBorderDecoration(),
                                                child: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors
                                                        .transparent, // Dairenin iç rengi
                                                    shape: BoxShape
                                                        .circle, // Daire şekli
                                                  ),
                                                  //margin: const EdgeInsetsDirectional.all(60),
                                                  child:
                                                      buildFutureStatsIndicator(),
                                                ),
                                              ),
                                            ],
                                          ),
                                          // SubStats

                                          buildLateralSpacer(),
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
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .only(
                                                          top: 10.w,
                                                          bottom: 0.w, // 10.w
                                                          end: 40.h,
                                                          start: 50.h,
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 0.w,
                                                                      right:
                                                                          10.w,
                                                                      bottom:
                                                                          20.h),
                                                              child: SizedBox(
                                                                height: 30,
                                                                width:
                                                                    mobileContainerWidths,
                                                                child: Center(
                                                                  child: Text(
                                                                    "Son 5 denemedeki istatistiklere göre",
                                                                    style:
                                                                        myThightStyle(
                                                                      color:
                                                                          mySecondaryTextColor,
                                                                      fontSize:
                                                                          10,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            buildVerticalSpacer(),
                                                            Expanded(
                                                              child:
                                                                  FutureBuilder<
                                                                      List<
                                                                          Score>>(
                                                                key:
                                                                    subStatsFutureResetterKey,
                                                                future:
                                                                    subStatsFuture,
                                                                builder: (context,
                                                                    snapshot) {
                                                                  if (snapshot
                                                                          .connectionState ==
                                                                      ConnectionState
                                                                          .waiting) {
                                                                    return const Center(
                                                                        child:
                                                                            CircularProgressIndicator());
                                                                  } else if (snapshot
                                                                      .hasError) {
                                                                    return Center(
                                                                        child: Text(
                                                                            'Error: ${snapshot.error}'));
                                                                  } else if (snapshot
                                                                      .hasData) {
                                                                    final subStatsData =
                                                                        snapshot
                                                                            .data!;
                                                                    subValuesList = subStatsData
                                                                        .map((score) => score
                                                                            .score
                                                                            .toDouble())
                                                                        .toList();
                                                                    subKeysList = subStatsData
                                                                        .map((score) =>
                                                                            score.name)
                                                                        .toList();
                                                                    subIdsList = subStatsData
                                                                        .map((score) =>
                                                                            score.skillID)
                                                                        .toList();

                                                                    return ListView
                                                                        .builder(
                                                                      physics:
                                                                          const BouncingScrollPhysics(),
                                                                      itemCount:
                                                                          subStatsData
                                                                              .length,
                                                                      itemBuilder:
                                                                          (context,
                                                                              index) {
                                                                        return MouseRegion(
                                                                          onEnter:
                                                                              (_) {
                                                                            setState(() {
                                                                              hoveredSubSkillIndex = index; // Hover olan index'i ayarla
                                                                            });
                                                                          },
                                                                          onExit:
                                                                              (_) {
                                                                            setState(() {
                                                                              hoveredSubSkillIndex = null; // Hover olmayan durumda null yap
                                                                            });
                                                                          },
                                                                          child:
                                                                              GestureDetector(
                                                                            onTapUp:
                                                                                (details) {
                                                                              setState(() {
                                                                                selectedSubSkill = index;
                                                                                _updateHeaderFromSubStats(
                                                                                  clickedSkillId: subIdsList![index],
                                                                                  clickedSkillName: subKeysList![index],
                                                                                  clickedSkillStat: subValuesList![index].toInt(),
                                                                                );
                                                                              });
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              // decoration: index == selectedIndex
                                                                              //     ? buildSelectedDecoration()
                                                                              //     : BoxDecoration(
                                                                              //         border: Border.all(
                                                                              //             color: myPrimaryColor,
                                                                              //             width: 0.8),
                                                                              //       ),
                                                                              margin: EdgeInsets.only(
                                                                                bottom: 15.h,
                                                                                left: index == hoveredSubSkillIndex || index == selectedSubSkill ? 10 : 0,
                                                                                right: index == hoveredSubSkillIndex || index == selectedSubSkill ? 0 : 10,
                                                                                // left: (index % 2 == 1) ? 10 : 0,
                                                                                // right: (index % 2 == 0) ? 10 : 0,
                                                                              ),
                                                                              child: ClipPath(
                                                                                clipper: MySubSkillCardClipper(),
                                                                                child: Container(
                                                                                  height: 27.h,
                                                                                  width: 120,
                                                                                  decoration: BoxDecoration(
                                                                                    border: Border.all(color: myPrimaryColor, width: 0.8),
                                                                                  ),
                                                                                  child: Row(
                                                                                    children: [
                                                                                      const SizedBox(
                                                                                        width: 20,
                                                                                      ),
                                                                                      Expanded(
                                                                                        child: ShaderMask(
                                                                                          shaderCallback: (bounds) {
                                                                                            return LinearGradient(
                                                                                              begin: Alignment.centerLeft,
                                                                                              end: Alignment.centerRight,
                                                                                              colors: [
                                                                                                Colors.white.withOpacity(0.9), // Left fade
                                                                                                Colors.white, // Center fully visible
                                                                                                Colors.white.withOpacity(0.1), // Right fade
                                                                                              ],
                                                                                              stops: const [0.0, 0.80, 1.0],
                                                                                            ).createShader(bounds);
                                                                                          },
                                                                                          blendMode: BlendMode.dstIn,
                                                                                          child: SingleChildScrollView(
                                                                                            scrollDirection: Axis.horizontal,
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsets.only(right: 8.0, left: 1.0),
                                                                                              child: Text(
                                                                                                subKeysList![index],
                                                                                                // subStatsData[index].name, böyle yapabilirsin

                                                                                                style: myTonicStyle(mySecondaryTextColor, fontSize: 12),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        width: 5,
                                                                                      ),
                                                                                      ClipPath(
                                                                                        clipper: MyScoreFieldClipper(),
                                                                                        child: Container(
                                                                                          width: 40,
                                                                                          alignment: Alignment.center,
                                                                                          decoration: BoxDecoration(
                                                                                            color: darkMode ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.2),
                                                                                            // border:
                                                                                            //     const BorderDirectional(
                                                                                            //   top: BorderSide(
                                                                                            //       color: myPrimaryColor,
                                                                                            //       width: 0),
                                                                                            // ),
                                                                                          ),
                                                                                          child: Text(
                                                                                            subValuesList![index].toInt().toString(),
                                                                                            style: myDigitalStyle(color: mySecondaryTextColor),
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
                                                                        child: Text(
                                                                            'No data'));
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                            buildVerticalSpacer(),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 0.w,
                                                                      right:
                                                                          10.w,
                                                                      bottom:
                                                                          20.h),
                                                              child: SizedBox(
                                                                height: 30,
                                                                width:
                                                                    mobileContainerWidths,
                                                                child: Center(
                                                                  child: Text(
                                                                    "Bir konu seçebilirsiniz.",
                                                                    style:
                                                                        myThightStyle(
                                                                      color:
                                                                          mySecondaryTextColor,
                                                                      fontSize:
                                                                          10,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .only(
                                                          top: 40.h,
                                                          bottom: 0.w, // 10.w
                                                          start: 5.w,
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      bottom:
                                                                          20.h),
                                                              child: const CardNameText(
                                                                  textColors:
                                                                      mySecondaryTextColor,
                                                                  name:
                                                                      "güçlü konular"),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .only(
                                                                end: 8.w,
                                                                start: 5.w,
                                                              ),
                                                              child: SizedBox(
                                                                height: 120.h,
                                                                width:
                                                                    subStatsWidth -
                                                                        0,
                                                                child: ListView
                                                                    .builder(
                                                                  physics:
                                                                      const BouncingScrollPhysics(),
                                                                  itemCount: 3,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return Container(
                                                                      margin: EdgeInsets
                                                                          .only(
                                                                        bottom:
                                                                            15.h,
                                                                        left: 0,
                                                                        right:
                                                                            10,
                                                                      ),
                                                                      child:
                                                                          ClipPath(
                                                                        clipper:
                                                                            MySubSkillCardClipper(),
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              27.h,
                                                                          width:
                                                                              120,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            border:
                                                                                Border.all(color: myAccentColor, width: 0.8),
                                                                          ),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              const SizedBox(
                                                                                width: 20,
                                                                              ),
                                                                              Expanded(
                                                                                child: ShaderMask(
                                                                                  shaderCallback: (bounds) {
                                                                                    return LinearGradient(
                                                                                      begin: Alignment.centerLeft,
                                                                                      end: Alignment.centerRight,
                                                                                      colors: [
                                                                                        Colors.white.withOpacity(0.9), // Left fade
                                                                                        Colors.white, // Center fully visible
                                                                                        Colors.white.withOpacity(0.1), // Right fade
                                                                                      ],
                                                                                      stops: const [
                                                                                        0.0,
                                                                                        0.80,
                                                                                        1.0
                                                                                      ],
                                                                                    ).createShader(bounds);
                                                                                  },
                                                                                  blendMode: BlendMode.dstIn,
                                                                                  child: SingleChildScrollView(
                                                                                    scrollDirection: Axis.horizontal,
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.only(right: 8.0, left: 1.0),
                                                                                      child: Text(
                                                                                        (index == 1
                                                                                                ? "Yazım kuralları"
                                                                                                : index == 2
                                                                                                    ? "Paragraf"
                                                                                                    : "Türev")
                                                                                            .toUpperCase(),
                                                                                        // subStatsData[index].name, böyle yapabilirsin

                                                                                        style: myTonicStyle(mySecondaryTextColor, fontSize: 12),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(
                                                                                width: 5,
                                                                              ),
                                                                              ClipPath(
                                                                                clipper: MyScoreFieldClipper(),
                                                                                child: Container(
                                                                                  width: 40,
                                                                                  alignment: Alignment.center,
                                                                                  decoration: BoxDecoration(
                                                                                    color: darkMode ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.2),
                                                                                    // border:
                                                                                    //     const BorderDirectional(
                                                                                    //   top: BorderSide(
                                                                                    //       color: myPrimaryColor,
                                                                                    //       width: 0),
                                                                                    // ),
                                                                                  ),
                                                                                  child: Text(
                                                                                    "88",
                                                                                    style: myDigitalStyle(color: mySecondaryTextColor),
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
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      bottom:
                                                                          15.h,
                                                                      top:
                                                                          25.h),
                                                              child: const CardNameText(
                                                                  textColors:
                                                                      mySecondaryTextColor,
                                                                  name:
                                                                      "zayıf konular"),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .only(
                                                                end: 8.w,
                                                                start: 5.w,
                                                              ),
                                                              child: SizedBox(
                                                                height: 120.h,
                                                                width:
                                                                    subStatsWidth -
                                                                        0,
                                                                child: ListView
                                                                    .builder(
                                                                  physics:
                                                                      const BouncingScrollPhysics(),
                                                                  itemCount: 3,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return Container(
                                                                      margin: EdgeInsets
                                                                          .only(
                                                                        bottom:
                                                                            15.h,
                                                                        left: 0,
                                                                        right:
                                                                            10,
                                                                      ),
                                                                      child:
                                                                          ClipPath(
                                                                        clipper:
                                                                            MySubSkillCardClipper(),
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              27.h,
                                                                          width:
                                                                              120,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            border:
                                                                                Border.all(color: myPrimaryColor, width: 0.8),
                                                                          ),
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              const SizedBox(
                                                                                width: 20,
                                                                              ),
                                                                              Expanded(
                                                                                child: ShaderMask(
                                                                                  shaderCallback: (bounds) {
                                                                                    return LinearGradient(
                                                                                      begin: Alignment.centerLeft,
                                                                                      end: Alignment.centerRight,
                                                                                      colors: [
                                                                                        Colors.white.withOpacity(0.9), // Left fade
                                                                                        Colors.white, // Center fully visible
                                                                                        Colors.white.withOpacity(0.1), // Right fade
                                                                                      ],
                                                                                      stops: const [
                                                                                        0.0,
                                                                                        0.80,
                                                                                        1.0
                                                                                      ],
                                                                                    ).createShader(bounds);
                                                                                  },
                                                                                  blendMode: BlendMode.dstIn,
                                                                                  child: SingleChildScrollView(
                                                                                    scrollDirection: Axis.horizontal,
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.only(right: 8.0, left: 1.0),
                                                                                      child: Text(
                                                                                        (index == 1
                                                                                                ? "olasılık"
                                                                                                : index == 2
                                                                                                    ? "trigonometri"
                                                                                                    : "Denklem ve Eşitsizlikler")
                                                                                            .toUpperCase(),
                                                                                        // subStatsData[index].name, böyle yapabilirsin

                                                                                        style: myTonicStyle(mySecondaryTextColor, fontSize: 12),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(
                                                                                width: 5,
                                                                              ),
                                                                              ClipPath(
                                                                                clipper: MyScoreFieldClipper(),
                                                                                child: Container(
                                                                                  width: 40,
                                                                                  alignment: Alignment.center,
                                                                                  decoration: BoxDecoration(
                                                                                    color: darkMode ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.2),
                                                                                    // border:
                                                                                    //     const BorderDirectional(
                                                                                    //   top: BorderSide(
                                                                                    //       color: myPrimaryColor,
                                                                                    //       width: 0),
                                                                                    // ),
                                                                                  ),
                                                                                  child: Text(
                                                                                    "55",
                                                                                    style: myDigitalStyle(color: mySecondaryTextColor),
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
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 5.w,
                                                                      bottom:
                                                                          15.h),
                                                              child: SizedBox(
                                                                height: 30.h,
                                                                width: 35.w,
                                                                child:
                                                                    FittedBox(
                                                                  child: Text(
                                                                    "Son 5 denemedeki istatistiklere göre",
                                                                    style:
                                                                        myThightStyle(
                                                                      color:
                                                                          mySecondaryTextColor,
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
                                        ],
                                      ),
                                      buildVerticalSpacer(),
                                      // Net Grafiği (Single Line)
                                      Container(
                                        width: secondColumnWidth,
                                        height: miniBoxHeights,
                                        decoration: buildBorderDecoration(),
                                        child: FutureBuilder(
                                          future: scoresFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            } else if (snapshot.hasError) {
                                              return Center(
                                                  child: Text(
                                                      'Error: ${snapshot.error}'));
                                            } else if (snapshot.hasData) {
                                              final scoresData =
                                                  snapshot.data as List<Score>;

                                              if (dontReloadFlag) {
                                                scoresData2 =
                                                    randomizeScores(scoresData);
                                                dontReloadFlag = false;
                                              }
                                              return Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 16.w, right: 8.w),
                                                    child: _buildLegend(
                                                        isMobile(context)),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        SizedBox(
                                                          height: 25.h,
                                                          child: Align(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            child: FittedBox(
                                                              fit: BoxFit
                                                                  .fitHeight,
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 15
                                                                            .h),
                                                                child: Text(
                                                                  // "Tüm denemelerdeki ${(headersLabel ?? "total").toLowerCase()} puanları",
                                                                  "Net Grafiği",
                                                                  style:
                                                                      myThightStyle(
                                                                    color:
                                                                        mySecondaryTextColor,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        ShaderMask(
                                                          shaderCallback:
                                                              (bounds) =>
                                                                  LinearGradient(
                                                            begin: Alignment
                                                                .centerLeft,
                                                            end: Alignment
                                                                .centerRight,
                                                            colors: [
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.35),
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.7),
                                                              Colors.white
                                                                  .withOpacity(
                                                                      1),
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.7),
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.35),
                                                            ],
                                                            stops: const [
                                                              0.0,
                                                              0.05,
                                                              0.5,
                                                              0.95,
                                                              1
                                                            ],
                                                          ).createShader(
                                                                      bounds),
                                                          child:
                                                              SingleChildScrollView(
                                                            physics:
                                                                const BouncingScrollPhysics(),
                                                            padding: isMobile(
                                                                    context)
                                                                ? EdgeInsetsDirectional
                                                                    .only(
                                                                        start: 50
                                                                            .w,
                                                                        end: 75
                                                                            .w,
                                                                        top: 5,
                                                                        bottom:
                                                                            18)
                                                                : EdgeInsetsDirectional
                                                                    .only(
                                                                        start:
                                                                            5.w,
                                                                        end: 25
                                                                            .w,
                                                                        top: 0,
                                                                        bottom:
                                                                            18),
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                top: 5.h,
                                                              ),
                                                              child: SizedBox(
                                                                width: chartWidthCalculator(
                                                                    scoresData
                                                                        .length),
                                                                height: 90.h,
                                                                child:
                                                                    ScoreChart(
                                                                  scores:
                                                                      scoresData,
                                                                  scores2:
                                                                      scoresData2,
                                                                ),
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
                                              return const Center(
                                                  child: Text(
                                                      'Player not found.'));
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

                                      // SingleLine Chart (Puan)
                                      Container(
                                        width: thirdColumnWidth,
                                        height: singleLineChartHeight,
                                        decoration: buildBorderDecoration(),
                                        child: FutureBuilder(
                                          future: scoresFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            } else if (snapshot.hasError) {
                                              return Center(
                                                  child: Text(
                                                      'Error: ${snapshot.error}'));
                                            } else if (snapshot.hasData) {
                                              final scoresData =
                                                  snapshot.data as List<Score>;
                                              return Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 12.w, right: 8.w),
                                                    child: SizedBox(
                                                      width:
                                                          thirdColumnWidth / 6,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          SizedBox(
                                                            height: 40.h,
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: FittedBox(
                                                                child: Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          top: 0
                                                                              .h),
                                                                  child: Text(
                                                                    "Puan hesaplanırken soruların\nzorluğu da değerlendirilir.",
                                                                    style:
                                                                        myThightStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          mySecondaryTextColor,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width:
                                                                thirdColumnWidth /
                                                                    7,
                                                            decoration: const BoxDecoration(
                                                                border: BorderDirectional(
                                                                    bottom: BorderSide(
                                                                        color:
                                                                            myAccentColor))),
                                                            child: Center(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  SizedBox(
                                                                    width: 8.w,
                                                                    child:
                                                                        FittedBox(
                                                                      child:
                                                                          Text(
                                                                        "4.8",
                                                                        style: myDigitalStyle(
                                                                            color:
                                                                                mySecondaryTextColor,
                                                                            fontSize:
                                                                                32),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 1.w,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 6.w,
                                                                    child:
                                                                        const FittedBox(
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .upgrade_outlined,
                                                                        color:
                                                                            myAccentColor,
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
                                                              "Ortalama artış miktarı",
                                                              style:
                                                                  myThightStyle(
                                                                color:
                                                                    mySecondaryTextColor,
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
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            child: FittedBox(
                                                              fit: BoxFit
                                                                  .fitHeight,
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 15
                                                                            .h),
                                                                child: Text(
                                                                  // "Tüm denemelerdeki ${(headersLabel ?? "total").toLowerCase()} puanları",
                                                                  "Puan Grafiği",
                                                                  style:
                                                                      myThightStyle(
                                                                    color:
                                                                        mySecondaryTextColor,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        ShaderMask(
                                                          shaderCallback:
                                                              (bounds) =>
                                                                  LinearGradient(
                                                            begin: Alignment
                                                                .centerLeft,
                                                            end: Alignment
                                                                .centerRight,
                                                            colors: [
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.35),
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.7),
                                                              Colors.white
                                                                  .withOpacity(
                                                                      1),
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.7),
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.35),
                                                            ],
                                                            stops: const [
                                                              0.0,
                                                              0.05,
                                                              0.5,
                                                              0.95,
                                                              1
                                                            ],
                                                          ).createShader(
                                                                      bounds),
                                                          child:
                                                              SingleChildScrollView(
                                                            physics:
                                                                const BouncingScrollPhysics(),
                                                            padding: isMobile(
                                                                    context)
                                                                ? EdgeInsetsDirectional
                                                                    .only(
                                                                        start: 50
                                                                            .w,
                                                                        end: 75
                                                                            .w,
                                                                        top: 5,
                                                                        bottom:
                                                                            18)
                                                                : EdgeInsetsDirectional
                                                                    .only(
                                                                        start:
                                                                            5.w,
                                                                        end: 25
                                                                            .w,
                                                                        top: 0,
                                                                        bottom:
                                                                            18),
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                top: 5.h,
                                                              ),
                                                              child: SizedBox(
                                                                width: chartWidthCalculator(
                                                                    scoresData
                                                                        .length),
                                                                height: 90.h,
                                                                child: ScoreChart(
                                                                    scores:
                                                                        scoresData),
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
                                              return const Center(
                                                  child: Text(
                                                      'Player not found.'));
                                            }
                                          },
                                        ),
                                      ),
                                      buildVerticalSpacer(),

                                      // MultiLine Chart
                                      Container(
                                        width: thirdColumnWidth,
                                        height: multiLineHeight,
                                        decoration: buildBorderDecoration(),
                                        child: FutureBuilder(
                                          future: multiScoresFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            } else if (snapshot.hasError) {
                                              return Center(
                                                  child: Text(
                                                      'Error: ${snapshot.error}'));
                                            } else if (snapshot.hasData) {
                                              final multiScoresData =
                                                  snapshot.data;

                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20,
                                                    top: 50,
                                                    bottom: 50,
                                                    right: 20),
                                                child: FittedBox(
                                                  child: MultiLineScoreChart(
                                                    showTags: true,
                                                    scoreMap: multiScoresData!,
                                                    callbackFunct:
                                                        _updateHeaderFromMultiLine,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return const Center(
                                                  child: Text(
                                                      'Player not found.'));
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

                                      // SingleLine Chart
                                      Container(
                                        width: thirdColumnWidth,
                                        height: singleLineChartHeight,
                                        decoration: buildBorderDecoration(),
                                        child: FutureBuilder(
                                          future: scoresFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            } else if (snapshot.hasError) {
                                              return Center(
                                                  child: Text(
                                                      'Error: ${snapshot.error}'));
                                            } else if (snapshot.hasData) {
                                              final scoresData =
                                                  snapshot.data as List<Score>;
                                              return Column(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(
                                                          // height: 25.h,
                                                          child: Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: FittedBox(
                                                              fit: BoxFit
                                                                  .fitHeight,
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 15
                                                                            .h),
                                                                child: Text(
                                                                  // ${(headersLabel ?? "total").toLowerCase()} kaldırdım.
                                                                  "Sıralama Grafiği",
                                                                  style:
                                                                      myThightStyle(
                                                                    color:
                                                                        mySecondaryTextColor,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        ShaderMask(
                                                          shaderCallback:
                                                              (bounds) =>
                                                                  LinearGradient(
                                                            begin: Alignment
                                                                .centerLeft,
                                                            end: Alignment
                                                                .centerRight,
                                                            colors: [
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.35),
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.7),
                                                              Colors.white
                                                                  .withOpacity(
                                                                      1),
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.7),
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.35),
                                                            ],
                                                            stops: const [
                                                              0.0,
                                                              0.05,
                                                              0.5,
                                                              0.95,
                                                              1
                                                            ],
                                                          ).createShader(
                                                                      bounds),
                                                          child:
                                                              SingleChildScrollView(
                                                            physics:
                                                                const BouncingScrollPhysics(),
                                                            padding: isMobile(
                                                                    context)
                                                                ? EdgeInsetsDirectional
                                                                    .only(
                                                                        start: 50
                                                                            .w,
                                                                        end: 50
                                                                            .w,
                                                                        top: 5,
                                                                        bottom:
                                                                            18)
                                                                : EdgeInsetsDirectional
                                                                    .only(
                                                                        start:
                                                                            5.w,
                                                                        end: 25
                                                                            .w,
                                                                        top: 0,
                                                                        bottom:
                                                                            18),
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                top: 5.h,
                                                              ),
                                                              child: SizedBox(
                                                                width: chartWidthCalculator(
                                                                    scoresData
                                                                        .length),
                                                                height: 80.h,
                                                                child: ScoreChart(
                                                                    decrease:
                                                                        true,
                                                                    scores:
                                                                        scoresData),
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
                                              return const Center(
                                                  child: Text(
                                                      'Player not found.'));
                                            }
                                          },
                                        ),
                                      ),
                                      buildVerticalSpacer(),

                                      // MultiLine Chart
                                      Container(
                                        width: thirdColumnWidth,
                                        height: multiLineHeight,
                                        decoration: buildBorderDecoration(),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              // height: 25.h,
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    top: 40.h,
                                                  ),
                                                  child: FittedBox(
                                                    child: Text(
                                                      // "Tüm denemelerdeki ${(headersLabel ?? "total").toLowerCase()} netleri ve diğer öğrencilerin net ortalaması",
                                                      "Zorluk Grafiği",
                                                      style: myThightStyle(
                                                        color:
                                                            mySecondaryTextColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            FutureBuilder(
                                              future: multiScoresFuture,
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Center(
                                                      child:
                                                          CircularProgressIndicator());
                                                } else if (snapshot.hasError) {
                                                  return Center(
                                                      child: Text(
                                                          'Error: ${snapshot.error}'));
                                                } else if (snapshot.hasData) {
                                                  final multiScoresData =
                                                      snapshot.data;

                                                  return SizedBox(
                                                    height:
                                                        multiLineHeight * 0.8,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10.w,
                                                          top: 10.h,
                                                          bottom: 10.h,
                                                          right: 10.w),
                                                      child: FittedBox(
                                                        // fit: BoxFit.fitHeight,
                                                        child:
                                                            DifficultyMultiChart(
                                                          // düzgün çalışmıyor
                                                          showTags: true,
                                                          showNegative: true,
                                                          scoreMap: {
                                                            "Doğru": [
                                                              Score(
                                                                  name: "name",
                                                                  discipleID: 8,
                                                                  skillID: 2,
                                                                  score: 99),
                                                              Score(
                                                                  name: "name",
                                                                  discipleID: 8,
                                                                  skillID: 2,
                                                                  score: 69),
                                                              Score(
                                                                  name: "name",
                                                                  discipleID: 8,
                                                                  skillID: 2,
                                                                  score: 79),
                                                              Score(
                                                                  name: "name",
                                                                  discipleID: 8,
                                                                  skillID: 2,
                                                                  score: 29),
                                                            ],
                                                            "Yanlış": [
                                                              Score(
                                                                  name: "name",
                                                                  discipleID: 8,
                                                                  skillID: 2,
                                                                  score: 59),
                                                              Score(
                                                                  name: "name",
                                                                  discipleID: 8,
                                                                  skillID: 2,
                                                                  score: 39),
                                                              Score(
                                                                  name: "name",
                                                                  discipleID: 8,
                                                                  skillID: 2,
                                                                  score: 19),
                                                              Score(
                                                                  name: "name",
                                                                  discipleID: 8,
                                                                  skillID: 2,
                                                                  score: 29),
                                                            ],
                                                            "Boş": [
                                                              Score(
                                                                  name: "name",
                                                                  discipleID: 8,
                                                                  skillID: 2,
                                                                  score: 59),
                                                              Score(
                                                                  name: "name",
                                                                  discipleID: 8,
                                                                  skillID: 2,
                                                                  score: 69),
                                                              Score(
                                                                  name: "name",
                                                                  discipleID: 8,
                                                                  skillID: 2,
                                                                  score: 12),
                                                              Score(
                                                                  name: "name",
                                                                  discipleID: 8,
                                                                  skillID: 2,
                                                                  score: 79),
                                                              Score(
                                                                  name: "name",
                                                                  discipleID: 8,
                                                                  skillID: 2,
                                                                  score: 59),
                                                              Score(
                                                                  name: "name",
                                                                  discipleID: 8,
                                                                  skillID: 2,
                                                                  score: 69),
                                                              Score(
                                                                  name: "name",
                                                                  discipleID: 8,
                                                                  skillID: 2,
                                                                  score: 12),
                                                              Score(
                                                                  name: "name",
                                                                  discipleID: 8,
                                                                  skillID: 2,
                                                                  score: 79),
                                                              Score(
                                                                  name: "name",
                                                                  discipleID: 8,
                                                                  skillID: 2,
                                                                  score: 59),
                                                              Score(
                                                                  name: "name",
                                                                  discipleID: 8,
                                                                  skillID: 2,
                                                                  score: 69),
                                                            ],
                                                            "Zorluk": [
                                                              Score(
                                                                  name: "name",
                                                                  discipleID: 8,
                                                                  skillID: 2,
                                                                  score: 32),
                                                              Score(
                                                                  name: "name",
                                                                  discipleID: 8,
                                                                  skillID: 2,
                                                                  score: 69),
                                                              Score(
                                                                  name: "name",
                                                                  discipleID: 8,
                                                                  skillID: 2,
                                                                  score: 12),
                                                              Score(
                                                                  name: "name",
                                                                  discipleID: 8,
                                                                  skillID: 2,
                                                                  score: -15),
                                                            ],
                                                          },
                                                          callbackFunct:
                                                              _updateHeaderFromMultiLine,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return const Center(
                                                      child: Text(
                                                          'Player not found.'));
                                                }
                                              },
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  List<Score> randomizeScores(List<Score> scores) {
    // if (dontReloadFlag) return scores;
    Random random = Random();
    return scores.map((score) {
      int variation =
          random.nextInt(20) - random.nextInt(40); // -5 ile +5 arasında değişim
      return score.copyWith(score: (score.score + variation).clamp(0, 99));
    }).toList();
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
            radius: isMobile(context) ? 45 : 150.h,
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

class LightPainter extends CustomPainter {
  final Offset position;

  LightPainter(this.position);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = RadialGradient(
        colors: [
          myAccentColor.withOpacity(0.2), // Orta kısım parlak
          Colors.transparent, // Dışa doğru kaybolan ışık
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: position, radius: 280));

    canvas.drawCircle(position, 280, paint);
  }

  @override
  bool shouldRepaint(covariant LightPainter oldDelegate) {
    return oldDelegate.position != position;
  }
}

Widget _buildLegend(bool isMobile) {
  return Wrap(
    alignment: WrapAlignment.center,
    spacing: 20,
    runSpacing: 55,
    children: List.generate(1, (index) {
      return GestureDetector(
        onTapUp: (details) {
          // widget.callbackFunct(
          //   clickedSkillId: lastIdsofEachSubjectList[index],
          //   clickedSkillStat: lastValuesofEachSubjectList[index],
          //   clickedSkillName: skillNames[index],
          // );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 3,
              color: Colors.red,
            ),
            const SizedBox(width: 5),
            Text(
              isMobile
                  ? "Diğer öğrencilerin net ortalaması"
                  : "Diğer öğrencilerin \n net ortalaması",
              style: myThightStyle(color: mySecondaryTextColor, fontSize: 9),
            ),
          ],
        ),
      );
    }),
  );
}

class CustomPageScrollPhysics extends PageScrollPhysics {
  final double pageSize; // Custom scroll distance per swipe

  const CustomPageScrollPhysics({
    required this.pageSize,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  CustomPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageScrollPhysics(
      pageSize: pageSize,
      parent: buildParent(ancestor),
    );
  }

  double _getPage(ScrollMetrics position) {
    return position.pixels / pageSize;
  }

  double _getPixels(ScrollMetrics position, double page) {
    return page * pageSize;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final Tolerance tolerance = toleranceFor(position);
    final double targetPage =
        (_getPage(position) + velocity.sign).roundToDouble();
    final double targetPixels = _getPixels(position, targetPage);

    return ScrollSpringSimulation(
      spring,
      position.pixels,
      targetPixels,
      velocity,
      tolerance: tolerance,
    );
  }
}

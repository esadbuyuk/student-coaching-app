import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../controller/disciple_list_controller.dart';
import '../../controller/string_operations.dart';
import '../../controller/trainer_controller.dart';
import '../../controller/ui_controller.dart';
import '../../model/disciple.dart';
import '../../model/my_constants.dart';
import '../../model/trainer.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/widget_decorations.dart';
import 'home_page.dart';

class ScoreListPage extends StatefulWidget {
  const ScoreListPage({Key? key}) : super(key: key);

  @override
  State<ScoreListPage> createState() => _ScoreListPageState();
}

class _ScoreListPageState extends State<ScoreListPage> {
  final DiscipleListController _playerListController = DiscipleListController();
  late Future<List<int>> futurePrivateIDs;
  late Future<List<Disciple>?> futurePlayerList;
  late TrainerController _trainerController = TrainerController();
  late Future<Trainer> trainerFuture;
  File? imageFile;
  ScrollController scrollController = ScrollController();
  List<bool> isHoveredList = [];
  String? selectedStudentName;
  double? turkceNet;
  double? matematikNet;
  double? sosyalNet;
  double? fizikNet;
  double? biyolojiNet;
  double? kimyaNet;

  @override
  void initState() {
    super.initState();
    futurePlayerList =
        futurePlayerList = _playerListController.fetchDiscipleListData();
    _trainerController = TrainerController();
    trainerFuture = _trainerController.fetchTrainerData();

    isHoveredList = List.generate(500, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    double boxWidths = isMobile(context) ? 100.w : 25.w;
    return SafeArea(
      child: Scaffold(
        appBar: buildAppBar(
          context,
          false,
        ),
        // resizeToAvoidBottomInset: false,
        body: FutureBuilder(
          future: futurePlayerList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final List<Disciple>? playerListData =
                  snapshot.data! as List<Disciple>?;

              // List<bool> isHoveredList =
              //     List.generate(playerListData!.length, (index) => false);

              return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      height: selectedStudentName != null ? 15.h : 25.h,
                    ),
                    if (selectedStudentName != null)
                      Row(
                        children: [
                          const Expanded(child: SizedBox()),
                          ScoreTableWidget(),
                          const Expanded(child: SizedBox()),
                          Padding(
                            padding: EdgeInsets.only(bottom: 20.h),
                            child: SizedBox(
                              height: isMobile(context) ? 123.h : 103.h,
                              // width: isMobile(context) ? 900 : 240,
                              child: const ButtonCard(
                                  title: "ANALİZE GİT",
                                  icon: Icons.bar_chart_outlined,
                                  destinationPage: "/lastTestResults"),
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    if (selectedStudentName == null)
                      Image(
                        width: 130.h,
                        height: 130.h,
                        image: AssetImage("assets/icons/KAIHL_LOGO_YAZILI.png"),
                      ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Container(
                      height: 20.h,
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: FittedBox(
                        child: Text(
                          "DENEME 3 (BİLGİ SARMAL YAYINLARI)",
                          style: myTonicStyle(mySecondaryTextColor),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 10.w, right: 10.w, bottom: 10.h, top: 10.h),
                      child: Container(
                        decoration: buildBorderDecoration(),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 20.w, right: 20.w, bottom: 0.h, top: 15.h),
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  bottom: 5.h,
                                ),
                                decoration: buildBorderDecoration(),
                                height: 40.h,
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(left: 20.w, right: 10.w),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 75.w,
                                        child: Text(
                                          style: myTonicStyle(
                                              mySecondaryTextColor),
                                          "İSİM",
                                        ),
                                      ),
                                      if (!isMobile(context))
                                        buildHeaderBox(boxWidths, "TÜRKÇE"),
                                      if (!isMobile(context))
                                        buildHeaderBox(boxWidths, "MATEMATİK"),
                                      if (!isMobile(context))
                                        buildHeaderBox(boxWidths, "FİZİK"),
                                      if (!isMobile(context))
                                        buildHeaderBox(boxWidths, "BİYOLOJİ"),
                                      if (!isMobile(context))
                                        buildHeaderBox(boxWidths, "KİMYA"),
                                      if (!isMobile(context))
                                        buildHeaderBox(boxWidths, "SOSYAL"),
                                      const Expanded(
                                        child: SizedBox(),
                                      ),
                                      buildHeaderBox(boxWidths, "TOTAL"),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: isMobile(context)
                                    ? selectedStudentName == null
                                        ? 370.h
                                        : 360.h
                                    : selectedStudentName == null
                                        ? 370.h
                                        : 320.h,
                                width: double.maxFinite,
                                child: Scrollbar(
                                  thumbVisibility: true,
                                  interactive: true,
                                  controller: scrollController,
                                  child: ListView.builder(
                                    controller: scrollController,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: playerListData!.length,
                                    padding: EdgeInsets.only(
                                        top: 60.h, bottom: 180.h),
                                    itemBuilder: (context, playerNo) {
                                      return MouseRegion(
                                        onEnter: (_) => setState(() =>
                                            isHoveredList[playerNo] = true),
                                        onExit: (_) => setState(() =>
                                            isHoveredList[playerNo] = false),
                                        child: GestureDetector(
                                          onTap: () {
                                            if (!isMobile(context)) {
                                              context.go('/lastTestResults');
                                            }
                                            setState(() {
                                              ScoreTableWidget.studentName =
                                                  playerListData[playerNo]
                                                          .name +
                                                      " " +
                                                      playerListData[playerNo]
                                                          .surname;
                                              selectedStudentName =
                                                  ScoreTableWidget.studentName;
                                            });
                                            matematikNet =
                                                ScoreTableWidget.subjectScores[
                                                        "Matematik"] ??
                                                    0.0;
                                            turkceNet = ScoreTableWidget
                                                    .subjectScores["Türkçe"] ??
                                                0.0;
                                            sosyalNet = ScoreTableWidget
                                                    .subjectScores["Sosyal"] ??
                                                0.0;
                                            fizikNet = ScoreTableWidget
                                                    .subjectScores["Fizik"] ??
                                                0.0;
                                            biyolojiNet =
                                                ScoreTableWidget.subjectScores[
                                                        "Biyoloji"] ??
                                                    0.0;
                                            kimyaNet = ScoreTableWidget
                                                    .subjectScores["Kimya"] ??
                                                0.0;
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(
                                              bottom: 5.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isHoveredList[playerNo]
                                                  ? myBackgroundColor
                                                  : myPrimaryColor,
                                              border: Border.all(
                                                  color: mySecondaryColor),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(11.r),
                                              ),
                                            ),
                                            height: 40.h,
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 20.w, right: 10.w),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: isMobile(context)
                                                        ? 135.w
                                                        : 75.w,
                                                    child: Text(
                                                      maxLines: 1,
                                                      style: myTonicStyle(
                                                        isHoveredList[playerNo]
                                                            ? mySecondaryTextColor
                                                            : myTextColor,
                                                      ),
                                                      "${playerNo + 1}. ${isMobile(context) ? getTruncateName(playerListData[playerNo].name, maxLength: 9) : getTruncateNameSurname(playerListData[playerNo].name, playerListData[playerNo].surname)}",
                                                    ),
                                                  ),
                                                  if (!isMobile(context))
                                                    SizedBox(
                                                      width: boxWidths,
                                                      child: Center(
                                                        child: Text(
                                                          style: myTonicStyle(
                                                            isHoveredList[
                                                                    playerNo]
                                                                ? mySecondaryTextColor
                                                                : myTextColor,
                                                          ),
                                                          (playerListData[playerNo]
                                                                      .overall ??
                                                                  "-")
                                                              .toString(),
                                                        ),
                                                      ),
                                                    ),
                                                  if (!isMobile(context))
                                                    SizedBox(
                                                      width: boxWidths,
                                                      child: Center(
                                                        child: Text(
                                                          style: myTonicStyle(
                                                            isHoveredList[
                                                                    playerNo]
                                                                ? mySecondaryTextColor
                                                                : myTextColor,
                                                          ),
                                                          (playerListData[playerNo]
                                                                      .overall ??
                                                                  "-")
                                                              .toString(),
                                                        ),
                                                      ),
                                                    ),
                                                  if (!isMobile(context))
                                                    SizedBox(
                                                      width: boxWidths,
                                                      child: Center(
                                                        child: Text(
                                                          style: myTonicStyle(
                                                            isHoveredList[
                                                                    playerNo]
                                                                ? mySecondaryTextColor
                                                                : myTextColor,
                                                          ),
                                                          (playerListData[playerNo]
                                                                      .overall ??
                                                                  "-")
                                                              .toString(),
                                                        ),
                                                      ),
                                                    ),
                                                  if (!isMobile(context))
                                                    SizedBox(
                                                      width: boxWidths,
                                                      child: Center(
                                                        child: Text(
                                                          style: myTonicStyle(
                                                            isHoveredList[
                                                                    playerNo]
                                                                ? mySecondaryTextColor
                                                                : myTextColor,
                                                          ),
                                                          (playerListData[playerNo]
                                                                      .overall ??
                                                                  "-")
                                                              .toString(),
                                                        ),
                                                      ),
                                                    ),
                                                  if (!isMobile(context))
                                                    SizedBox(
                                                      width: boxWidths,
                                                      child: Center(
                                                        child: Text(
                                                          style: myTonicStyle(
                                                            isHoveredList[
                                                                    playerNo]
                                                                ? mySecondaryTextColor
                                                                : myTextColor,
                                                          ),
                                                          (playerListData[playerNo]
                                                                      .overall ??
                                                                  "-")
                                                              .toString(),
                                                        ),
                                                      ),
                                                    ),
                                                  if (!isMobile(context))
                                                    SizedBox(
                                                      width: boxWidths,
                                                      child: Center(
                                                        child: Text(
                                                          style: myTonicStyle(
                                                            isHoveredList[
                                                                    playerNo]
                                                                ? mySecondaryTextColor
                                                                : myTextColor,
                                                          ),
                                                          (playerListData[playerNo]
                                                                      .overall ??
                                                                  "-")
                                                              .toString(),
                                                        ),
                                                      ),
                                                    ),
                                                  const Expanded(
                                                    child: SizedBox(),
                                                  ),
                                                  SizedBox(
                                                    width: boxWidths,
                                                    child: Center(
                                                      child: Text(
                                                        style: myTonicStyle(
                                                          isHoveredList[
                                                                  playerNo]
                                                              ? mySecondaryTextColor
                                                              : myTextColor,
                                                        ),
                                                        (playerListData[playerNo]
                                                                    .overall ??
                                                                "-")
                                                            .toString(),
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
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (selectedStudentName == null)
                      Padding(
                        padding:
                            EdgeInsets.only(left: 0.w, right: 10.w, top: 10.h),
                        child: SizedBox(
                          height: 20.h,
                          child: Center(
                            child: FittedBox(
                              child: Text(
                                "Denemenin detaylı analizi için bir öğrenci seçin.",
                                style: myThightStyle(
                                  color: mySecondaryTextColor,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ]);
            }
          },
        ),
      ),
    );
  }

  SizedBox buildHeaderBox(double boxWidths, String text) {
    return SizedBox(
      width: boxWidths,
      child: Center(
        child: Text(
          style: myTonicStyle(mySecondaryTextColor),
          text,
        ),
      ),
    );
  }
}

class ScoreTableWidget extends StatelessWidget {
  static String studentName = "Ali Desidero";
  static Map<String, double> subjectScores = {
    "Matematik": 32.5,
    "Türkçe": 30.0,
    "Fizik": 25.0,
    "Kimya": 27.75,
    "Biyoloji": 30.0,
    "Sosyal": 30.0,
  };

  ScoreTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        //decoration: buildBorderDecoration(),
        height: 180.h,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20.h,
              child: FittedBox(
                child: Text(
                  studentName,
                  style: myTonicStyle(myIconsColor),
                ),
              ),
            ),
            const Divider(color: Colors.black),
            Container(
              //height: 130.h,
              decoration: buildBorderDecoration(),
              padding: EdgeInsets.all(8),
              child: Column(
                children: subjectScores.entries.map((entry) {
                  return SizedBox(
                    width: isMobile(context) ? 100.w : 50.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 15.h,
                          child: FittedBox(
                              child: Text(entry.key,
                                  style: myThightStyle(
                                      color: mySecondaryTextColor))),
                        ),
                        const Expanded(child: SizedBox()),
                        SizedBox(
                          height: 15.h,
                          child: FittedBox(
                            child: Text(entry.value.toStringAsFixed(2),
                                style:
                                    myThightStyle(color: mySecondaryTextColor)),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentTable extends StatefulWidget {
  @override
  _StudentTableState createState() => _StudentTableState();
}

class _StudentTableState extends State<StudentTable> {
  // Öğrenci verileri
  List<Map<String, dynamic>> students = [
    {
      'name': 'Ahmet Yılmaz',
      'matematik': 30,
      'türkçe': 25,
      'sosyal': 20,
      'fizik': 15,
      'kimya': 18,
      'biyoloji': 22,
    },
    {
      'name': 'Elif Demir',
      'matematik': 28,
      'türkçe': 30,
      'sosyal': 25,
      'fizik': 20,
      'kimya': 24,
      'biyoloji': 26,
    },
    {
      'name': 'Mert Kaya',
      'matematik': 18,
      'türkçe': 20,
      'sosyal': 22,
      'fizik': 12,
      'kimya': 15,
      'biyoloji': 19,
    },
  ];
  void addRandomStudentData() {
    List<String> firstNames = [
      'Ali',
      'Ayşe',
      'Fatma',
      'Mehmet',
      'Can',
      'Ece',
      'Burak',
      'Zehra',
      'Selim',
      'Derya',
      'Osman',
      'Leyla',
      'Furkan',
      'Aslı',
      'Emre',
      'Zeynep',
      'Deniz',
      'Seda',
      'Kerem',
      'Pelin',
      'Cem',
      'Gül',
      'Hüseyin',
      'Sema'
    ];

    List<String> lastNames = [
      'Çelik',
      'Kaya',
      'Şahin',
      'Demir',
      'Yılmaz',
      'Aydın',
      'Arslan',
      'Eren',
      'Koç',
      'Bozkurt',
      'Taş',
      'Yavuz',
      'Korkmaz',
      'Polat',
      'Özkan',
      'Karaca'
    ];

    Random random = Random();

    while (students.length < 50) {
      String name = "${firstNames[random.nextInt(firstNames.length)]} "
          "${lastNames[random.nextInt(lastNames.length)]}";

      Map<String, dynamic> student = {
        'name': name,
        'matematik': random.nextInt(31), // 0-30 arası puan
        'türkçe': random.nextInt(31),
        'sosyal': random.nextInt(31),
        'fizik': random.nextInt(31),
        'kimya': random.nextInt(31),
        'biyoloji': random.nextInt(31),
      };

      students.add(student);
    }

    // for (var student in students) {
    //   print(student);
    // }
  }

  // Sıralama değişkenleri
  bool sortAscending = true;
  String sortColumn = 'name';

  @override
  Widget build(BuildContext context) {
    addRandomStudentData();
    // Toplam net hesaplama
    for (var student in students) {
      student['total'] = student['matematik'] +
          student['türkçe'] +
          student['sosyal'] +
          student['fizik'] +
          student['kimya'] +
          student['biyoloji'];
    }

    // Öğrencileri sıralama
    students.sort((a, b) {
      if (sortAscending) {
        return a[sortColumn].compareTo(b[sortColumn]);
      } else {
        return b[sortColumn].compareTo(a[sortColumn]);
      }
    });
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
          iconTheme: theme.iconTheme.copyWith(color: myIconsColor)),
      child: DataTableTheme(
        data: DataTableThemeData(
          // headingRowColor:
          //     WidgetStateColor.resolveWith((states) => Colors.blueGrey[800]!),
          headingTextStyle: myTonicStyle(myIconsColor),
          dataRowColor:
              WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
            return states.contains(WidgetState.selected)
                ? Colors.blueGrey[300]!
                : Colors.white12;
          }),
          decoration: buildBorderDecoration(),
          dataTextStyle: myTonicStyle(mySecondaryTextColor),
          dividerThickness: 1.5,
        ),
        child: Column(
          children: [
            DataTable(
              columnSpacing: 70,
              border: TableBorder.all(color: Colors.transparent),
              // decoration: buildBorderDecoration(),
              sortAscending: sortAscending,
              sortColumnIndex: _getColumnIndex(sortColumn),
              // decoration: buildBorderDecoration(),
              columns: [
                DataColumn(
                  label: const Text('İSİM'),
                  onSort: (index, ascending) {
                    setState(() {
                      sortColumn = 'name';
                      sortAscending = ascending;
                    });
                  },
                ),
                _buildDataColumn('MATEMATİK', 'matematik'),
                _buildDataColumn('TÜRKÇE', 'türkçe'),
                _buildDataColumn('SOSYAL', 'sosyal'),
                _buildDataColumn('FİZİK', 'fizik'),
                _buildDataColumn('KİMYA', 'kimya'),
                _buildDataColumn('BİYOLOJİ', 'biyoloji'),
                _buildDataColumn('TOTAL', 'total'),
              ],
              rows: [],
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: 70,
                  sortAscending: sortAscending,
                  sortColumnIndex: _getColumnIndex(sortColumn),
                  columns: [
                    DataColumn(
                      label: Text(
                        'İSİM',
                        style: myTonicStyle(Colors.transparent),
                      ),
                      onSort: (index, ascending) {
                        setState(() {
                          sortColumn = 'name';
                          sortAscending = ascending;
                        });
                      },
                    ),
                    _buildTransparentDataColumn('MA', 'matematik'),
                    _buildTransparentDataColumn('TÜ', 'türkçe'),
                    _buildTransparentDataColumn('SO', 'sosyal'),
                    _buildTransparentDataColumn('Fİ', 'fizik'),
                    _buildTransparentDataColumn('Kİ', 'kimya'),
                    _buildTransparentDataColumn('Bİ', 'biyoloji'),
                    _buildTransparentDataColumn('TO', 'total'),
                  ],
                  rows: students
                      .map(
                        (student) => DataRow(
                          cells: [
                            DataCell(Text(student['name'])),
                            DataCell(Text(student['matematik'].toString())),
                            DataCell(Text(student['türkçe'].toString())),
                            DataCell(Text(student['sosyal'].toString())),
                            DataCell(Text(student['fizik'].toString())),
                            DataCell(Text(student['kimya'].toString())),
                            DataCell(Text(student['biyoloji'].toString())),
                            DataCell(Text(student['total'].toString())),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataColumn _buildDataColumn(String label, String key) {
    return DataColumn(
      label: Container(child: Text(label)),
      onSort: (index, ascending) {
        setState(() {
          sortColumn = key;
          sortAscending = ascending;
        });
      },
    );
  }

  DataColumn _buildTransparentDataColumn(String label, String key) {
    return DataColumn(
      label: Container(
          child: Text(
        label,
        style: myTonicStyle(Colors.transparent),
      )),
      onSort: (index, ascending) {
        setState(() {
          sortColumn = key;
          sortAscending = ascending;
        });
      },
    );
  }

  int _getColumnIndex(String column) {
    switch (column) {
      case 'name':
        return 0;
      case 'matematik':
        return 1;
      case 'türkçe':
        return 2;
      case 'sosyal':
        return 3;
      case 'fizik':
        return 4;
      case 'kimya':
        return 5;
      case 'biyoloji':
        return 6;
      case 'total':
        return 7;
      default:
        return 0;
    }
  }
}

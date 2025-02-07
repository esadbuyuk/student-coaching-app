import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pcaweb/controller/ui_controller.dart';

import '../../model/my_constants.dart';
import '../../model/score.dart';

class DeepLineChart extends StatefulWidget {
  final Map<String, List<Score>> scoreMap;
  final bool showTags;
  final bool lineChart;
  final Function callbackFunct;

  const DeepLineChart({
    super.key,
    required this.scoreMap,
    this.showTags = true,
    this.lineChart = true,
    required this.callbackFunct,
  });

  @override
  DeepLineChartState createState() => DeepLineChartState();
}

class DeepLineChartState extends State<DeepLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 0), // animasyonu kapattım!
    )..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (var scores in widget.scoreMap.values) {
      scores.sort((a, b) => a.date?.compareTo(b.date ?? DateTime.now()) ?? 0);
    }

    return Column(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              //decoration: buildInsideShadow(),
              child: CustomPaint(
                size: Size(getScreenWidth(context) + 100.w, 300),
                painter: DeepLineCartPainter(
                  widget.scoreMap,
                  widget.showTags,
                  widget.lineChart,
                  _animation.value,
                ),
              ),
            );
          },
        ),
        //SizedBox(height: 80.h),
        // _buildLegend(),
      ],
    );
  }

  Widget _buildLegend() {
// final colors = MultiLineScoreChartPainter.colorMap;
    final colorMap = DeepLineCartPainter.colorMap;
    final skillNames = widget.scoreMap.keys.toList();
// final scoresList = widget.scoreMap.values.toList();
    final lastValuesofEachSubjectList = widget.scoreMap.entries.map((entry) {
      final lastItem = entry.value.last.score; // Her dersin son elemanını al
      return lastItem;
    }).toList();
    final lastIdsofEachSubjectList = widget.scoreMap.entries.map((entry) {
      final lastItem = entry.value.last.skillID; // Her dersin son elemanını al
      return lastItem;
    }).toList();
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      runSpacing: 55,
      children: List.generate(skillNames.length, (index) {
        return GestureDetector(
          onTapUp: (details) {
            widget.callbackFunct(
              clickedSkillId: lastIdsofEachSubjectList[index],
              clickedSkillStat: lastValuesofEachSubjectList[index],
              clickedSkillName: skillNames[index],
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 15,
                height: 15,
                color: DeepLineCartPainter
                    .colorMap[skillNames[index].toLowerCase()],
// color: colors[index % colors.length],
              ),
              const SizedBox(width: 5),
              Text(
                skillNames[index],
                style: myThightStyle(color: mySecondaryTextColor),
              ),
            ],
          ),
        );
      }),
    );
  }
}

double lightOpacity = 0.1;

class DeepLineCartPainter extends CustomPainter {
  final Map<String, List<Score>> scoreMap;
  final bool showTags;
  final bool lineChart;
  final double animationValue;
  bool flagForOnce = false;

  static Map<String, Color> colorMap = {
    "matematik": Colors.blue,
    "türkçe": Colors.red,
    "sosyal": Colors.green,
    "fizik": Colors.orange,
    "kimya": Colors.purple,
    "total": Colors.white,
    "biyoloji": Colors.lime,
  };

  DeepLineCartPainter(
      this.scoreMap, this.showTags, this.lineChart, this.animationValue);

  List<Color> lineColors = colorMap.values.toList();

  static void selectColor(String selectedColorName) {
    if (!colorMap.containsKey(selectedColorName)) {
      // print("Hata: '$selectedColorName' geçerli bir renk adı değil.");
      return;
    }

// Renkleri güncelle
    colorMap.forEach((key, value) {
      colorMap[key] = key == selectedColorName
          ? value.withOpacity(1.0) // Seçilen rengi tam opak yap
          : value.withOpacity(lightOpacity); // Diğer renklerin opaklığını azalt
    });
  }

  static void resetColors() {
    colorMap.forEach((key, value) {
      colorMap[key] = true
          ? value.withOpacity(1.0) // Seçilen rengi tam opak yap
          : value.withOpacity(lightOpacity); // Diğer renklerin opaklığını azalt
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paintBackground = Paint()
      ..color = myDividerColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

// Grid çizimi
    for (double i = 0; i <= 100; i += 20) {
      // for (double i = 0; i <= 100; i += 100) {
      //   canvas.drawLine(
      //     Offset(0, size.height - i * size.height / 100),
      //     Offset(size.width, size.height - i * size.height / 100),
      //     paintBackground,
      //   );
      // }
      // for (double i = 0; i <= 100; i += 20) {
      //   canvas.drawLine(
      //     Offset(i * size.width / 100, 0),
      //     Offset(i * size.width / 100, size.height),
      //     paintBackground,
      //   );
      // }
      if (showTags) {
        TextSpan span = TextSpan(
          style: myDigitalStyle(color: mySecondaryTextColor),
          text: i.toInt().toString(),
        );
        TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.right,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(
            canvas,
            Offset(-tp.width - 5,
                size.height - i * size.height / 100 - tp.height / 2));
      }
    }

    double margin = 0.0;

    int index = 0;
    for (var entry in scoreMap.entries) {
      final skillName = entry.key;
      final scores = entry.value;

      if (scores.isEmpty) continue;

      double columnWidth = (size.width - margin) / (scores.length - 1);
      double columnHeight = size.height / 100;

      List<Color> lineColors = colorMap.values.toList();
      if (!lineChart) {
// Alt kısmı boyama
        Path path2 = Path();
        path2.moveTo(margin, size.height);
        path2.lineTo(margin,
            size.height - scores[0].score * columnHeight * animationValue);
        for (int i = 1; i < scores.length; i++) {
          double x = margin + columnWidth * i;
          double y =
              size.height - scores[i].score * columnHeight * animationValue;
          path2.lineTo(x, y);
        }
        path2.lineTo(size.width, size.height);
        path2.close();
        canvas.drawPath(
          path2,
          Paint()
            ..color = darkMode
                ? myBackgroundColor.withOpacity(0.7 * animationValue)
                : myBackgroundColor.withOpacity(0.7 * animationValue),
        );
        canvas.drawPath(
          path2,
          Paint()..color = Colors.white.withOpacity(0.05 * animationValue),
        );
      }

      Paint paint = Paint()
        ..color = lineColors[index % lineColors.length]
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      Path path = Path();
      path.moveTo(
        margin,
        size.height - scores[0].score * size.height / 100 * animationValue,
      );

      // for (int i = 1; i < scores.length; i++) {
      //   double x = margin + columnWidth * i;
      //   double y =
      //       size.height - scores[i].score * size.height / 100 * animationValue;
      //   path.lineTo(x, y);
      //
      //   // düz çizgiler
      //   // if (showTags && animationValue > 0.9) {
      //   //   TextSpan span = TextSpan(
      //   //     style: myDigitalStyle(color: mySecondaryTextColor),
      //   //     text: scores[i].score.toString(),
      //   //   );
      //   //   TextPainter tp = TextPainter(
      //   //     text: span,
      //   //     textAlign: TextAlign.center,
      //   //     textDirection: TextDirection.ltr,
      //   //   );
      //   //   tp.layout();
      //   //   tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height - 5));
      //   // }
      // }

      // if (lineChart) {
      //   canvas.drawPath(path, paint);
      // }

// eğik çizgileri çiz

      for (int i = 1; i < scores.length; i++) {
        double x = margin + columnWidth * i;
        double y =
            size.height - scores[i].score * size.height / 100 * animationValue;

        double previousX = margin + columnWidth * (i - 1);
        double previousY = size.height -
            scores[i - 1].score * size.height / 100 * animationValue;

// Bezier eğrisi kontrol noktalarını belirleW
        double controlX = (previousX + x) / 2;
        double controlY = previousY;

        path.quadraticBezierTo(controlX, controlY, x, y);
      }

      if (showTags && animationValue > 0.9 && !flagForOnce) {
        flagForOnce = true;
        List<String> months = [
          "Oca",
          "Şub",
          "Mar",
          "Nis",
          "May",
          "Haz",
          "Tem",
          "Ağu",
          "Eyl",
          "Eki",
          "Kas",
          "Ara"
        ];
        for (int i = 0; i < scores.length; i++) {
          double x = margin + columnWidth * i;

// deneme adı gelince buraya scores[i].name gelecek
          String monthName =
              scores[i].date != null ? months[scores[i].date!.month - 1] : "";
          TextSpan span = TextSpan(
            style: myTonicStyle(mySecondaryTextColor, fontSize: 12),
            text: monthName,
          );
          TextPainter tp = TextPainter(
            text: span,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          );
          tp.layout();
          tp.paint(canvas, Offset(x - tp.width / 2, size.height + 5));
        }
      }
      if (lineChart) {
        canvas.drawPath(path, paint);
      }
      index++;
    }
    flagForOnce = false;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

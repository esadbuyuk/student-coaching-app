import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pcaweb/view/widgets/widget_decorations.dart';

import '../../model/my_constants.dart';
import '../../model/score.dart';

class DifficultyMultiChart extends StatefulWidget {
  final Map<String, List<Score>> scoreMap;
  final bool showTags;
  final bool showNegative;
  final Function callbackFunct;

  const DifficultyMultiChart({
    super.key,
    required this.scoreMap,
    this.showTags = true,
    this.showNegative = false,
    required this.callbackFunct,
  });

  @override
  DifficultyMultiChartState createState() => DifficultyMultiChartState();
}

class DifficultyMultiChartState extends State<DifficultyMultiChart>
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
              decoration: buildInsideShadow(),
              child: CustomPaint(
                size: const Size(500, 300),
                painter: DifficultyMultiChartPainter(
                  widget.scoreMap,
                  widget.showTags,
                  widget.showNegative,
                  _animation.value,
                ),
              ),
            );
          },
        ),
        SizedBox(height: 80.h),
        _buildLegend(),
      ],
    );
  }

  Widget _buildLegend() {
    // final colors = MultiLineScoreChartPainter.colorMap;
    final colorMap = DifficultyMultiChartPainter.colorMapForNegative;
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
    // print(lastIdsofEachSubjectList);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      runSpacing: 55,
      children: List.generate(skillNames.length, (index) {
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
                width: 15,
                height: 15,
                color: widget.showNegative
                    ? DifficultyMultiChartPainter
                        .colorMapForNegative[skillNames[index].toLowerCase()]
                    : DifficultyMultiChartPainter
                        .colorMapForNegative[skillNames[index].toLowerCase()],
                // color: colors[index % colors.length],
              ),
              const SizedBox(width: 5),
              Text(
                skillNames[index],
                style: myThightStyle(color: mySecondaryTextColor, fontSize: 12),
              ),
            ],
          ),
        );
      }),
    );
  }
}

double lightOpacity = 1;

class DifficultyMultiChartPainter extends CustomPainter {
  final Map<String, List<Score>> scoreMap;
  final bool showTags;
  final bool showNegative;
  final double animationValue;
  bool flagForOnce = false;

  static Map<String, Color> colorMapForNegative = {
    "doğru": Colors.blue,
    "yanlış": Colors.red,
    "boş": Colors.green,
    "zorluk": Colors.orange,
  };
  DifficultyMultiChartPainter(
      this.scoreMap, this.showTags, this.showNegative, this.animationValue);

  List<Color> lineColors = colorMapForNegative.values.toList();

  static void selectColor(String selectedColorName) {
    if (!colorMapForNegative.containsKey(selectedColorName)) {
      // print("Hata: '$selectedColorName' geçerli bir renk adı değil.");
      return;
    }

    // Renkleri güncelle
    colorMapForNegative.forEach((key, value) {
      colorMapForNegative[key] = key == selectedColorName
          ? value.withOpacity(1.0) // Seçilen rengi tam opak yap
          : value.withOpacity(lightOpacity); // Diğer renklerin opaklığını azalt
    });
  }

  static void resetColors() {
    colorMapForNegative.forEach((key, value) {
      colorMapForNegative[key] = true
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
      for (double i = 0; i <= 100; i += 50) {
        canvas.drawLine(
          Offset(0, size.height - i * size.height / 100),
          Offset(size.width, size.height - i * size.height / 100),
          paintBackground,
        );
      }
      for (double i = 0; i <= 100; i += 100) {
        canvas.drawLine(
          Offset(i * size.width / 100, 0),
          Offset(i * size.width / 100, size.height),
          paintBackground,
        );
      }
      if (showTags && !showNegative) {
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

    double margin = 15.0;
    double columnHeight = size.height / 100;

    // Grid çizimi (-100 ile 100 arası çizgiler)
    if (showNegative) {
      for (double i = -100; i <= 100; i += 20) {
        double y = size.height / 2 - (i * size.height / 200);
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paintBackground);

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
          tp.paint(canvas, Offset(-tp.width - 5, y - tp.height / 2));
        }
      }
    }

    int index = 0;
    for (var entry in scoreMap.entries) {
      final skillName = entry.key;
      final scores = entry.value;

      if (scores.isEmpty) continue;

      double columnWidth = (size.width - margin) / (scores.length - 1);
      List<Color> lineColors = colorMapForNegative.values.toList();

      Paint paint = Paint()
        ..color = lineColors[index % lineColors.length]
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      Path path = Path();
      path.moveTo(
        margin,
        size.height - scores[0].score * size.height / 100 * animationValue,
      );

      for (int i = 1; i < scores.length; i++) {
        double x = margin + columnWidth * i;
        double y =
            size.height - scores[i].score * size.height / 100 * animationValue;
        // path.lineTo(x, y); düz çizgiler

        // if (showTags && animationValue > 0.9) {
        //   TextSpan span = TextSpan(
        //     style: myDigitalStyle(color: mySecondaryTextColor),
        //     text: scores[i].score.toString(),
        //   );
        //   TextPainter tp = TextPainter(
        //     text: span,
        //     textAlign: TextAlign.center,
        //     textDirection: TextDirection.ltr,
        //   );
        //   tp.layout();
        //   tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height - 5));
        // }
      }

      canvas.drawPath(path, paint);

      // eğik çizgileri çiz
      for (int i = 1; i < scores.length; i++) {
        double x = margin + columnWidth * i;
        double y =
            size.height * (1 - (scores[i].score + 100) / 200) * animationValue;

        double previousX = margin + columnWidth * (i - 1);
        double previousY = size.height *
            (1 - (scores[i - 1].score + 100) / 200) *
            animationValue;

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

      canvas.drawPath(path, paint);
      index++;
    }
    flagForOnce = false;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

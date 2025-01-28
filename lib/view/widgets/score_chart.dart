import 'package:flutter/material.dart';
import 'package:pcaweb/view/widgets/widget_decorations.dart';

import '../../model/my_constants.dart';
import '../../model/score.dart';

class ScoreChart extends StatefulWidget {
  final List<Score> scores;
  final bool showTags;

  const ScoreChart({super.key, required this.scores, this.showTags = true});

  @override
  ScoreChartState createState() => ScoreChartState();
}

class ScoreChartState extends State<ScoreChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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
    widget.scores
        .sort((a, b) => a.date?.compareTo(b.date ?? DateTime.now()) ?? 0);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: buildInsideShadow(),
          padding: const EdgeInsets.only(right: 15),
          child: CustomPaint(
            size: const Size(double.infinity, 300),
            painter: ScoreChartPainter(
                widget.scores, widget.showTags, _animation.value),
          ),
        );
      },
    );
  }
}

class ScoreChartPainter extends CustomPainter {
  final List<Score> scores;
  final bool showTags;
  final double animationValue;

  ScoreChartPainter(this.scores, this.showTags, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = myAccentColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    Paint paintBackground = Paint()
      ..color = myDividerColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Kareli arkaplan çizimi
    for (double i = 0; i <= 100; i += 20) {
      // canvas.drawLine(
      //   Offset(0, size.height - i * size.height / 100),
      //   Offset(size.width, size.height - i * size.height / 100),
      //   paintBackground,
      // );
      // canvas.drawLine(
      //   Offset(i * size.width / 100, 0),
      //   Offset(i * size.width / 100, size.height),
      //   paintBackground,
      // );

      // if (showTags) {
      //   // Y ekseni etiketleri
      //   TextSpan span = TextSpan(
      //     style: myDigitalStyle(color: mySecondaryTextColor),
      //     text: i.toInt().toString(),
      //   );
      //   TextPainter tp = TextPainter(
      //     text: span,
      //     textAlign: TextAlign.right,
      //     textDirection: TextDirection.ltr,
      //   );
      //   tp.layout();
      //   tp.paint(
      //       canvas,
      //       Offset(-tp.width - 5,
      //           size.height - i * size.height / 100 - tp.height / 2));
      // }
    }

    if (scores.isEmpty) return;

    double margin = 15.0;
    double columnWidth = (size.width - margin) / (scores.length - 1);
    double columnHeight = size.height / 100;

    Path path = Path();
    path.moveTo(
        margin, size.height - scores[0].score * columnHeight * animationValue);

    for (int i = 1; i < scores.length; i++) {
      double x = margin + columnWidth * i;
      double y = size.height - scores[i].score * columnHeight * animationValue;
      path.lineTo(x, y);

      if (showTags && animationValue > 0.9) {
        // Etiketler, animasyon sonunda gösteriliyor
        TextSpan span = TextSpan(
          style: myDigitalStyle(color: mySecondaryTextColor, fontSize: 10),
          text: scores[i].score.toString(),
        );
        TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height - 5));
      }
    }

    // Alt kısmı boyama
    Path path2 = Path();
    path2.moveTo(margin, size.height);
    path2.lineTo(
        margin, size.height - scores[0].score * columnHeight * animationValue);
    for (int i = 1; i < scores.length; i++) {
      double x = margin + columnWidth * i;
      double y = size.height - scores[i].score * columnHeight * animationValue;
      path2.lineTo(x, y);
    }
    path2.lineTo(size.width, size.height);
    path2.close();
    canvas.drawPath(
      path2,
      Paint()..color = myAccentColor.withOpacity(0.3 * animationValue),
    );

    canvas.drawPath(path, paint);

    if (showTags && animationValue > 0.9) {
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
        String monthName =
            scores[i].date != null ? months[scores[i].date!.month - 1] : "";
        TextSpan span = TextSpan(
          style: myTonicStyle(mySecondaryTextColor, fontSize: 10),
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

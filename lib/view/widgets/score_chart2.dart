import 'package:flutter/material.dart';

import '../../model/my_constants.dart';
import '../../model/score.dart';

class ScoreChart2 extends StatefulWidget {
  final List<Score> scores;
  final bool showTags;

  const ScoreChart2({super.key, required this.scores, this.showTags = true});

  @override
  ScoreChart2State createState() => ScoreChart2State();
}

class ScoreChart2State extends State<ScoreChart2>
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      // Köşe yuvarlama
      child: Container(
        decoration: BoxDecoration(
            color: myBackgroundColor,
            border: Border.all(color: myPrimaryColor),
            borderRadius: BorderRadius.circular(20)),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(double.infinity, 300),
              painter: ScoreChart2Painter(
                  widget.scores, widget.showTags, _animation.value),
            );
          },
        ),
      ),
    );
  }
}

class ScoreChart2Painter extends CustomPainter {
  final List<Score> scores;
  final bool showTags;
  final double animationValue;

  ScoreChart2Painter(this.scores, this.showTags, this.animationValue);

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

    // Sadece dikey eksen çizgileri
    for (double i = 0; i <= 20; i += 20) {
      canvas.drawLine(
        Offset(i * size.width / 100, 0),
        Offset(i * size.width / 100, size.height),
        paintBackground,
      );
    }

    for (double i = 0; i <= 100; i += 20) {
      // Yatay çizgiler
      canvas.drawLine(
        Offset(0, size.height - i * size.height / 100),
        Offset(size.width, size.height - i * size.height / 100),
        paintBackground,
      );

      if (showTags) {
        // Yatay eksen etiketleri
        TextSpan span = TextSpan(
          style: myDigitalStyle(color: mySecondaryTextColor),
          text: i.toInt().toString(),
        );
        TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(
            canvas,
            Offset(-tp.width - 5,
                size.height - i * size.height / 100 - tp.height / 2));
      }
    }

    if (scores.isEmpty) return;

    double margin = 15.0;
    double columnWidth = (size.width - margin) / (scores.length - 1);
    double columnHeight = size.height / 100;

    Path path = Path();
    path.moveTo(
        margin, size.height - scores[0].score * columnHeight * animationValue);

    // Dairesel geçişler
    for (int i = 1; i < scores.length; i++) {
      double x = margin + columnWidth * i;
      double y = size.height - scores[i].score * columnHeight * animationValue;
      double prevX = margin + columnWidth * (i - 1);
      double prevY =
          size.height - scores[i - 1].score * columnHeight * animationValue;

      path.quadraticBezierTo(
        (prevX + x) / 2,
        prevY,
        x,
        y,
      );
    }

    // Alt kısmı boyama
    Path path2 = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(margin, size.height)
      ..close();
    canvas.drawPath(
      path2,
      Paint()..color = myAccentColor.withOpacity(0.3 * animationValue),
    );

    canvas.drawPath(path, paint);

    // Etiketler
    if (showTags && animationValue > 0.9) {
      for (int i = 0; i < scores.length; i++) {
        double x = margin + columnWidth * i;
        String monthName = scores[i].date != null
            ? [
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
              ][scores[i].date!.month - 1]
            : "";
        TextSpan span = TextSpan(
          style: myThinStyle(color: mySecondaryTextColor, fontSize: 12),
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

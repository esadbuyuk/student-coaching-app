import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pcaweb/controller/ui_controller.dart';
import 'package:pcaweb/model/my_constants.dart';

class QuestionStatsCard extends StatefulWidget {
  final int totalQuestions;
  final int correct;
  final int wrong;
  final int empty;
  final bool bigCircular;

  const QuestionStatsCard({
    super.key,
    required this.totalQuestions,
    required this.correct,
    required this.wrong,
    required this.empty,
    this.bigCircular = false,
  });

  @override
  State<QuestionStatsCard> createState() => _QuestionStatsCardState();
}

class _QuestionStatsCardState extends State<QuestionStatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _correctAnimation;
  late Animation<double> _wrongAnimation;

  @override
  void initState() {
    super.initState();

    double correctPercentage = widget.correct / widget.totalQuestions;
    double wrongPercentage = widget.wrong / widget.totalQuestions;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _correctAnimation =
        Tween<double>(begin: 0, end: correctPercentage).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _wrongAnimation =
        Tween<double>(begin: 0, end: correctPercentage + wrongPercentage)
            .animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant QuestionStatsCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Eğer parametreler değiştiyse animasyonları yeniden başlat
    if (oldWidget.correct != widget.correct ||
        oldWidget.wrong != widget.wrong ||
        oldWidget.totalQuestions != widget.totalQuestions) {
      double correctPercentage = widget.correct / widget.totalQuestions;
      double wrongPercentage = widget.wrong / widget.totalQuestions;

      _correctAnimation = Tween<double>(begin: 0, end: correctPercentage)
          .animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));

      _wrongAnimation =
          Tween<double>(begin: 0, end: correctPercentage + wrongPercentage)
              .animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));

      _animationController.reset(); // Animasyonu sıfırla
      _animationController.forward(); // Animasyonu yeniden başlat
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double circularsHeight = isMobile(context)
        ? 120.h
        : widget.bigCircular
            ? 180.h
            : 70.h;
    double circularsWidth = isMobile(context)
        ? 120.h
        : widget.bigCircular
            ? 180.h
            : 70.h;
    double circularsStrokeWidth = isMobile(context)
        ? 9
        : widget.bigCircular
            ? 14
            : 7;
    Color textColors = mySecondaryTextColor;
    Color trueColor = myAccentColor;
    Color falseColor = Colors.red;

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isMobile(context)
              ? Column(
                  children: [
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return SizedBox(
                              width: circularsHeight,
                              height: circularsWidth,
                              child: Stack(
                                children: [
                                  CustomPaint(
                                    size: Size(circularsWidth, circularsHeight),
                                    painter: CircleBorderPainter(
                                      strokeWidth: circularsStrokeWidth,
                                      color: myPrimaryColor,
                                    ),
                                  ),
                                  // Yanlış oranı
                                  SizedBox(
                                    height: circularsHeight,
                                    width: circularsWidth,
                                    child: CircularProgressIndicator(
                                      value: _wrongAnimation.value,
                                      strokeWidth: circularsStrokeWidth,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          falseColor),
                                    ),
                                  ),
                                  // Doğru oranı
                                  SizedBox(
                                    height: circularsHeight,
                                    width: circularsWidth,
                                    child: CircularProgressIndicator(
                                      value: _correctAnimation.value,
                                      strokeWidth: circularsStrokeWidth,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          trueColor),
                                    ),
                                  ),
                                  // Ortadaki metin
                                  Center(
                                    child: Text(
                                      "${widget.totalQuestions}",
                                      style: myDigitalStyle(color: textColors),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          width: 16.w,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatRow(
                                "Doğru", widget.correct, myAccentColor),
                            _buildStatRow("Yanlış", widget.wrong, Colors.red),
                            _buildStatRow(
                                "Boş", widget.empty, mySecondaryTextColor),
                          ],
                        ),
                      ],
                    ),
                  ],
                )
              : Column(
                  children: [
                    const Spacer(
                      flex: 1,
                    ),
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return SizedBox(
                              width: circularsHeight,
                              height: circularsWidth,
                              child: Stack(
                                children: [
                                  CustomPaint(
                                    size: Size(circularsWidth, circularsHeight),
                                    painter: CircleBorderPainter(
                                      strokeWidth: circularsStrokeWidth,
                                      color: myPrimaryColor,
                                    ),
                                  ),
                                  // Yanlış oranı
                                  SizedBox(
                                    height: circularsHeight,
                                    width: circularsWidth,
                                    child: CircularProgressIndicator(
                                      value: _wrongAnimation.value,
                                      strokeWidth: circularsStrokeWidth,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          falseColor),
                                    ),
                                  ),
                                  // Doğru oranı
                                  SizedBox(
                                    height: circularsHeight,
                                    width: circularsWidth,
                                    child: CircularProgressIndicator(
                                      value: _correctAnimation.value,
                                      strokeWidth: circularsStrokeWidth,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          trueColor),
                                    ),
                                  ),
                                  // Ortadaki metin
                                  Center(
                                    child: Text(
                                      "${widget.totalQuestions}",
                                      style: myDigitalStyle(color: textColors),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          width: widget.bigCircular ? 14.w : 6.w,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatRow(
                                "Doğru", widget.correct, myAccentColor),
                            _buildStatRow("Yanlış", widget.wrong, Colors.red),
                            _buildStatRow(
                                "Boş", widget.empty, mySecondaryTextColor),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(
                      flex: 2,
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: FittedBox(
        child: Row(
          children: [
            SizedBox(
              width: isMobile(context) ? 13.w : 3.w,
              height: 20.h,
              child: FittedBox(
                child: Text(
                  value.toString(),
                  style: myDigitalStyle(color: color),
                ),
              ),
            ),
            SizedBox(width: isMobile(context) ? 13.w : 3.w),
            Text(
              label.toUpperCase(),
              style: myTonicStyle(mySecondaryTextColor, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

class CircleBorderPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;

  CircleBorderPainter({required this.strokeWidth, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - strokeWidth / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

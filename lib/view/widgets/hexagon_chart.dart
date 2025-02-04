import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pcaweb/controller/ui_controller.dart';
import 'package:pcaweb/view/widgets/widget_decorations.dart';

import '../../model/my_constants.dart';
import '../../view/widgets/skill_card.dart';

class PolygonChart extends StatelessWidget {
  final List<double> data;
  final double radius;
  final int? numberOfSides;

  const PolygonChart({
    super.key,
    required this.data,
    this.radius = 35,
    this.numberOfSides,
  });

  @override
  Widget build(BuildContext context) {
    int sides = numberOfSides ?? data.length;
    if (sides < 5 || sides > 6) {
      throw Exception('Polygon must have 5 or 6 sides.');
    }

    List<double> fixedDataForChart = divideBy100(data);

    double width = isMobile(context) ? (radius * 2).w : (radius * 2);
    return CustomPaint(
      size: Size(width, width),
      painter: PolygonChartPainter(
        data: fixedDataForChart,
        sides: sides,
      ),
    );
  }
}

List<double> divideBy100(List<double> data) {
  return data.map((value) => value / 100).toList();
}

class PolygonChartPainter extends CustomPainter {
  final List<double> data;
  final int sides;
  final Paint _insidePaint = Paint()
    ..color = myAccentColor.withOpacity(0.6)
    ..style = PaintingStyle.fill
    ..strokeWidth = 1.0;
  final Paint _backgroundPaint = Paint()
    ..color = myAccentColor.withOpacity(0.2)
    ..style = PaintingStyle.fill
    ..strokeWidth = 1.0;
  final Paint _linePaint = Paint()
    ..color = myAccentColor.withOpacity(0.8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  // Glow etkisi için bir Paint
  final Paint _glowPaint = Paint()
    ..color = myAccentColor.withOpacity(0.3)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

  PolygonChartPainter({required this.data, required this.sides});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 * 0.8;

    final inlinePath = Path();
    final outlinePath = Path();

    final rotationOffset = sides == 5 ? -pi / 2 : 0;

    for (int i = 0; i < sides; i++) {
      final angle = (2 * pi / sides) * i + rotationOffset;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      final dataX = center.dx + radius * data[i] * cos(angle);
      final dataY = center.dy + radius * data[i] * sin(angle);

      if (i == 0) {
        inlinePath.moveTo(dataX, dataY);
        outlinePath.moveTo(x, y);
      } else {
        inlinePath.lineTo(dataX, dataY);
        outlinePath.lineTo(x, y);
      }
    }

    inlinePath.close();
    outlinePath.close();

    // 1. Glow efekti
    canvas.drawPath(outlinePath, _glowPaint);

    // 2. Dış katman (arka plan)
    canvas.drawPath(outlinePath, _backgroundPaint);

    // 3. Çokgen çizgileri ve iç dolgu
    canvas.drawPath(inlinePath, _linePaint);
    canvas.drawPath(inlinePath, _insidePaint);

    // 4. Gölge efekti için: InlinePath'in dış kenarına ufak bir gölge
    canvas.drawShadow(inlinePath, Colors.black, 3.0, true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

class PolygonContainer extends StatefulWidget {
  final double radius;
  final List<String> labels;
  final List<int?> ids;
  final List<double> data;
  final Function callbackFunct;
  final int? numberOfSides;

  const PolygonContainer({
    super.key,
    required this.radius,
    required this.labels,
    required this.ids,
    required this.data,
    this.numberOfSides,
    required this.callbackFunct,
  });

  @override
  State<PolygonContainer> createState() => PolygonContainerState();
}

class PolygonContainerState extends State<PolygonContainer> {
  int? selectedIndex; // Seçilen elemanın index'i
  int? hoveredIndex; // Seçilen elemanın index'i

  @override
  Widget build(BuildContext context) {
    double containersRadius = widget.radius; // 120.h

    double polygonsRadius = isMobile(context)
        ? 50.w
        : containersRadius / 30 * 11; // sorun bu değerler de!

    double stacksWidth =
        isMobile(context) ? 220.w : containersRadius / 5; // containersRadius

    double marginSize = isMobile(context) ? 45.w : containersRadius / 30 * 11;
    double polygonsBorderRadius = polygonsRadius + marginSize;
    int dataLength = widget.data.isEmpty ? 5 : widget.data.length;
    List<String> displayLabels = widget.labels;
    List<double> displayData = List.from(widget.data);

    return Container(
      alignment: Alignment.center,
      width: stacksWidth,
      height: stacksWidth,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          ...buildSkillTexts(polygonsBorderRadius,
              numberOfEdges: widget.numberOfSides ?? dataLength,
              displayLabels: displayLabels),
          Align(
            alignment: Alignment.center,
            child: PolygonChart(
              data: displayData,
              radius: polygonsRadius,
              numberOfSides: widget.numberOfSides,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildSkillTexts(double polygonsBorderRadius,
      {required int numberOfEdges, required List<String> displayLabels}) {
    final rotationOffset = numberOfEdges == 5 ? -pi / 2 : 0;

    return List.generate(numberOfEdges, (index) {
      final angle = (2 * pi / numberOfEdges) * index + rotationOffset;
      final x =
          polygonsBorderRadius + (polygonsBorderRadius * 0.9 * cos(angle));
      final y =
          polygonsBorderRadius + (polygonsBorderRadius * 0.9 * sin(angle));

      return Positioned(
        left: isMobile(context) ? x : x + 1.4.w,
        top: isMobile(context) ? y : y + 6.h,
        child: MouseRegion(
          onEnter: (_) {
            setState(() {
              hoveredIndex = index; // Hover olan index'i ayarla
            });
          },
          onExit: (_) {
            setState(() {
              hoveredIndex = null; // Hover olmayan durumda null yap
            });
          },
          child: GestureDetector(
            onTapUp: (tapDownDetails) {
              setState(() {
                selectedIndex = index; // Seçilen index'i güncelle
              });
              widget.callbackFunct(
                clickedSkillId: widget.ids[index],
                clickedSkillStat: widget.data[index].toInt(),
                clickedSkillName: widget.labels[index],
              );
            },
            child: Container(
              width: 52,
              padding: const EdgeInsetsDirectional.all(2),
              decoration:
                  index == hoveredIndex ? buildSelectedDecoration() : null,
              child: TweenAnimationBuilder<int>(
                duration:
                    Duration(milliseconds: 5 * widget.data[index].toInt()),
                tween: IntTween(
                    begin: 0,
                    end: widget.data.isEmpty ? 0 : widget.data[index].toInt()),
                builder: (context, value, child) {
                  return SkillCard(
                    stat: value,
                    skillName: displayLabels[index],
                  );
                },
              ),
            ),
          ),
        ),
      );
    });
  }
}

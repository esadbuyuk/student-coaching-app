import 'package:flutter/cupertino.dart';

// yönlendireceği screen variable olarak verilicek.
class ScreenCard {
  final String title;
  final IconData? icon;
  final String destinationPage;

  ScreenCard(
      {required this.title, required this.icon, required this.destinationPage});
}

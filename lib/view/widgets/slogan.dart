import 'package:flutter/material.dart';

import '../../controller/academy_controller.dart';
import '../../model/my_constants.dart';

class Slogan extends StatelessWidget {
  Slogan({
    Key? key,
  }) : super(key: key);

  final AcademyController _academyController = AcademyController();

  @override
  Widget build(BuildContext context) {
    return Text(
      _academyController.getAcademySlogan(),
      style: mySloganStyle(color: darkMode ? mySecondaryColor : myIconsColor),
    );
  }
}

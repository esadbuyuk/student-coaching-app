import 'package:flutter/material.dart';

import '../../model/my_constants.dart';

class DefaultProfileImage extends StatelessWidget {
  final Color backgroundColor;
  final bool darkMode = true;

  const DefaultProfileImage(
      {Key? key, this.backgroundColor = myBackgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.cover,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        alignment: Alignment.bottomCenter,
        child: darkMode
            ? Stack(alignment: Alignment.bottomCenter, children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    double iconSize = constraints.maxWidth / 1.5;
                    return Icon(
                      Icons.person_outlined,
                      size: iconSize,
                      color: myPrimaryColor,
                    );
                  },
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    double iconSize = constraints.maxWidth / 1.63;
                    return Padding(
                      padding: const EdgeInsets.all(1.35),
                      child: Icon(
                        Icons.person,
                        size: iconSize,
                        color: myBackgroundColor,
                      ),
                    );
                  },
                ),
              ])
            : LayoutBuilder(
                builder: (context, constraints) {
                  double iconSize = constraints.maxWidth / 1.5;
                  return Icon(
                    Icons.person_outlined,
                    size: iconSize,
                    color: myPrimaryColor,
                  );
                },
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../model/my_constants.dart';

BoxDecoration buildInsideShadow() {
  return BoxDecoration(
    // boxShadow: [
    //   BoxShadow(
    //     color: Colors.black.withOpacity(0.4), // Gölge rengi ve opaklığı
    //     blurRadius: 10, // Gölgenin yayılma miktarı
    //     offset: const Offset(5, 5), // Gölgenin x ve y eksenindeki kayması
    //   ),
    // ],
    borderRadius: const BorderRadius.all(
      Radius.circular(10),
    ),
    border: Border.all(
      color: darkMode ? myPrimaryColor.withOpacity(1) : myPrimaryColor,
      width: 0.8,
    ),
    color: darkMode
        ? Colors.black.withOpacity(0.2)
        : Colors.white.withOpacity(0.2),
  );
}

BoxDecoration buildBorderDecoration() {
  return BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.4), // Gölge rengi ve opaklığı
        blurRadius: 10, // Gölgenin yayılma miktarı
        offset: const Offset(5, 5), // Gölgenin x ve y eksenindeki kayması
      ),
    ],
    borderRadius: const BorderRadius.all(
      Radius.circular(10),
    ),
    border: Border.all(
      color: myPrimaryColor,
      width: 0.8,
    ),
    color: myBackgroundColor,
  );
}

BoxDecoration buildSelectedDecoration(bool isMobile) {
  return BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: darkMode
            ? isMobile
                ? Colors.transparent
                : Colors.black.withOpacity(0.8)
            : isMobile
                ? Colors.transparent
                : Colors.black.withOpacity(0.4), // Gölge rengi ve opaklığı
        blurRadius: 10, // Gölgenin yayılma miktarı
        offset: Offset(isMobile ? 0 : 5,
            isMobile ? 0 : 5), // Gölgenin x ve y eksenindeki kayması
      ),
    ],
    borderRadius: const BorderRadius.all(
      Radius.circular(10),
    ),
    border: Border.all(
      color: isMobile ? Colors.transparent : myBackgroundColor,
      width: 2.0,
    ),
    color: isMobile ? Colors.transparent : myBackgroundColor,
  );
}

BoxDecoration buildOverlayDecoration() {
  return BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: darkMode
            ? Colors.black.withOpacity(0.8)
            : Colors.black.withOpacity(0.3), // Gölge rengi ve opaklığı
        blurRadius: 100, // Gölgenin yayılma miktarı
        offset: const Offset(0, 0), // Gölgenin x ve y eksenindeki kayması
      ),
    ],
    borderRadius: const BorderRadius.all(
      Radius.circular(10),
    ),
    border: Border.all(
      color: myAccentColor,
      width: 0.8,
    ),
    color: myBackgroundColor,
  );
}

import 'package:flutter/cupertino.dart';

bool isKeyboardOpen(BuildContext context) {
  double bottomInset = MediaQuery.of(context).viewInsets.bottom;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Burada viewInsets.bottom değerini tekrar kontrol edebilirsiniz
  });
  return bottomInset != 0;
}

bool isMobile(BuildContext context) {
  return getScreenWidth(context) < 1000; // 800 filan yapılabilir
}

double getScreenWidth(BuildContext context) {
  return MediaQuery.sizeOf(context).width;
}

double getScreenHeight(BuildContext context) {
  return MediaQuery.sizeOf(context).height;
}

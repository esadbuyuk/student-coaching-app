import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/my_constants.dart';

class MyButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onPressed;
  final Color color;

  const MyButton({super.key, required this.buttonText, this.onPressed, this.color = myPrimaryColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,

        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(5.r))), // Background color
        overlayColor: myIconsColor,
      ),
      child: Text(
        buttonText,
        style: const TextStyle(
            fontSize: 18,
            color: myTextColor,
            fontFamily: 'MyTonicFont',
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

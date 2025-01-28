import 'package:flutter/material.dart';

import '../../model/my_constants.dart';

class MyToggleSwitch extends StatefulWidget {
  final Function(bool) onToggle;

  const MyToggleSwitch({super.key, required this.onToggle});

  @override
  MyToggleSwitchState createState() => MyToggleSwitchState();
}

class MyToggleSwitchState extends State<MyToggleSwitch> {
  bool liveRecording = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          liveRecording = !liveRecording;
          widget.onToggle(
              liveRecording); // Dışarıdan gelen onToggle fonksiyonunu çağırır
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 25,
        width: 50,
        decoration: BoxDecoration(
            color: liveRecording ? myPrimaryColor : myBackgroundColor,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: myIconsColor, width: 2)),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              alignment:
                  liveRecording ? Alignment.centerRight : Alignment.centerLeft,
              child: const Padding(
                padding: EdgeInsets.all(2.0),
                child: CircleAvatar(
                  backgroundColor: myIconsColor,
                  radius: 9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

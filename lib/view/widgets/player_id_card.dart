import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../controller/disciple_controller.dart';
import '../../controller/image_clipper.dart';
import '../../model/disciple.dart';
import '../../model/my_constants.dart';
import 'my_card_clippers.dart';
import 'overall_card.dart';

class FuturePlayerIDCard extends StatefulWidget {
  const FuturePlayerIDCard(
      {Key? key, required this.playerID, required this.playerController})
      : super(key: key);

  final int playerID;
  final DiscipleController playerController;

  @override
  State<FuturePlayerIDCard> createState() => _FuturePlayerIDCardState();
}

class _FuturePlayerIDCardState extends State<FuturePlayerIDCard> {
  late Future<Disciple> playerFuture;
  bool darkMode = true;

  @override
  void initState() {
    super.initState();
    playerFuture = widget.playerController.fetchPlayerData();
  }

  @override
  void didUpdateWidget(FuturePlayerIDCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playerID != widget.playerID) {
      setState(() {
        playerFuture = widget.playerController.fetchPlayerData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Disciple>(
      future: playerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final disciple = snapshot.data!;
          return ClipPath(
            clipper: MyCustomIDCardClipper(),
            child: Container(
              height: 265.h,
              width: 105,
              padding: EdgeInsetsDirectional.only(
                  start: 10.h, end: 10.h, bottom: 10.h, top: 10.h),
              decoration: BoxDecoration(
                color: darkMode ? Colors.transparent : myPrimaryColor,
                border: Border.all(
                    color: darkMode ? Colors.transparent : mySecondaryColor,
                    width: 3),
                borderRadius: BorderRadius.all(Radius.circular(0.r)),
              ),
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: SizedBox(
                      height: 22.h,
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                          style: myTonicStyle(
                              darkMode ? mySecondaryTextColor : myTextColor),
                          disciple.surname.toUpperCase(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  SizedBox(
                    // profile Photo
                    width: 85,
                    height: 85.h,
                    child: PentagonImage(
                      imagePath: disciple.profilePicture,
                      defaultImageColor:
                          darkMode ? myBackgroundColor : myPrimaryColor,
                    ),
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  Expanded(
                    child: OverallCard(
                      overall: disciple.overall,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: Text('No player data found'));
        }
      },
    );
  }
}

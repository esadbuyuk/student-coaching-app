import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pcaweb/controller/ui_controller.dart';

import '../../controller/user_controller.dart';
import '../../model/my_constants.dart';
import '../../model/screen_card_data.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/slogan.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserController userController = UserController();
    int buttonCount = 4;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: buildAppBar(context, false),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage("assets/icons/KAIHL_LOGO_MAVİ.png"),
              fit: BoxFit
                  .cover, // Ekranı tamamen kaplayacak şekilde resmi ölçeklendirir
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.1), // Resmi saydam hale getirir
                BlendMode.dstATop, // Karışım modu
              ),
            ),
          ),
          child: Column(
            children: [
              Flexible(
                child: Container(),
              ),
              SizedBox(
                height: 250,
                child: FittedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Image(
                        width: 390,
                        height: 130,
                        color: myPrimaryColor,
                        image: AssetImage(
                          "assets/icons/KAIHL_LOGO_YAZILI.png",
                        ),
                      ),

                      // SizedBox(
                      //     width: 180.h, child: FittedBox(child: BrandName())),
                      SizedBox(
                        height: 20.h,
                      ),
                      SizedBox(
                          width: 180.h,
                          child: const FittedBox(child: HomeText())),
                      SizedBox(
                        height: 20.h,
                      ),
                      SizedBox(width: 180.h, child: FittedBox(child: Slogan())),
                      // SizedBox(
                      //   height: 55.h,
                      // ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: Container(),
              ),
              if (isMobile(context))
                SizedBox(
                  height: 203.h,
                  width: 900,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsetsDirectional.only(start: 75.w, end: 75.w),
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        buttonCount, // userController.isUserAuthorized() ? 4 : 3,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsetsDirectional.only(end: 3),
                      child: ButtonCard(
                        title: ScreenCardData().screenCards[index].title,
                        icon: ScreenCardData().screenCards[index].icon,
                        destinationPage:
                            ScreenCardData().screenCards[index].destinationPage,
                      ),
                    ),
                  ),
                ),
              if (!isMobile(context))
                SizedBox(
                  height: 203.h,
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize
                            .min, // İçeriği minimum genişlikte tutar
                        children: List.generate(
                          buttonCount, // userController.isUserAuthorized() ? 4 : 3,
                          (index) => Padding(
                            padding: const EdgeInsetsDirectional.only(end: 3),
                            child: ButtonCard(
                              title: ScreenCardData().screenCards[index].title,
                              icon: ScreenCardData().screenCards[index].icon,
                              destinationPage: ScreenCardData()
                                  .screenCards[index]
                                  .destinationPage,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(
                height: 80.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeText extends StatelessWidget {
  const HomeText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Stroked text as border.
        Text(
          'MENU',
          style: TextStyle(
            fontFamily: 'MyTonicFont',
            fontSize: 58,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = mySecondaryColor,
          ),
        ),
        // Solid text as fill.
        const Text(
          'MENU',
          style: TextStyle(
            fontFamily: 'MyTonicFont',
            fontSize: 58,
            color: myPrimaryColor,
          ),
        ),
      ],
    );
  }
}

class ButtonCard extends StatefulWidget {
  final String title;
  final IconData? icon;
  final String destinationPage;

  const ButtonCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.destinationPage,
  }) : super(key: key);

  @override
  State<ButtonCard> createState() => _ButtonCardState();
}

class _ButtonCardState extends State<ButtonCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        context.go(widget.destinationPage);
      },
      child: Card(
        color: myPrimaryColor,
        shadowColor: mySecondaryColor,
        elevation: 3.h,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(0),
          child: SizedBox(
            width: 183,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  flex: 2,
                  child: Container(),
                ),
                if (widget.icon != null)
                  Flexible(
                    flex: 17,
                    child: FittedBox(
                      child: Container(
                        alignment: Alignment.center,
                        child: Icon(
                          widget.icon,
                          size: 100,
                          color: mySecondaryColor,
                        ),
                      ),
                    ),
                  ),
                if (widget.icon == null)
                  Flexible(
                    flex: 17,
                    child: FittedBox(
                        child: Center(
                      child: Image(
                        width: 200.h,
                        height: 200.h,
                        color: myBackgroundColor,
                        image: const AssetImage("assets/icons/trophy_6.png"),
                      ),
                    )),
                  ),
                Flexible(
                  flex: 1,
                  child: Container(),
                ),
                Flexible(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 6, end: 6),
                    child: Container(
                      alignment: Alignment.center,
                      child: FittedBox(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontFamily: 'MyTonicFont',
                            color: mySecondaryColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Container(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

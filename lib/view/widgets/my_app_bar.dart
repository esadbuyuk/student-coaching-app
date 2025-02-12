import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controller/academy_controller.dart';
import '../../model/my_constants.dart';

AppBar buildAppBar(BuildContext context, bool showLogo, {String? pageName}) {
  final AcademyController academyController = AcademyController();

  return AppBar(
    elevation: 0.2,
    shadowColor: myBackgroundColor,
    toolbarHeight: 50, // Web için sabit yükseklik
    centerTitle: true,
    leadingWidth: 74,
    backgroundColor: myBackgroundColor, // Web için tercihe bağlı bir renk
    leading: IconButton(
      alignment: AlignmentDirectional.centerStart,
      padding: const EdgeInsetsDirectional.only(start: 20),
      onPressed: () {
        // Home sayfasına yönlendirme
        context.go('/home');
      },
      icon: const Icon(Icons.home_outlined, size: 25, color: myIconsColor),
      // icon: SvgPicture.asset(
      //   'assets/icons/home_icon.svg',
      //   color: myIconsColor,
      //   width: 15,
      //   height: 15,
      // ),
    ),
    title: showLogo
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SvgPicture.asset(
              //   'assets/icons/logo_icon.svg', // Logonun ikonu
              //   width: 30,
              //   height: 30,
              //   color: myIconsColor,
              // ),
              // const SizedBox(width: 10),
              Text(
                pageName ?? academyController.getAbbreviatedName(),
                style: pageName == null
                    ? myBrandStyle()
                    : myTonicStyle(myIconsColor),
              ),
            ],
          )
        : null,
    actions: [
      // Sağ tarafa bir veya daha fazla düğme eklemek isterseniz
      Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: IconButton(
          icon: const Icon(
            Icons.logout_outlined,
            color: myIconsColor,
            size: 25,
          ),
          onPressed: () {
            context.go('/login');
          },
        ),
      ),
    ],
  );
}

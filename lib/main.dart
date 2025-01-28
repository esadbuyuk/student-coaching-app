import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pcaweb/view/screens/charts_page.dart';
import 'package:pcaweb/view/screens/disciple_list_page.dart';
import 'package:pcaweb/view/screens/home_page.dart';
import 'package:pcaweb/view/screens/log_in_page.dart';
import 'package:pcaweb/view/screens/monthly_awards_page.dart';
import 'package:pcaweb/view/screens/player_profile_page.dart';
import 'package:pcaweb/view/screens/trainer_profile_page.dart';

import 'controller/disciple_controller.dart';
import 'model/my_constants.dart';

class MyCustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child; // Glow efektini tamamen devre dışı bırakır
  }
}

// For API SERVİCE
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  final DiscipleController discipleController;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    final GoRouter router = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/playerProfile',
          builder: (context, state) => const PlayerProfilePage(),
        ),
        GoRoute(
          path: '/trainerProfile',
          builder: (context, state) => const TrainerProfilePage(),
        ),
        GoRoute(
          path: '/charts',
          builder: (context, state) => const ChartsPage(),
        ),
        GoRoute(
          path: '/monthWinners',
          builder: (context, state) => const MonthlyAwardsPage(),
        ),
        GoRoute(
          path: '/list',
          builder: (context, state) => const ScoreListPage(),
        ),
      ],
    );

    return ScreenUtilInit(
      designSize: const Size(360, 800),
      // isMobile(context) ? const Size(360, 800) : const Size(1700, 1000), saçma bir yöntemmiş
      builder: (BuildContext context, child) => MaterialApp.router(
        routerConfig: router,
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.stylus,
            PointerDeviceKind.unknown
          },
        ),
        theme: ThemeData(
          scaffoldBackgroundColor: myBackgroundColor,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: myTextColor),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: myBackgroundColor,
            titleTextStyle: myBrandStyle(),
          ),
        ),
        // builder: (context, child) {
        //   return ScrollConfiguration(
        //     behavior: MyCustomScrollBehavior(),
        //     child: child!,
        //   );
        // },
      ),
    );
  }
}

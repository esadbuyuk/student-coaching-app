import 'package:flutter/material.dart';

import '../controller/user_controller.dart';
import '../model/screen_card.dart';

// yeni veri eklemesi yaptığında ListView'in itemCount sayısını arttırmayı unutma!
class ScreenCardData {
  final UserController userController = UserController();
  late final List<ScreenCard> screenCards;

  ScreenCardData() {
    screenCards = [
      // ScreenCard(
      //   title: 'PLAYERS',
      //   icon: Icons.people_alt_outlined, // Web uyumlu ikon
      //   destinationPage: const DiscipleListPage(),
      // ),
      ScreenCard(
        title: 'SON DENEME',
        icon: Icons.featured_play_list_outlined, // Web uyumlu ikon
        destinationPage: '/list', // playerID: userController.getUserID()
      ),
      ScreenCard(
        title: 'GRAFİKLER',
        icon: Icons.show_chart_rounded, // Web uyumlu ikon
        destinationPage: '/charts', // playerID: userController.getUserID()
      ),
      ScreenCard(
        title: 'EN İYİLER',
        icon: Icons.grade_outlined, // Web uyumlu ikon
        destinationPage:
            '/monthWinners', // playerID: userController.getUserID()
      ),

      // ScreenCard(
      //   title: 'PROFİL',
      //   icon: Icons.person_outline, // Web uyumlu ikon
      //   destinationPage: userController.isUserAuthorized()
      //       ? '/trainerProfile'
      //       : '/playerProfile', // playerID: userController.getUserID()
      // ),
      // ScreenCard(
      //   title: 'KOÇLAR',
      //   icon: Icons.groups_outlined, // Web uyumlu ikon
      //   destinationPage: '/trainerProfile',
      // ),
      // ScreenCard(
      //   title: 'RESULTS',
      //   icon: Icons.note_alt_outlined, // Web uyumlu ikon
      //   destinationPage: const ResultCardsPage(),
      // ),
    ];
  }
}

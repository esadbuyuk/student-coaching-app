import 'package:flutter/material.dart';

import '../../model/disciple.dart';
import '../../view/widgets/player_card.dart';
import '../../view/widgets/player_charts_card.dart';
import '../../view/widgets/player_profile_card.dart';
import '../../view/widgets/player_results_card.dart';
import '../../view/widgets/player_stats_card.dart';

class PlayerList extends StatelessWidget {
  const PlayerList({
    Key? key,
    required this.playerListData,
    required this.listNo,
    required this.playerCardHeight,
    // required this.onPlusIconTap, // Add a callback for the plus icon tap
  }) : super(key: key);

  final List<Disciple>? playerListData;
  final int listNo;
  final double playerCardHeight;
  // final VoidCallback onPlusIconTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: playerListData!.length,
            itemBuilder: (context, playerNo) {
              // playerNo aşağıdakiler düzenlenecek

              switch (listNo) {
                case 0:
                  return PlayerChartsCard(
                      playerData: playerListData![playerNo],
                      playerCardHeight: playerCardHeight);
                case 1:
                  // şimdilik performans sorunları nedeniyle kullanımdan çıkarıldı.
                  return PlayerProfileCard(
                      playerData: playerListData![playerNo],
                      playerCardHeight: playerCardHeight);
                case 2:
                  return PlayerStatsCard(
                    playerData: playerListData![playerNo],
                    playerCardHeight: playerCardHeight,
                  );
                case 3:
                  return PlayerResultsCard(
                      playerData: playerListData![playerNo],
                      playerCardHeight: playerCardHeight);
                default:
                  return PlayerCard(
                      playerData: playerListData![playerNo],
                      playerCardHeight:
                          playerCardHeight); // Default case, should not reach here
              }
            },
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';

import 'air_raid_models.dart';
import 'practice_recap.dart';

class MissionRecapLayout extends StatelessWidget {
  const MissionRecapLayout({
    super.key,
    required this.audioControls,
    required this.actions,
    this.recapContent,
    this.notice,
    this.scrollController,
  });

  final Widget audioControls;
  final List<Widget> actions;
  final Widget? recapContent;
  final Widget? notice;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              recapContent ??
                  PracticeRecap(
                    praise: AirRaidPracticeRecap.praise,
                    points: AirRaidPracticeRecap.points,
                    pointIcons: const [
                      BaseboundIconName.hallway,
                      BaseboundIconName.phone,
                      BaseboundIconName.wait,
                    ],
                  ),
              ?notice,
              audioControls,
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      ...actions,
    ],
  );
}

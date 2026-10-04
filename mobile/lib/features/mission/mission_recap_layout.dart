import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';

import 'air_raid_models.dart';
import 'practice_recap.dart';

class MissionRecapLayout extends StatelessWidget {
  const MissionRecapLayout({
    super.key,
    required this.audioControls,
    required this.actions,
  });

  final Widget audioControls;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PracticeRecap(
                praise: AirRaidPracticeRecap.praise,
                points: AirRaidPracticeRecap.points,
                pointIcons: const [
                  BaseboundIconName.hallway,
                  BaseboundIconName.phone,
                  BaseboundIconName.wait,
                ],
              ),
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

import 'package:flutter/material.dart';

import 'air_raid_models.dart';
import 'practice_recap.dart';

class MissionRecapLayout extends StatelessWidget {
  const MissionRecapLayout({
    super.key,
    required this.title,
    required this.audioControls,
    required this.actions,
  });

  final String title;
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
                title: title,
                praise: AirRaidPracticeRecap.praise,
                points: AirRaidPracticeRecap.points,
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

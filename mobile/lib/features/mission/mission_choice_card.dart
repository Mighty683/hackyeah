import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import 'air_raid_mission.dart';

BaseboundIconName missionActionIcon(MissionActionIcon action) =>
    switch (action) {
      MissionActionIcon.window => BaseboundIconName.window,
      MissionActionIcon.door ||
      MissionActionIcon.leave => BaseboundIconName.door,
      MissionActionIcon.interior ||
      MissionActionIcon.hallway => BaseboundIconName.hallway,
      MissionActionIcon.livingRoom => BaseboundIconName.livingRoom,
      MissionActionIcon.bedroom => BaseboundIconName.bedroom,
      MissionActionIcon.kitchen => BaseboundIconName.kitchen,
      MissionActionIcon.mom => BaseboundIconName.mother,
      MissionActionIcon.dad => BaseboundIconName.father,
      MissionActionIcon.grandparent => BaseboundIconName.grandparent,
      MissionActionIcon.call => BaseboundIconName.phone,
      MissionActionIcon.message => BaseboundIconName.message,
      MissionActionIcon.stay => BaseboundIconName.stay,
      MissionActionIcon.home => BaseboundIconName.home,
      MissionActionIcon.school => BaseboundIconName.school,
      MissionActionIcon.shelter => BaseboundIconName.shelter,
      MissionActionIcon.park => BaseboundIconName.park,
      MissionActionIcon.busStop => BaseboundIconName.busStop,
      MissionActionIcon.down => BaseboundIconName.down,
      MissionActionIcon.protectHead => BaseboundIconName.protectHead,
      MissionActionIcon.next => BaseboundIconName.next,
      MissionActionIcon.replay => BaseboundIconName.replay,
    };

/// A large pictured action; its spoken instruction never depends on its label.
class MissionChoiceCard extends StatelessWidget {
  const MissionChoiceCard({
    super.key,
    required this.choice,
    required this.onPressed,
    this.selected = false,
  });

  final MissionChoice choice;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final accent = selected
        ? (choice.isCorrect ? BaseboundColors.green : BaseboundColors.coral)
        : BaseboundColors.blue;
    final surface = selected
        ? (choice.isCorrect
              ? BaseboundColors.greenLight
              : BaseboundColors.coralLight)
        : Colors.white;
    return Semantics(
      button: true,
      enabled: onPressed != null,
      onTap: onPressed,
      selected: selected,
      label: choice.label,
      child: ExcludeSemantics(
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: surface,
            disabledBackgroundColor: surface,
            foregroundColor: BaseboundColors.ink,
            disabledForegroundColor: BaseboundColors.ink,
            side: BorderSide(
              width: selected ? 3 : 1.5,
              color: selected ? accent : BaseboundColors.border,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            minimumSize: const Size(64, 100),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: selected ? accent : BaseboundColors.sky,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: BaseboundIcon(
                  selected
                      ? (choice.isCorrect
                            ? BaseboundIconName.check
                            : BaseboundIconName.cross)
                      : missionActionIcon(choice.icon),
                  size: 38,
                  color: selected ? Colors.white : null,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                choice.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

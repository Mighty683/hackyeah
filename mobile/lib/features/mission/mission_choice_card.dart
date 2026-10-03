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

/// A calm action row; its spoken instruction never depends on its label.
class MissionChoiceCard extends StatelessWidget {
  const MissionChoiceCard({
    super.key,
    required this.choice,
    required this.onPressed,
    this.selected = false,
    this.compact = false,
  });

  final MissionChoice choice;
  final VoidCallback? onPressed;
  final bool selected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = selected
        ? (choice.isCorrect ? BaseboundColors.green : BaseboundColors.coral)
        : BaseboundColors.border;
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
            side: BorderSide(color: accent),
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: compact ? 12 : 16,
            ),
            minimumSize: const Size(56, 56),
            alignment: Alignment.centerLeft,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            children: [
              BaseboundIcon(
                selected
                    ? (choice.isCorrect
                          ? BaseboundIconName.check
                          : BaseboundIconName.cross)
                    : missionActionIcon(choice.icon),
                size: 24,
                color: selected ? accent : BaseboundColors.ink,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  choice.label,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

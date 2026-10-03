import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import 'lost_landmarks.dart';
import 'lost_mission.dart';

BaseboundIconName lostActionIcon(LostActionIcon action) => switch (action) {
  LostActionIcon.stop || LostActionIcon.stay => BaseboundIconName.stay,
  LostActionIcon.search || LostActionIcon.look => BaseboundIconName.lost,
  LostActionIcon.leave => BaseboundIconName.door,
  LostActionIcon.meetingPoint => BaseboundIconName.pin,
  LostActionIcon.staff => BaseboundIconName.help,
  LostActionIcon.unknownAdult ||
  LostActionIcon.adult => BaseboundIconName.adult,
  LostActionIcon.call => BaseboundIconName.phone,
  LostActionIcon.wait => BaseboundIconName.wait,
  LostActionIcon.safe => BaseboundIconName.check,
  LostActionIcon.next => BaseboundIconName.next,
  LostActionIcon.mother => BaseboundIconName.mother,
  LostActionIcon.father => BaseboundIconName.father,
  LostActionIcon.grandparent => BaseboundIconName.grandparent,
};

/// Every pictured choice has its own native, labelled control.
class LostMissionChoiceCard extends StatelessWidget {
  const LostMissionChoiceCard({
    super.key,
    required this.choice,
    required this.onPressed,
  });

  final LostMissionChoice choice;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    label: choice.label,
    button: true,
    enabled: onPressed != null,
    onTap: onPressed,
    child: ExcludeSemantics(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: BaseboundColors.ink,
          minimumSize: const Size(64, 76),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          side: const BorderSide(color: BaseboundColors.border, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Row(
          children: [
            _illustration(),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                choice.label,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _illustration() => SizedBox.square(
    dimension: 54,
    child: switch (choice.landmarkPresetId) {
      final presetId? => LostLandmarkIllustration(presetId: presetId, size: 54),
      null => BaseboundIcon(lostActionIcon(choice.icon), size: 42),
    },
  );
}

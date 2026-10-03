import 'package:flutter/material.dart';

import 'air_raid_mission.dart';

IconData missionActionIcon(MissionActionIcon action) => switch (action) {
  MissionActionIcon.window => Icons.window,
  MissionActionIcon.door || MissionActionIcon.leave => Icons.door_front_door,
  MissionActionIcon.interior || MissionActionIcon.hallway => Icons.meeting_room,
  MissionActionIcon.livingRoom => Icons.weekend,
  MissionActionIcon.bedroom => Icons.bed,
  MissionActionIcon.kitchen => Icons.countertops,
  MissionActionIcon.mom => Icons.face_3,
  MissionActionIcon.dad => Icons.face_6,
  MissionActionIcon.grandparent => Icons.elderly,
  MissionActionIcon.call => Icons.phone_in_talk,
  MissionActionIcon.message => Icons.chat_bubble_outline,
  MissionActionIcon.stay => Icons.self_improvement,
  MissionActionIcon.home => Icons.home,
  MissionActionIcon.school => Icons.school,
  MissionActionIcon.shelter => Icons.apartment,
  MissionActionIcon.park => Icons.park,
  MissionActionIcon.busStop => Icons.directions_bus,
  MissionActionIcon.down => Icons.arrow_downward,
  MissionActionIcon.protectHead => Icons.health_and_safety_outlined,
  MissionActionIcon.next => Icons.arrow_forward,
  MissionActionIcon.replay => Icons.replay,
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
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: choice.label,
    child: ExcludeSemantics(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? const Color(0xFFDAECE2) : Colors.white,
          foregroundColor: const Color(0xFF213D37),
          disabledForegroundColor: const Color(0xFF213D37),
          side: BorderSide(
            width: selected ? 3 : 1.5,
            color: selected ? const Color(0xFF27634F) : const Color(0xFF8BACA0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          minimumSize: const Size(64, 100),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(missionActionIcon(choice.icon), size: 42),
            const SizedBox(height: 10),
            Text(
              choice.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}

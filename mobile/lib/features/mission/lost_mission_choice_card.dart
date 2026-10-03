import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import '../../widgets/child_character.dart';
import '../parent/data/family_plan.dart';
import 'lost_landmarks.dart';
import 'lost_mission.dart';
import 'scene_object_target.dart';

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

/// The pictured object is the accessible scene target; labels are spoken only.
class LostMissionChoiceCard extends StatelessWidget {
  const LostMissionChoiceCard({
    super.key,
    required this.choice,
    required this.onPressed,
    this.childGender = ChildGender.girl,
  });

  final LostMissionChoice choice;
  final VoidCallback? onPressed;
  final ChildGender childGender;

  @override
  Widget build(BuildContext context) => SceneObjectTarget(
    label: choice.label,
    onTap: onPressed,
    child: SizedBox(
      height: 140,
      width: double.infinity,
      child: CustomPaint(
        foregroundPainter: const SceneObjectHalo(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _illustration(),
        ),
      ),
    ),
  );

  Widget _illustration() {
    if (choice.landmarkPresetId case final presetId?) {
      return LostLandmarkIllustration(presetId: presetId, size: 108);
    }
    return switch (choice.icon) {
      LostActionIcon.staff => const LostLandmarkIllustration(
        presetId: 'information_desk',
        size: 108,
      ),
      LostActionIcon.stop || LostActionIcon.stay || LostActionIcon.wait =>
        ChildCharacter(pose: ChildPoseName.stand, gender: childGender),
      LostActionIcon.search || LostActionIcon.leave => CustomPaint(
        painter: _SquareChoicePainter(choice.icon),
      ),
      _ => BaseboundIcon(lostActionIcon(choice.icon), size: 100),
    };
  }
}

/// Separate native objects keep the choice highlight off the background art.
class _SquareChoicePainter extends CustomPainter {
  const _SquareChoicePainter(this.action);

  final LostActionIcon action;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Preserve object proportions in wide targets on narrow/text-scaled screens.
    final scale = size.shortestSide / 108;
    canvas.translate((size.width - 108 * scale) / 2, 0);
    canvas.scale(scale);
    if (action == LostActionIcon.leave) {
      _exit(canvas);
    } else {
      _paths(canvas);
    }
    canvas.restore();
  }

  void _exit(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 8, 92, 96),
        const Radius.circular(5),
      ),
      Paint()..color = BaseboundColors.peach,
    );
    canvas.drawRect(
      const Rect.fromLTWH(27, 29, 54, 75),
      Paint()..color = const Color(0xFF805335),
    );
    canvas.drawRect(
      const Rect.fromLTWH(32, 34, 44, 70),
      Paint()..color = const Color(0xFFD89761),
    );
    canvas.drawRect(
      const Rect.fromLTWH(38, 40, 32, 23),
      Paint()..color = BaseboundColors.sky,
    );
    canvas.drawCircle(
      const Offset(67, 78),
      3,
      Paint()..color = BaseboundColors.ink,
    );
    canvas.drawRect(
      const Rect.fromLTWH(3, 100, 102, 8),
      Paint()..color = const Color(0xFF92ACCB),
    );
  }

  void _paths(Canvas canvas) {
    final street = Paint()
      ..color = const Color(0xFF92ACCB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;
    canvas.drawPath(
      Path()
        ..moveTo(54, 108)
        ..lineTo(54, 71)
        ..lineTo(15, 38)
        ..moveTo(54, 71)
        ..lineTo(94, 42),
      street,
    );
    canvas.drawRect(
      const Rect.fromLTWH(50, 5, 7, 78),
      Paint()..color = const Color(0xFF805335),
    );
    canvas.drawPath(
      Path()
        ..moveTo(23, 10)
        ..lineTo(80, 10)
        ..lineTo(93, 22)
        ..lineTo(80, 34)
        ..lineTo(23, 34)
        ..close(),
      Paint()..color = BaseboundColors.blue,
    );
    canvas.drawPath(
      Path()
        ..moveTo(84, 40)
        ..lineTo(25, 40)
        ..lineTo(13, 52)
        ..lineTo(25, 64)
        ..lineTo(84, 64)
        ..close(),
      Paint()..color = BaseboundColors.peach,
    );
  }

  @override
  bool shouldRepaint(_SquareChoicePainter oldDelegate) =>
      action != oldDelegate.action;
}

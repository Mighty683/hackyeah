import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';
import '../../widgets/child_character.dart';
import '../parent/data/family_plan.dart';
import '../../ui/basebound_ui.dart';
import 'air_raid_mission.dart';
import 'mission_home_plan.dart';
import 'mission_object_highlights.dart';
import 'mission_outdoor_action_scene.dart';
import 'mission_scene_layout.dart';
import 'scene_object_target.dart';

bool missionUsesSceneChoices(MissionVisual visual) => switch (visual) {
  MissionVisual.room ||
  MissionVisual.apartment ||
  MissionVisual.street ||
  MissionVisual.contacts ||
  MissionVisual.communication ||
  MissionVisual.sheltered ||
  MissionVisual.quiet ||
  MissionVisual.getDown ||
  MissionVisual.protectHead => true,
  _ => false,
};

/// Uncropped practice art with accessible targets around scene objects.
class MissionScene extends StatelessWidget {
  const MissionScene({
    super.key,
    required this.visual,
    this.stepId,
    this.gender = ChildGender.girl,
    this.choices = const [],
    this.rejectedChoiceIds = const {},
    this.selectedChoice,
    this.onChoose,
  });

  final ChildGender gender;
  final MissionVisual visual;
  final String? stepId;
  final List<MissionChoice> choices;
  final Set<String> rejectedChoiceIds;
  final MissionChoice? selectedChoice;
  final ValueChanged<String>? onChoose;

  @override
  Widget build(BuildContext context) {
    final layout = missionSceneLayout(
      visual == MissionVisual.twoWalls ? null : stepId,
      visual,
    );
    if (stepId == 'outdoor_noise' ||
        stepId == 'outdoor_recover' ||
        visual == MissionVisual.getDown ||
        visual == MissionVisual.protectHead) {
      return MissionOutdoorActionScene(
        visual: visual,
        stepId: stepId,
        gender: gender,
        choices: choices,
        selectedChoice: selectedChoice,
        rejectedChoiceIds: rejectedChoiceIds,
        onChoose: onChoose,
        backdrop: _PortraitBackdrop(
          layout: layout,
          visual: visual,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: missionSceneSize.aspectRatio,
        child: LayoutBuilder(
          builder: (context, constraints) => FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Semantics(
                  label: _sceneDescription(visual, selectedChoice),
                  image: true,
                  child: _PortraitBackdrop(layout: layout, visual: visual),
                ),
                if (layout.childWidth > 0)
                  _character(context, constraints, layout),
                if (visual == MissionVisual.alarm ||
                    visual == MissionVisual.allClear)
                  _phoneSignal(constraints),
                IgnorePointer(
                  child: CustomPaint(
                    painter: MissionObjectHighlights(
                      layout: layout,
                      stepId: stepId,
                      choices: choices,
                      selectedChoice: selectedChoice,
                      rejectedChoiceIds: rejectedChoiceIds,
                      visual: visual,
                    ),
                  ),
                ),
                for (var index = 0; index < choices.length; index++)
                  if (layout.targets[choices[index].id] case final target?)
                    _target(constraints, target, choices[index], index),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _phoneSignal(BoxConstraints constraints) => Positioned(
    left: constraints.maxWidth * .405,
    top: constraints.maxHeight * .20,
    width: constraints.maxWidth * .19,
    height: constraints.maxHeight * .16,
    child: ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BaseboundColors.border),
        ),
        child: BaseboundIcon(
          visual == MissionVisual.alarm
              ? BaseboundIconName.alarm
              : BaseboundIconName.check,
          size: 34,
          color: visual == MissionVisual.alarm
              ? BaseboundColors.blue
              : BaseboundColors.green,
        ),
      ),
    ),
  );

  Widget _target(
    BoxConstraints constraints,
    Rect target,
    MissionChoice choice,
    int index,
  ) {
    final rejected =
        rejectedChoiceIds.contains(choice.id) ||
        (visual == MissionVisual.quiet &&
            selectedChoice != null &&
            choice.id == 'leave');
    final width = math.max(49.0, target.width * constraints.maxWidth);
    final height = math.max(49.0, target.height * constraints.maxHeight);
    return Positioned(
      left: math.min(
        target.left * constraints.maxWidth,
        constraints.maxWidth - width,
      ),
      top: math.min(
        target.top * constraints.maxHeight,
        constraints.maxHeight - height,
      ),
      width: width,
      height: height,
      child: FocusTraversalOrder(
        order: NumericFocusOrder(index.toDouble()),
        child: SceneObjectTarget(
          label: choice.label,
          selected: selectedChoice?.id == choice.id,
          rejected: rejected,
          onTap: onChoose == null || rejected
              ? null
              : () => onChoose!(choice.id),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  Widget _character(
    BuildContext context,
    BoxConstraints constraints,
    MissionSceneLayout layout,
  ) {
    final destination =
        selectedChoice?.isCorrect == true ||
            selectedChoice?.continuesAfterFeedback == true
        ? layout.destinations[selectedChoice?.id]
        : null;
    final feet = destination ?? layout.childFeet;
    final extent =
        (destination == null
            ? layout.childWidth
            : layout.selectedChildWidth ?? layout.childWidth) *
        constraints.maxWidth;
    final pose = _characterPose(layout, selectedChoice, destination != null);
    return AnimatedPositioned(
      key: const ValueKey('mission-character'),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      left: feet.dx * constraints.maxWidth - extent / 2,
      top: feet.dy * constraints.maxHeight - extent,
      width: extent,
      height: extent,
      child: ExcludeSemantics(
        child: Transform.flip(
          flipX: destination != null && destination.dx < layout.childFeet.dx,
          child: ChildCharacter(pose: pose, gender: gender),
        ),
      ),
    );
  }
}

class _PortraitBackdrop extends StatelessWidget {
  const _PortraitBackdrop({
    required this.layout,
    required this.visual,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  final MissionSceneLayout layout;
  final MissionVisual visual;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final fallback = layout.family == MissionVisual.apartment
        ? const MissionHomePlan()
        : CustomPaint(painter: _PortraitScenePainter(layout.family, visual));
    return ExcludeSemantics(
      child: layout.asset == null
          ? fallback
          : Image.asset(
              layout.asset!,
              fit: fit,
              alignment: alignment,
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) => fallback,
            ),
    );
  }
}

ChildPoseName _characterPose(
  MissionSceneLayout layout,
  MissionChoice? choice,
  bool moving,
) {
  if (layout.family == MissionVisual.protectHead) {
    return choice?.isCorrect == true
        ? ChildPoseName.protect
        : ChildPoseName.crouch;
  }
  if (layout.family == MissionVisual.getDown && choice?.isCorrect == true) {
    return ChildPoseName.crouch;
  }
  return moving ? ChildPoseName.walk : ChildPoseName.stand;
}

String _sceneDescription(MissionVisual visual, MissionChoice? choice) {
  if (visual == MissionVisual.street &&
      choice?.continuesAfterFeedback == true) {
    return 'The child has started along the street and is still outside.';
  }
  if (choice?.isCorrect == false) choice = null;
  if (choice?.icon == MissionActionIcon.window) {
    return 'The child has moved toward the window.';
  }
  if (choice?.icon == MissionActionIcon.door ||
      choice?.icon == MissionActionIcon.leave) {
    return 'The child has moved toward the door.';
  }
  return switch (visual) {
    MissionVisual.alarm => 'A child playing at home. A phone shows an alarm.',
    MissionVisual.room => 'A room with a window, an inside area, and a door.',
    MissionVisual.apartment => 'A home seen from above. Three rooms have windows. The hallway is inside.',
    MissionVisual.twoWalls =>
      'The child, one wall, another wall, then outside.',
    MissionVisual.contacts => 'Pretend family faces on the child’s phone.',
    MissionVisual.communication => 'A pretend phone with a call and a message.',
    MissionVisual.message => 'A pretend message and a reply from an adult.',
    MissionVisual.sheltered ||
    MissionVisual.quiet => 'The child is waiting in an inside room.',
    MissionVisual.allClear => 'A pretend phone shows the all-clear.',
    MissionVisual.recall => 'Pictures of the six actions practiced.',
    MissionVisual.street =>
      'A street with home and school far away and a solid building nearby.',
    MissionVisual.getDown =>
      choice?.isCorrect == true
          ? 'The child has got down low.'
          : 'The child is standing outdoors.',
    MissionVisual.protectHead =>
      choice?.isCorrect == true
          ? 'The child covers their head with both arms.'
          : 'The child is down low with their arms by their side.',
  };
}

/// Native portrait fallback also supplies phone and home-plan scenes.
class _PortraitScenePainter extends CustomPainter {
  _PortraitScenePainter(this.family, this.visual);

  final MissionVisual family;
  final MissionVisual visual;
  static const wood = Color(0xFFC99A68);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 400, size.height / 600);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 400, 600),
      Paint()..color = BaseboundColors.cream,
    );
    switch (family) {
      case MissionVisual.apartment:
        const MissionHomePlanPainter().paint(canvas, missionSceneSize);
      case MissionVisual.street:
        _street(canvas);
      case MissionVisual.contacts:
      case MissionVisual.communication:
      case MissionVisual.message:
        _phone(canvas);
      case MissionVisual.getDown:
      case MissionVisual.protectHead:
        _street(canvas);
      case MissionVisual.twoWalls:
        _walls(canvas);
      case MissionVisual.sheltered:
      case MissionVisual.quiet:
        _hallway(canvas);
      case MissionVisual.recall:
        _recall(canvas);
      default:
        _room(canvas);
    }
    canvas.restore();
  }

  void _panel(Canvas canvas, Rect bounds, Color color, {double radius = 18}) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds, Radius.circular(radius)),
      Paint()..color = color,
    );
  }

  void _line(
    Canvas canvas,
    Offset start,
    Offset end, {
    Color color = wood,
    double width = 5,
  }) {
    canvas.drawLine(
      start,
      end,
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  void _symbol(
    Canvas canvas,
    BaseboundIconName name,
    Rect bounds, {
    Color? color,
  }) => paintBaseboundIcon(canvas, bounds, name, color: color);

  void _window(Canvas canvas, Rect bounds) {
    _panel(canvas, bounds.inflate(7), Colors.white, radius: 4);
    _panel(canvas, bounds, const Color(0xFFBBE6FA), radius: 2);
    _line(canvas, bounds.topCenter, bounds.bottomCenter, color: Colors.white);
    _line(canvas, bounds.centerLeft, bounds.centerRight, color: Colors.white);
    _panel(
      canvas,
      Rect.fromLTWH(bounds.left - 15, bounds.top - 8, 15, bounds.height + 30),
      const Color(0xFFCBB9E7),
      radius: 6,
    );
    _panel(
      canvas,
      Rect.fromLTWH(bounds.right, bounds.top - 8, 15, bounds.height + 30),
      const Color(0xFFCBB9E7),
      radius: 6,
    );
  }

  void _room(Canvas canvas) {
    _panel(
      canvas,
      const Rect.fromLTWH(0, 395, 400, 205),
      const Color(0xFFE3B783),
      radius: 0,
    );
    for (var x = 0.0; x < 450; x += 60) {
      _line(
        canvas,
        Offset(x, 395),
        Offset(x - 70, 600),
        width: 2,
        color: const Color(0xFFC99A68),
      );
    }
    _window(canvas, const Rect.fromLTWH(28, 95, 108, 140));
    _panel(canvas, const Rect.fromLTWH(272, 95, 116, 300), wood, radius: 6);
    _panel(
      canvas,
      const Rect.fromLTWH(282, 105, 88, 290),
      const Color(0xFFAADAEC),
      radius: 2,
    );
    _symbol(
      canvas,
      BaseboundIconName.park,
      const Rect.fromLTWH(288, 150, 80, 80),
      color: const Color(0xFF60A865),
    );
    _panel(
      canvas,
      const Rect.fromLTWH(148, 145, 106, 250),
      const Color(0xFFC69D79),
      radius: 6,
    );
    _panel(
      canvas,
      const Rect.fromLTWH(158, 155, 86, 240),
      BaseboundColors.cream,
      radius: 2,
    );
    _symbol(
      canvas,
      BaseboundIconName.hallway,
      const Rect.fromLTWH(173, 249, 56, 60),
    );
    _symbol(
      canvas,
      BaseboundIconName.park,
      const Rect.fromLTWH(16, 401, 65, 85),
      color: BaseboundColors.green,
    );
    _panel(canvas, const Rect.fromLTWH(20, 480, 67, 40), wood, radius: 8);
    _line(canvas, const Offset(203, 0), const Offset(203, 72), width: 3);
    _panel(
      canvas,
      const Rect.fromLTWH(169, 70, 68, 28),
      const Color(0xFFFFCE78),
      radius: 20,
    );
    if (visual == MissionVisual.alarm || visual == MissionVisual.allClear) {
      _panel(
        canvas,
        const Rect.fromLTWH(151, 144, 92, 110),
        Colors.white,
        radius: 24,
      );
      _symbol(
        canvas,
        visual == MissionVisual.alarm
            ? BaseboundIconName.alarm
            : BaseboundIconName.check,
        const Rect.fromLTWH(170, 163, 55, 55),
      );
    }
  }

  void _planWall(Canvas canvas, Offset start, Offset end, {double width = 6}) =>
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = BaseboundColors.muted
          ..strokeWidth = width
          ..strokeCap = StrokeCap.square,
      );

  void _outlinedPanel(
    Canvas canvas,
    Rect bounds, {
    Color color = BaseboundColors.peach,
    double radius = 4,
  }) {
    final shape = RRect.fromRectAndRadius(bounds, Radius.circular(radius));
    canvas.drawRRect(shape, Paint()..color = color);
    canvas.drawRRect(
      shape,
      Paint()
        ..color = BaseboundColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _street(Canvas canvas) {
    _panel(
      canvas,
      const Rect.fromLTWH(0, 0, 400, 600),
      const Color(0xFFCAEAFB),
      radius: 0,
    );
    _panel(
      canvas,
      const Rect.fromLTWH(0, 250, 400, 350),
      const Color(0xFFD5EABD),
      radius: 0,
    );
    final road = Path()
      ..moveTo(168, 120)
      ..lineTo(208, 120)
      ..lineTo(267, 600)
      ..lineTo(79, 600)
      ..close();
    canvas.drawPath(road, Paint()..color = const Color(0xFFD9CED0));
    _building(
      canvas,
      const Rect.fromLTWH(18, 70, 124, 110),
      BaseboundIconName.home,
    );
    _building(
      canvas,
      const Rect.fromLTWH(255, 44, 127, 128),
      BaseboundIconName.school,
    );
    _building(
      canvas,
      const Rect.fromLTWH(258, 264, 127, 143),
      BaseboundIconName.shelter,
    );
    _symbol(
      canvas,
      BaseboundIconName.park,
      const Rect.fromLTWH(30, 307, 100, 100),
      color: BaseboundColors.green,
    );
    _symbol(
      canvas,
      BaseboundIconName.busStop,
      const Rect.fromLTWH(286, 431, 81, 100),
    );
    _line(
      canvas,
      const Offset(185, 198),
      const Offset(188, 261),
      color: Colors.white,
      width: 4,
    );
    _line(
      canvas,
      const Offset(180, 390),
      const Offset(172, 443),
      color: Colors.white,
      width: 4,
    );
  }

  void _building(Canvas canvas, Rect bounds, BaseboundIconName name) {
    _panel(canvas, bounds, const Color(0xFFF7E8CA), radius: 9);
    _panel(
      canvas,
      Rect.fromLTWH(bounds.left - 5, bounds.top - 7, bounds.width + 10, 15),
      const Color(0xFFBA8663),
      radius: 3,
    );
    _symbol(
      canvas,
      name,
      Rect.fromCenter(center: bounds.center, width: 63, height: 63),
    );
  }

  void _phone(Canvas canvas) {
    _outlinedPanel(
      canvas,
      const Rect.fromLTWH(52, 20, 296, 530),
      color: Colors.white,
      radius: 28,
    );
    _line(
      canvas,
      const Offset(80, 106),
      const Offset(320, 106),
      color: BaseboundColors.border,
      width: 1,
    );
    canvas.drawCircle(
      const Offset(200, 43),
      3,
      Paint()..color = BaseboundColors.muted,
    );
    _symbol(
      canvas,
      BaseboundIconName.family,
      const Rect.fromLTWH(184, 62, 32, 28),
    );
    if (family == MissionVisual.message) {
      _messageBubble(canvas, const Rect.fromLTWH(83, 157, 203, 91));
      _messageBubble(
        canvas,
        const Rect.fromLTWH(114, 316, 203, 91),
        reply: true,
      );
    } else if (family == MissionVisual.contacts) {
      const contacts = [
        BaseboundIconName.mother,
        BaseboundIconName.father,
        BaseboundIconName.grandparent,
      ];
      for (var index = 0; index < contacts.length; index++) {
        final top = 124.0 + index * 126;
        canvas.drawCircle(
          Offset(200, top + 42),
          25,
          Paint()..color = BaseboundColors.peach,
        );
        _symbol(canvas, contacts[index], Rect.fromLTWH(183, top + 24, 34, 36));
      }
    } else {
      _symbol(
        canvas,
        BaseboundIconName.phone,
        const Rect.fromLTWH(99, 190, 34, 36),
      );
      _phoneTextLines(canvas, const Offset(162, 200), width: 136);
      _line(
        canvas,
        const Offset(83, 283),
        const Offset(317, 283),
        color: BaseboundColors.border,
        width: 1,
      );
      _symbol(
        canvas,
        BaseboundIconName.message,
        const Rect.fromLTWH(99, 351, 34, 36),
      );
      _phoneTextLines(canvas, const Offset(162, 361), width: 136);
    }
    _line(
      canvas,
      const Offset(168, 523),
      const Offset(232, 523),
      color: BaseboundColors.muted,
      width: 3,
    );
  }

  void _phoneTextLines(Canvas canvas, Offset start, {required double width}) {
    _line(
      canvas,
      start,
      start.translate(width, 0),
      color: BaseboundColors.muted,
      width: 3,
    );
    _line(
      canvas,
      start.translate(0, 17),
      start.translate(width * .65, 17),
      color: BaseboundColors.border,
      width: 2,
    );
  }

  void _messageBubble(Canvas canvas, Rect bounds, {bool reply = false}) {
    _outlinedPanel(
      canvas,
      bounds,
      color: reply ? BaseboundColors.peach : BaseboundColors.sky,
      radius: 12,
    );
    _phoneTextLines(canvas, bounds.topLeft.translate(20, 27), width: 160);
    _symbol(
      canvas,
      reply ? BaseboundIconName.messageRead : BaseboundIconName.message,
      Rect.fromLTWH(bounds.right - 41, bounds.bottom - 32, 22, 20),
    );
  }

  void _hallway(Canvas canvas) {
    final floor = Path()
      ..moveTo(148, 252)
      ..lineTo(250, 252)
      ..lineTo(400, 600)
      ..lineTo(0, 600)
      ..close();
    canvas.drawPath(floor, Paint()..color = const Color(0xFFE9BE88));
    _line(canvas, const Offset(148, 0), const Offset(148, 252));
    _line(canvas, const Offset(250, 0), const Offset(250, 252));
    _panel(canvas, const Rect.fromLTWH(163, 87, 74, 168), wood, radius: 3);
    _panel(canvas, const Rect.fromLTWH(272, 128, 104, 205), wood, radius: 5);
    _panel(canvas, const Rect.fromLTWH(27, 114, 99, 219), wood, radius: 5);
    _symbol(
      canvas,
      BaseboundIconName.wait,
      const Rect.fromLTWH(169, 307, 63, 63),
    );
    _symbol(
      canvas,
      BaseboundIconName.park,
      const Rect.fromLTWH(325, 405, 60, 80),
      color: BaseboundColors.green,
    );
  }

  void _walls(Canvas canvas) {
    _panel(
      canvas,
      const Rect.fromLTWH(24, 130, 272, 312),
      Colors.white,
      radius: 0,
    );
    _panel(
      canvas,
      const Rect.fromLTWH(308, 130, 68, 312),
      BaseboundColors.sky,
      radius: 0,
    );
    _panel(
      canvas,
      const Rect.fromLTWH(24, 442, 284, 14),
      BaseboundColors.peach,
      radius: 0,
    );
    _planWall(canvas, const Offset(24, 130), const Offset(308, 130), width: 3);
    _planWall(canvas, const Offset(24, 442), const Offset(376, 442), width: 3);

    // The child occupies x=32..200. Both uninterrupted walls lie between
    // that position and the outdoor strip, which starts beyond the second wall.
    _cutawayWall(canvas, const Rect.fromLTWH(214, 130, 12, 312));
    _cutawayWall(canvas, const Rect.fromLTWH(296, 130, 12, 312));
    _line(
      canvas,
      const Offset(350, 368),
      const Offset(350, 436),
      color: BaseboundColors.muted,
      width: 3,
    );
    final tree = Path()
      ..moveTo(350, 283)
      ..cubicTo(326, 309, 331, 334, 326, 358)
      ..quadraticBezierTo(350, 373, 374, 358)
      ..cubicTo(369, 334, 374, 309, 350, 283)
      ..close();
    canvas.drawPath(tree, Paint()..color = BaseboundColors.greenLight);
    canvas.drawPath(
      tree,
      Paint()
        ..color = BaseboundColors.muted
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    _line(
      canvas,
      const Offset(329, 432),
      const Offset(367, 432),
      color: BaseboundColors.border,
      width: 1.5,
    );
  }

  void _cutawayWall(Canvas canvas, Rect bounds) {
    canvas.drawRect(bounds, Paint()..color = BaseboundColors.border);
    canvas.drawRect(
      bounds,
      Paint()
        ..color = BaseboundColors.muted
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    for (var top = bounds.top + 12; top < bounds.bottom; top += 20) {
      _line(
        canvas,
        Offset(bounds.left + 2, top),
        Offset(bounds.right - 2, top - 8),
        color: BaseboundColors.muted,
        width: 1,
      );
    }
  }

  void _recall(Canvas canvas) {
    const symbols = [
      BaseboundIconName.alarm,
      BaseboundIconName.window,
      BaseboundIconName.hallway,
      BaseboundIconName.message,
      BaseboundIconName.wait,
      BaseboundIconName.check,
    ];
    for (var index = 0; index < symbols.length; index++) {
      final center = Offset(
        index.isEven ? 115 : 285,
        98.0 + (index ~/ 2) * 196,
      );
      _outlinedPanel(
        canvas,
        Rect.fromCenter(center: center, width: 112, height: 112),
        color: Colors.white,
        radius: 12,
      );
      _symbol(
        canvas,
        symbols[index],
        Rect.fromCenter(center: center, width: 40, height: 40),
      );
      if (index < symbols.length - 1) {
        _symbol(
          canvas,
          BaseboundIconName.next,
          Rect.fromLTWH(188, center.dy + (index.isEven ? -10 : 78), 24, 24),
          color: BaseboundColors.muted,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PortraitScenePainter oldDelegate) =>
      family != oldDelegate.family || visual != oldDelegate.visual;
}

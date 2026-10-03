import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import 'air_raid_mission.dart';
import 'mission_choice_card.dart';
import 'mission_scene_layout.dart';

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

/// Portrait art, the child and native actions share one source coordinate space.
class MissionScene extends StatelessWidget {
  const MissionScene({
    super.key,
    required this.visual,
    this.stepId,
    this.choices = const [],
    this.selectedChoice,
    this.onChoose,
  });

  final MissionVisual visual;
  final String? stepId;
  final List<MissionChoice> choices;
  final MissionChoice? selectedChoice;
  final ValueChanged<String>? onChoose;

  @override
  Widget build(BuildContext context) {
    final layout = missionSceneLayout(
      visual == MissionVisual.twoWalls ? null : stepId,
      visual,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
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
                for (var index = 0; index < choices.length; index++)
                  if (layout.targets[choices[index].id] case final target?)
                    _target(
                      constraints,
                      selectedChoice?.id == choices[index].id
                          ? layout.selectedTargets[choices[index].id] ?? target
                          : target,
                      choices[index],
                      index,
                    ),
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
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: BaseboundColors.ink, width: 3),
          boxShadow: const [BoxShadow(color: Color(0x22112568), blurRadius: 8)],
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
  ) => Positioned(
    left: target.left * constraints.maxWidth,
    top: target.top * constraints.maxHeight,
    width: target.width * constraints.maxWidth,
    height: target.height * constraints.maxHeight,
    child: FocusTraversalOrder(
      order: NumericFocusOrder(index.toDouble()),
      child: _SceneChoice(
        choice: choice,
        selected: selectedChoice?.id == choice.id,
        onTap: onChoose == null ? null : () => onChoose!(choice.id),
        showIllustration:
            visual == MissionVisual.contacts ||
            visual == MissionVisual.communication,
      ),
    ),
  );

  Widget _character(
    BuildContext context,
    BoxConstraints constraints,
    MissionSceneLayout layout,
  ) {
    final destination = layout.destinations[selectedChoice?.id];
    final feet = destination ?? layout.childFeet;
    final extent =
        (destination == null
            ? layout.childWidth
            : layout.selectedChildWidth ?? layout.childWidth) *
        constraints.maxWidth;
    final pose = _characterPose(layout, selectedChoice, destination != null);
    return AnimatedPositioned(
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
          child: _ChildPose(pose: pose),
        ),
      ),
    );
  }
}

class _PortraitBackdrop extends StatelessWidget {
  const _PortraitBackdrop({required this.layout, required this.visual});

  final MissionSceneLayout layout;
  final MissionVisual visual;

  @override
  Widget build(BuildContext context) {
    final fallback = CustomPaint(
      painter: _PortraitScenePainter(layout.family, visual),
    );
    return ExcludeSemantics(
      child: layout.asset == null
          ? fallback
          : Image.asset(
              layout.asset!,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) => fallback,
            ),
    );
  }
}

/// Text belongs to the pictured object; its generous invisible hit area stays
/// independent of the small caption. Only phone contacts need a separate image.
class _SceneChoice extends StatelessWidget {
  const _SceneChoice({
    required this.choice,
    required this.selected,
    required this.onTap,
    required this.showIllustration,
  });

  final MissionChoice choice;
  final bool selected;
  final VoidCallback? onTap;
  final bool showIllustration;

  @override
  Widget build(BuildContext context) {
    final accent = choice.isCorrect
        ? BaseboundColors.green
        : BaseboundColors.coral;
    return Semantics(
      button: true,
      enabled: onTap != null,
      onTap: onTap,
      selected: selected,
      label: choice.label,
      child: ExcludeSemantics(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            focusColor: BaseboundColors.sky.withValues(alpha: .8),
            splashColor: BaseboundColors.sky.withValues(alpha: .5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 1.05,
                    colors: [
                      BaseboundColors.cream.withValues(alpha: .96),
                      BaseboundColors.cream.withValues(alpha: .83),
                      BaseboundColors.cream.withValues(alpha: 0),
                    ],
                    stops: const [0, .55, 1],
                  ),
                ),
                child: selected
                    ? Row(
                        children: [
                          BaseboundIcon(
                            choice.isCorrect
                                ? BaseboundIconName.check
                                : BaseboundIconName.cross,
                            size: 22,
                            color: accent,
                          ),
                          const SizedBox(width: 5),
                          Expanded(child: _label(compact: true)),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showIllustration) ...[
                            BaseboundIcon(
                              missionActionIcon(choice.icon),
                              size: 34,
                            ),
                            const SizedBox(height: 2),
                          ],
                          Flexible(child: _label()),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label({bool compact = false}) => Text(
    choice.label,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontFamily: 'Nunito',
      fontSize: compact ? 14 : 17,
      fontWeight: FontWeight.w800,
      color: BaseboundColors.ink,
      height: 1.12,
      shadows: const [Shadow(color: Colors.white, blurRadius: 7)],
      decoration: selected ? TextDecoration.none : TextDecoration.underline,
      decorationColor: BaseboundColors.ink.withValues(alpha: .3),
      decorationThickness: 1,
    ),
  );
}

enum _ChildPoseName { stand, walk, crouch, protect }

_ChildPoseName _characterPose(
  MissionSceneLayout layout,
  MissionChoice? choice,
  bool moving,
) {
  if (layout.family == MissionVisual.protectHead) {
    return choice?.isCorrect == true
        ? _ChildPoseName.protect
        : _ChildPoseName.crouch;
  }
  if (layout.family == MissionVisual.getDown && choice?.isCorrect == true) {
    return _ChildPoseName.crouch;
  }
  return moving ? _ChildPoseName.walk : _ChildPoseName.stand;
}

/// Source crops preserve the sheet's pose heights and transparent padding.
class _ChildPose extends StatelessWidget {
  const _ChildPose({required this.pose});

  final _ChildPoseName pose;

  static const _sourceRects = [
    Rect.fromLTWH(161, 17, 308, 672),
    Rect.fromLTWH(773, 27, 335, 658),
    Rect.fromLTWH(194, 759, 291, 434),
    Rect.fromLTWH(780, 782, 304, 416),
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final source = _sourceRects[pose.index];
      final scale = constraints.maxHeight / _sourceRects.first.height;
      return Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: source.width * scale,
          height: source.height * scale,
          child: ClipRect(
            child: Stack(
              children: [
                Positioned(
                  left: -source.left * scale,
                  top: -source.top * scale,
                  width: 1254 * scale,
                  height: 1254 * scale,
                  child: Image.asset(
                    'assets/illustrations/child-poses.png',
                    fit: BoxFit.fill,
                    excludeFromSemantics: true,
                    errorBuilder: (_, _, _) => CustomPaint(
                      painter: _ChildFallbackPainter(pose, source),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

String _sceneDescription(MissionVisual visual, MissionChoice? choice) {
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
  static const ink = BaseboundColors.ink;
  static const wood = Color(0xFFC99A68);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 400, size.height / 600);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 400, 600),
      Paint()
        ..shader = const LinearGradient(
          colors: [BaseboundColors.cream, BaseboundColors.peach],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(const Rect.fromLTWH(0, 0, 400, 600)),
    );
    switch (family) {
      case MissionVisual.apartment:
        _homePlan(canvas);
      case MissionVisual.street:
        _street(canvas);
      case MissionVisual.contacts:
      case MissionVisual.communication:
      case MissionVisual.message:
        _phone(canvas);
      case MissionVisual.getDown:
      case MissionVisual.protectHead:
        _bodyPractice(canvas);
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
    _panel(canvas, const Rect.fromLTWH(272, 95, 116, 249), wood, radius: 6);
    _panel(
      canvas,
      const Rect.fromLTWH(282, 105, 88, 229),
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
      const Rect.fromLTWH(289, 421, 98, 175),
      const Color(0xFFC69D79),
      radius: 6,
    );
    _panel(
      canvas,
      const Rect.fromLTWH(299, 431, 76, 165),
      BaseboundColors.cream,
      radius: 2,
    );
    _symbol(
      canvas,
      BaseboundIconName.hallway,
      const Rect.fromLTWH(308, 438, 60, 60),
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

  void _homePlan(Canvas canvas) {
    _panel(canvas, const Rect.fromLTWH(10, 30, 380, 545), wood, radius: 18);
    _panel(
      canvas,
      const Rect.fromLTWH(22, 43, 165, 222),
      const Color(0xFFF9EDD7),
    );
    _panel(
      canvas,
      const Rect.fromLTWH(214, 43, 165, 222),
      const Color(0xFFF0E5FA),
    );
    _panel(
      canvas,
      const Rect.fromLTWH(22, 316, 165, 247),
      const Color(0xFFE5F1FB),
    );
    _panel(
      canvas,
      const Rect.fromLTWH(214, 316, 165, 247),
      const Color(0xFFFFE9CF),
    );
    _panel(
      canvas,
      const Rect.fromLTWH(187, 50, 27, 505),
      BaseboundColors.cream,
      radius: 2,
    );
    _panel(
      canvas,
      const Rect.fromLTWH(22, 265, 357, 51),
      BaseboundColors.cream,
      radius: 2,
    );
    _window(canvas, const Rect.fromLTWH(65, 36, 80, 35));
    _window(canvas, const Rect.fromLTWH(265, 36, 80, 35));
    _window(canvas, const Rect.fromLTWH(18, 348, 31, 75));
    _symbol(
      canvas,
      visual == MissionVisual.sheltered
          ? BaseboundIconName.window
          : BaseboundIconName.livingRoom,
      const Rect.fromLTWH(65, 85, 80, 70),
    );
    _symbol(
      canvas,
      visual == MissionVisual.sheltered
          ? BaseboundIconName.door
          : BaseboundIconName.bedroom,
      const Rect.fromLTWH(265, 85, 80, 70),
    );
    _symbol(
      canvas,
      BaseboundIconName.kitchen,
      const Rect.fromLTWH(64, 339, 80, 70),
    );
    _symbol(
      canvas,
      BaseboundIconName.hallway,
      const Rect.fromLTWH(265, 339, 80, 70),
    );
    _panel(canvas, const Rect.fromLTWH(220, 306, 83, 15), wood, radius: 3);
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
    _panel(
      canvas,
      const Rect.fromLTWH(43, 28, 314, 535),
      const Color(0x180F2568),
      radius: 43,
    );
    _panel(canvas, const Rect.fromLTWH(52, 20, 296, 530), ink, radius: 40);
    _panel(
      canvas,
      const Rect.fromLTWH(66, 35, 268, 499),
      Colors.white,
      radius: 30,
    );
    _panel(
      canvas,
      const Rect.fromLTWH(67, 35, 266, 72),
      BaseboundColors.sky,
      radius: 26,
    );
    _panel(canvas, const Rect.fromLTWH(161, 41, 78, 8), ink, radius: 8);
    _symbol(
      canvas,
      BaseboundIconName.family,
      const Rect.fromLTWH(168, 58, 65, 40),
    );
    if (family == MissionVisual.message) {
      _panel(
        canvas,
        const Rect.fromLTWH(89, 158, 222, 114),
        BaseboundColors.sky,
      );
      _symbol(
        canvas,
        BaseboundIconName.message,
        const Rect.fromLTWH(168, 183, 63, 63),
      );
      _panel(
        canvas,
        const Rect.fromLTWH(89, 321, 222, 114),
        BaseboundColors.greenLight,
      );
      _symbol(
        canvas,
        BaseboundIconName.messageRead,
        const Rect.fromLTWH(168, 346, 63, 63),
      );
    } else if (family == MissionVisual.contacts) {
      for (final top in [124.0, 250.0, 376.0]) {
        _panel(
          canvas,
          Rect.fromLTWH(79, top, 242, 99),
          BaseboundColors.sky,
          radius: 20,
        );
      }
    } else {
      _symbol(
        canvas,
        BaseboundIconName.phone,
        const Rect.fromLTWH(161, 191, 80, 85),
      );
      _symbol(
        canvas,
        BaseboundIconName.message,
        const Rect.fromLTWH(161, 353, 80, 85),
      );
    }
    _panel(canvas, const Rect.fromLTWH(162, 509, 77, 7), ink, radius: 4);
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

  void _bodyPractice(Canvas canvas) {
    _panel(
      canvas,
      const Rect.fromLTWH(0, 0, 400, 600),
      const Color(0xFFD2ECFA),
      radius: 0,
    );
    _panel(
      canvas,
      const Rect.fromLTWH(0, 314, 400, 286),
      const Color(0xFFE1D1B9),
      radius: 0,
    );
    _building(
      canvas,
      const Rect.fromLTWH(264, 52, 119, 163),
      BaseboundIconName.shelter,
    );
    _symbol(
      canvas,
      family == MissionVisual.getDown
          ? BaseboundIconName.down
          : BaseboundIconName.protectHead,
      const Rect.fromLTWH(32, 102, 80, 80),
      color: BaseboundColors.blue,
    );
    _panel(
      canvas,
      const Rect.fromLTWH(28, 540, 344, 23),
      const Color(0xFFC7B79F),
      radius: 10,
    );
  }

  void _walls(Canvas canvas) {
    _panel(
      canvas,
      const Rect.fromLTWH(255, 0, 145, 600),
      const Color(0xFFCCE9FA),
      radius: 0,
    );
    _panel(
      canvas,
      const Rect.fromLTWH(10, 155, 200, 350),
      BaseboundColors.cream,
    );
    _panel(canvas, const Rect.fromLTWH(216, 60, 17, 460), wood, radius: 3);
    _panel(canvas, const Rect.fromLTWH(291, 60, 17, 460), wood, radius: 3);
    _symbol(
      canvas,
      BaseboundIconName.park,
      const Rect.fromLTWH(327, 190, 65, 88),
      color: BaseboundColors.green,
    );
    _symbol(
      canvas,
      BaseboundIconName.hallway,
      const Rect.fromLTWH(63, 218, 103, 100),
    );
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
      canvas.drawCircle(center, 66, Paint()..color = Colors.white);
      _symbol(
        canvas,
        symbols[index],
        Rect.fromCenter(center: center, width: 74, height: 74),
      );
      if (index < symbols.length - 1) {
        _symbol(
          canvas,
          BaseboundIconName.next,
          Rect.fromLTWH(188, center.dy + (index.isEven ? -14 : 72), 28, 28),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PortraitScenePainter oldDelegate) =>
      family != oldDelegate.family || visual != oldDelegate.visual;
}

class _ChildFallbackPainter extends CustomPainter {
  _ChildFallbackPainter(this.pose, this.source);

  final _ChildPoseName pose;
  final Rect source;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 1254, size.height / 1254);
    canvas.translate(source.left, source.top);
    canvas.scale(source.width / 100, source.height / 100);
    final low = pose == _ChildPoseName.crouch || pose == _ChildPoseName.protect;
    const skin = Color(0xFFF6CAA7);
    const hair = Color(0xFF724127);
    const shirt = Color(0xFFB961BE);
    final head = Offset(low ? 48 : 50, low ? 57 : 24);
    canvas.drawOval(
      Rect.fromCenter(center: head + const Offset(0, 3), width: 40, height: 47),
      Paint()..color = hair,
    );
    canvas.drawCircle(head, 16, Paint()..color = skin);
    canvas.drawPath(
      Path()
        ..moveTo(head.dx - 17, head.dy - 5)
        ..quadraticBezierTo(
          head.dx - 4,
          head.dy - 25,
          head.dx + 18,
          head.dy - 5,
        )
        ..quadraticBezierTo(
          head.dx + 3,
          head.dy - 10,
          head.dx - 17,
          head.dy - 5,
        ),
      Paint()..color = hair,
    );
    for (final dx in [-6.0, 6.0]) {
      canvas.drawCircle(
        head + Offset(dx, 1),
        2.4,
        Paint()..color = BaseboundColors.ink,
      );
    }
    final body = Rect.fromLTWH(
      low ? 37 : 36,
      low ? 72 : 43,
      low ? 42 : 28,
      low ? 15 : 26,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(8)),
      Paint()..color = shirt,
    );
    _limb(
      canvas,
      Offset(body.left, body.top + 6),
      pose == _ChildPoseName.protect
          ? head + const Offset(-10, -14)
          : Offset(body.left - 7, body.bottom),
      skin,
      7,
    );
    _limb(
      canvas,
      Offset(body.right, body.top + 6),
      pose == _ChildPoseName.protect
          ? head + const Offset(10, -14)
          : Offset(body.right + 6, body.bottom),
      skin,
      7,
    );
    final stride = pose == _ChildPoseName.walk ? 13.0 : 5.0;
    _limb(
      canvas,
      Offset(43, body.bottom - 1),
      Offset(43 - stride, 92),
      const Color(0xFF458BC5),
      10,
    );
    _limb(
      canvas,
      Offset(59, body.bottom - 1),
      Offset(59 + stride, 92),
      const Color(0xFF458BC5),
      10,
    );
    _limb(
      canvas,
      Offset(43 - stride - 3, 95),
      Offset(43 - stride + 4, 95),
      const Color(0xFF7E58A4),
      7,
    );
    _limb(
      canvas,
      Offset(59 + stride - 3, 95),
      Offset(59 + stride + 4, 95),
      const Color(0xFF7E58A4),
      7,
    );
    canvas.restore();
  }

  void _limb(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color,
    double width,
  ) => canvas.drawLine(
    start,
    end,
    Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round,
  );

  @override
  bool shouldRepaint(_ChildFallbackPainter oldDelegate) =>
      pose != oldDelegate.pose;
}

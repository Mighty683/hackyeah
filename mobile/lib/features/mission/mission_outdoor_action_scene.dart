import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../ui/basebound_ui.dart';
import '../parent/data/family_plan.dart';
import 'air_raid_mission.dart';

enum _OutdoorPose { standing, lowered, protected }

/// Keeps the street in view while making each physical action recognisable.
/// The poses share a ground line and scale; a lower pose is actually lower.
class MissionOutdoorActionScene extends StatelessWidget {
  const MissionOutdoorActionScene({
    super.key,
    required this.visual,
    required this.stepId,
    required this.gender,
    required this.choices,
    required this.selectedChoice,
    required this.rejectedChoiceIds,
    required this.onChoose,
    required this.backdrop,
  });

  final MissionVisual visual;
  final String? stepId;
  final ChildGender gender;
  final List<MissionChoice> choices;
  final MissionChoice? selectedChoice;
  final Set<String> rejectedChoiceIds;
  final ValueChanged<String>? onChoose;
  final Widget backdrop;

  _OutdoorPose _poseFor(String? choiceId) {
    if (stepId == 'outdoor_recover' || choiceId == 'protect_head') {
      return _OutdoorPose.protected;
    }
    if (visual == MissionVisual.protectHead || choiceId == 'down') {
      return _OutdoorPose.lowered;
    }
    return _OutdoorPose.standing;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final stackChoices = width < 200;
      final targetWidth = stackChoices ? width - 32 : (width - 48) / 2;
      final poseHeight = math.min(targetWidth, 156.0);
      final captionHeight = choices.fold<double>(48, (height, choice) {
        final painter = TextPainter(
          text: TextSpan(text: choice.label, style: _captionStyle),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: math.max(1, targetWidth - 16));
        final measuredHeight = painter.height + 24;
        painter.dispose();
        return math.max(height, measuredHeight);
      });
      final contextHeight = width * .38;
      final desiredHeight = choices.isEmpty
          ? width * .93
          : contextHeight +
                (poseHeight + captionHeight) *
                    (stackChoices ? choices.length : 1) +
                (stackChoices ? 16 * (choices.length - 1) : 0) +
                32;
      final height = constraints.hasBoundedHeight
          ? math.min(desiredHeight, constraints.maxHeight)
          : desiredHeight;
      final scene = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: width,
          height: height,
          child: SingleChildScrollView(
            child: SizedBox(
              height: choices.isEmpty ? height : desiredHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ExcludeSemantics(child: backdrop),
                  ExcludeSemantics(
                    child: CustomPaint(
                      painter: _StreetForegroundPainter(
                        soundCue: stepId == 'outdoor_noise',
                      ),
                    ),
                  ),
                  if (choices.isEmpty)
                    _currentPose()
                  else
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: FocusTraversalGroup(
                        policy: OrderedTraversalPolicy(),
                        child: Flex(
                          direction: stackChoices
                              ? Axis.vertical
                              : Axis.horizontal,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (
                              var index = 0;
                              index < choices.length;
                              index++
                            ) ...[
                              if (index > 0)
                                const SizedBox(width: 16, height: 16),
                              SizedBox(
                                width: targetWidth,
                                child: FocusTraversalOrder(
                                  order: NumericFocusOrder(index.toDouble()),
                                  child: _PoseChoice(
                                    choice: choices[index],
                                    pose: _poseFor(choices[index].id),
                                    gender: gender,
                                    poseHeight: poseHeight,
                                    captionHeight: captionHeight,
                                    rejected: rejectedChoiceIds.contains(
                                      choices[index].id,
                                    ),
                                    onTap:
                                        onChoose == null ||
                                            rejectedChoiceIds.contains(
                                              choices[index].id,
                                            )
                                        ? null
                                        : () => onChoose!(choices[index].id),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      // When content scrolls, a downward gesture must scroll, never answer.
      if (visual != MissionVisual.getDown ||
          choices.isEmpty ||
          onChoose == null ||
          desiredHeight > height) {
        return scene;
      }
      var dragDistance = 0.0;
      var chosen = false;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: (_) => dragDistance = 0,
        onVerticalDragUpdate: (details) {
          dragDistance += details.delta.dy;
          if (!chosen && dragDistance >= 48) {
            chosen = true;
            onChoose!('down');
          }
        },
        child: scene,
      );
    },
  );

  Widget _currentPose() {
    final pose = _poseFor(selectedChoice?.id);
    final withAdult = stepId == 'outdoor_recover';
    return Semantics(
      image: true,
      label: withAdult
          ? 'A trusted adult is nearby. The child stays down with their head covered.'
          : switch (pose) {
              _OutdoorPose.standing =>
                'The child is still outside on the same street.',
              _OutdoorPose.lowered => 'The child is down low on the street.',
              _OutdoorPose.protected =>
                'The child stays down and covers their head with both arms.',
            },
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (withAdult)
            const FractionallySizedBox(
              alignment: Alignment(-.6, .55),
              widthFactor: .36,
              heightFactor: .7,
              child: CustomPaint(
                painter: _OutdoorPosePainter(
                  _OutdoorPose.standing,
                  ChildGender.boy,
                  helper: true,
                ),
              ),
            ),
          FractionallySizedBox(
            alignment: Alignment(withAdult ? .5 : 0, .7),
            widthFactor: .55,
            heightFactor: .57,
            child: CustomPaint(painter: _OutdoorPosePainter(pose, gender)),
          ),
        ],
      ),
    );
  }
}

const _captionStyle = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 17,
  fontWeight: FontWeight.w700,
  height: 1.2,
  color: BaseboundColors.ink,
);

class _PoseChoice extends StatelessWidget {
  const _PoseChoice({
    required this.choice,
    required this.pose,
    required this.gender,
    required this.poseHeight,
    required this.captionHeight,
    required this.onTap,
    required this.rejected,
  });

  final MissionChoice choice;
  final _OutdoorPose pose;
  final ChildGender gender;
  final double poseHeight;
  final double captionHeight;
  final VoidCallback? onTap;
  final bool rejected;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onTap != null,
    onTap: onTap,
    label: choice.label,
    hint: rejected ? 'Try another choice.' : null,
    child: ExcludeSemantics(
      child: Material(
        color: rejected
            ? BaseboundColors.border
            : Colors.white.withValues(alpha: .92),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: BaseboundColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          focusColor: BaseboundColors.sky,
          splashColor: BaseboundColors.sky,
          child: Column(
            children: [
              SizedBox(
                height: poseHeight,
                width: double.infinity,
                child: CustomPaint(painter: _OutdoorPosePainter(pose, gender)),
              ),
              Container(
                constraints: BoxConstraints(minHeight: captionHeight),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: BaseboundColors.border),
                  ),
                ),
                child: Text(
                  choice.label,
                  textAlign: TextAlign.center,
                  style: _captionStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _StreetForegroundPainter extends CustomPainter {
  const _StreetForegroundPainter({required this.soundCue});

  final bool soundCue;

  @override
  void paint(Canvas canvas, Size size) {
    final ground = Path()
      ..moveTo(0, size.height * .42)
      ..quadraticBezierTo(
        size.width * .48,
        size.height * .33,
        size.width,
        size.height * .42,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(ground, Paint()..color = BaseboundColors.peach);
    final curb = Path()
      ..moveTo(0, size.height * .42)
      ..quadraticBezierTo(
        size.width * .48,
        size.height * .33,
        size.width,
        size.height * .42,
      );
    canvas.drawPath(
      curb,
      Paint()
        ..color = BaseboundColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    if (soundCue) {
      final center = Offset(size.width * .5, size.height * .28);
      for (final radius in [12.0, 22.0, 32.0]) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -.6,
          1.2,
          false,
          Paint()
            ..color = BaseboundColors.blue
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_StreetForegroundPainter oldDelegate) =>
      soundCue != oldDelegate.soundCue;
}

/// Simple side-view poses keep limbs and head-covering readable at small sizes.
class _OutdoorPosePainter extends CustomPainter {
  const _OutdoorPosePainter(this.pose, this.gender, {this.helper = false});

  final _OutdoorPose pose;
  final ChildGender gender;
  final bool helper;

  static const _skin = Color(0xFFE7B28F);
  static const _hair = Color(0xFF674535);
  static const _trousers = Color(0xFF577594);

  @override
  void paint(Canvas canvas, Size size) {
    final artHeight = helper ? 240.0 : 190.0;
    final scale = math.min(size.width / 180, size.height / artHeight);
    canvas.save();
    canvas.translate(
      (size.width - 180 * scale) / 2,
      size.height - artHeight * scale,
    );
    canvas.scale(scale);
    final groundY = helper ? 237.0 : 181.0;
    _line(
      canvas,
      Offset(18, groundY),
      Offset(162, groundY),
      BaseboundColors.border,
      2,
    );
    if (helper) {
      _helper(canvas);
    } else if (pose == _OutdoorPose.standing) {
      _standing(canvas);
    } else {
      _lowered(canvas, covered: pose == _OutdoorPose.protected);
    }
    canvas.restore();
  }

  Color get _shirt => gender == ChildGender.boy
      ? const Color(0xFF508C89)
      : const Color(0xFF946BA0);

  void _helper(Canvas canvas) {
    _line(canvas, const Offset(78, 143), const Offset(74, 226), _trousers, 15);
    _line(
      canvas,
      const Offset(101, 143),
      const Offset(109, 226),
      _trousers,
      15,
    );
    _line(
      canvas,
      const Offset(65, 231),
      const Offset(79, 231),
      BaseboundColors.ink,
      9,
    );
    _line(
      canvas,
      const Offset(104, 231),
      const Offset(119, 231),
      BaseboundColors.ink,
      9,
    );
    _line(
      canvas,
      const Offset(90, 71),
      const Offset(90, 140),
      BaseboundColors.blue,
      40,
    );
    _line(canvas, const Offset(69, 82), const Offset(59, 132), _skin, 10);
    _bentLimb(
      canvas,
      const [Offset(109, 82), Offset(127, 112), Offset(145, 103)],
      _skin,
      10,
    );
    _head(canvas, const Offset(90, 42), tilted: false);
  }

  void _standing(Canvas canvas) {
    _line(canvas, const Offset(85, 117), const Offset(80, 171), _trousers, 13);
    _line(canvas, const Offset(99, 117), const Offset(105, 171), _trousers, 13);
    _line(
      canvas,
      const Offset(73, 175),
      const Offset(84, 175),
      BaseboundColors.ink,
      8,
    );
    _line(
      canvas,
      const Offset(100, 175),
      const Offset(113, 175),
      BaseboundColors.ink,
      8,
    );
    _line(canvas, const Offset(92, 67), const Offset(92, 113), _shirt, 34);
    _line(canvas, const Offset(75, 78), const Offset(68, 113), _skin, 9);
    _line(canvas, const Offset(109, 78), const Offset(115, 112), _skin, 9);
    _head(canvas, const Offset(92, 42), tilted: false);
  }

  void _lowered(Canvas canvas, {required bool covered}) {
    _bentLimb(
      canvas,
      const [Offset(112, 143), Offset(144, 158), Offset(116, 173)],
      _trousers,
      15,
    );
    _bentLimb(
      canvas,
      const [Offset(101, 145), Offset(127, 159), Offset(102, 173)],
      _trousers,
      15,
    );
    _line(
      canvas,
      const Offset(101, 177),
      const Offset(119, 177),
      BaseboundColors.ink,
      8,
    );
    _line(canvas, const Offset(112, 142), const Offset(82, 121), _shirt, 32);
    final head = covered ? const Offset(60, 124) : const Offset(62, 103);
    _head(canvas, head, tilted: covered);
    if (covered) {
      _bentLimb(
        canvas,
        const [Offset(88, 126), Offset(86, 101), Offset(55, 107)],
        _skin,
        10,
      );
      _bentLimb(
        canvas,
        const [Offset(75, 131), Offset(61, 145), Offset(49, 117)],
        _skin,
        10,
      );
    } else {
      _bentLimb(
        canvas,
        const [Offset(87, 124), Offset(70, 148), Offset(53, 170)],
        _skin,
        9,
      );
      _bentLimb(
        canvas,
        const [Offset(77, 127), Offset(61, 149), Offset(44, 171)],
        _skin,
        9,
      );
    }
  }

  void _head(Canvas canvas, Offset center, {required bool tilted}) {
    if (gender == ChildGender.girl) {
      canvas.drawOval(
        Rect.fromCenter(center: center.translate(7, 5), width: 36, height: 47),
        Paint()..color = _hair,
      );
    }
    canvas.drawCircle(center, 17, Paint()..color = _skin);
    final fringe = Path()
      ..moveTo(center.dx - 17, center.dy - 4)
      ..cubicTo(
        center.dx - 17,
        center.dy - 27,
        center.dx + 22,
        center.dy - 25,
        center.dx + 18,
        center.dy + 4,
      )
      ..quadraticBezierTo(
        center.dx + 5,
        center.dy - 15,
        center.dx - 17,
        center.dy - 4,
      )
      ..close();
    canvas.drawPath(fringe, Paint()..color = _hair);
    final eye = center.translate(-8, tilted ? 6 : 1);
    canvas.drawCircle(eye, 1.6, Paint()..color = BaseboundColors.ink);
    _line(
      canvas,
      center.translate(-10, 9),
      center.translate(-5, 10),
      _hair,
      1.5,
    );
    if (gender == ChildGender.girl) {
      _line(
        canvas,
        center.translate(9, -13),
        center.translate(14, -8),
        _shirt,
        4,
      );
    }
  }

  void _bentLimb(
    Canvas canvas,
    List<Offset> joints,
    Color color,
    double width,
  ) {
    final path = Path()..moveTo(joints.first.dx, joints.first.dy);
    for (final joint in joints.skip(1)) {
      path.lineTo(joint.dx, joint.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  void _line(
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
  bool shouldRepaint(_OutdoorPosePainter oldDelegate) =>
      pose != oldDelegate.pose ||
      gender != oldDelegate.gender ||
      helper != oldDelegate.helper;
}

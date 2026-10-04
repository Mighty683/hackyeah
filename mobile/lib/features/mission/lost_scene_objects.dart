import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import '../../widgets/child_character.dart';
import '../landmarks/widgets/landmark_photo.dart';
import '../parent/data/family_plan.dart';
import 'lost_adult_sprite.dart';
import 'lost_mission_scene_layout.dart';
import 'scene_highlight_style.dart';

/// Actual posed people and place objects, without choice cards or captions.
class LostSceneIllustration extends StatelessWidget {
  const LostSceneIllustration({
    super.key,
    required this.object,
    required this.gender,
    required this.photoLabel,
  });

  final LostSceneObject object;
  final ChildGender gender;
  final String photoLabel;

  @override
  Widget build(BuildContext context) => switch (object.kind) {
    LostSceneObjectKind.standingChild => _child(ChildPoseName.stand),
    LostSceneObjectKind.walkingChild => Transform.flip(
      flipX: true,
      child: _child(ChildPoseName.walk),
    ),
    LostSceneObjectKind.adult => const LostAdultSprite(
      pose: LostAdultPose.stranger,
    ),
    LostSceneObjectKind.informationDesk => _desk(),
    LostSceneObjectKind.childWithStaff => Stack(
      fit: StackFit.expand,
      children: [
        _part(const Rect.fromLTWH(0, 0, .72, .68), _desk()),
        _part(
          const Rect.fromLTWH(.64, .43, .35, .57),
          _child(ChildPoseName.stand),
        ),
      ],
    ),
    LostSceneObjectKind.family => Stack(
      fit: StackFit.expand,
      children: [
        _part(
          const Rect.fromLTWH(.02, 0, .48, 1),
          const LostAdultSprite(pose: LostAdultPose.parent),
        ),
        _part(
          const Rect.fromLTWH(.51, .38, .42, .62),
          _child(ChildPoseName.stand),
        ),
      ],
    ),
    LostSceneObjectKind.photo => LayoutBuilder(
      builder: (context, constraints) => LandmarkPhoto(
        path: object.photoPath!,
        label: photoLabel,
        height: constraints.maxHeight,
        fit: BoxFit.contain,
      ),
    ),
    _ => CustomPaint(painter: _PlaceObjectPainter(object.kind)),
  };

  Widget _child(ChildPoseName pose) => LayoutBuilder(
    builder: (context, constraints) => Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: math.min(constraints.maxHeight, constraints.maxWidth / .55),
        width: constraints.maxWidth,
        child: ChildCharacter(pose: pose, gender: gender),
      ),
    ),
  );

  Widget _desk() => Stack(
    fit: StackFit.expand,
    children: [
      _part(
        const Rect.fromLTWH(.55, 0, .43, 1),
        const LostAdultSprite(pose: LostAdultPose.staff),
      ),
      _part(
        const Rect.fromLTWH(0, .42, .54, .58),
        CustomPaint(
          painter: const _PlaceObjectPainter(
            LostSceneObjectKind.informationDesk,
          ),
        ),
      ),
    ],
  );

  Widget _part(Rect bounds, Widget child) => Positioned.fill(
    child: FractionallySizedBox(
      widthFactor: bounds.width,
      heightFactor: bounds.height,
      alignment: Alignment(
        bounds.width == 1 ? 0 : 2 * bounds.left / (1 - bounds.width) - 1,
        bounds.height == 1 ? 0 : 2 * bounds.top / (1 - bounds.height) - 1,
      ),
      child: child,
    ),
  );
}

/// Pictured-object contours use the same local geometry as their illustrations.
class LostSceneObjectOutline extends CustomPainter {
  const LostSceneObjectOutline({
    required this.kind,
    required this.rejected,
    required this.selected,
    required this.correct,
  });

  final LostSceneObjectKind kind;
  final bool rejected;
  final bool selected;
  final bool correct;

  @override
  void paint(Canvas canvas, Size size) => paintSceneHighlight(
    canvas,
    (paint) => _outline(canvas, size, kind, paint),
    color: rejected
        ? BaseboundColors.muted
        : selected
        ? (correct ? BaseboundColors.green : BaseboundColors.coral)
        : BaseboundColors.blue,
    subdued: rejected,
  );

  void _outline(
    Canvas canvas,
    Size size,
    LostSceneObjectKind objectKind,
    Paint paint,
  ) {
    switch (objectKind) {
      case LostSceneObjectKind.standingChild:
      case LostSceneObjectKind.walkingChild:
        _person(canvas, size, paint, child: true);
      case LostSceneObjectKind.adult:
        _person(canvas, size, paint);
      case LostSceneObjectKind.informationDesk:
        _within(
          canvas,
          size,
          const Rect.fromLTWH(.55, 0, .43, 1),
          (part) => _person(canvas, part, paint, aspect: 302 / 599),
        );
        _within(
          canvas,
          size,
          const Rect.fromLTWH(0, .42, .54, .58),
          (part) => canvas.drawPath(_deskOutline(part), paint),
        );
      case LostSceneObjectKind.childWithStaff:
        _within(
          canvas,
          size,
          const Rect.fromLTWH(0, 0, .72, .68),
          (part) => _outline(
            canvas,
            part,
            LostSceneObjectKind.informationDesk,
            paint,
          ),
        );
        _within(
          canvas,
          size,
          const Rect.fromLTWH(.64, .43, .35, .57),
          (part) => _person(canvas, part, paint, child: true),
        );
      case LostSceneObjectKind.exit:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              size.width * .14,
              size.height * .07,
              size.width * .73,
              size.height * .90,
            ),
            const Radius.circular(3),
          ),
          paint,
        );
      case LostSceneObjectKind.fountain:
        canvas.drawPath(_fountainOutline(size), paint);
      case LostSceneObjectKind.photo:
      case LostSceneObjectKind.phone:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            (Offset.zero & size).deflate(5),
            const Radius.circular(10),
          ),
          paint,
        );
      default:
        break;
    }
  }

  void _person(
    Canvas canvas,
    Size size,
    Paint paint, {
    bool child = false,
    double aspect = 325 / 613,
  }) {
    final childHeight = math.min(size.height, size.width / .55);
    final width = child
        ? childHeight * .52
        : math.min(size.width, size.height * aspect);
    final height = child ? childHeight : math.min(size.height, width / aspect);
    final left = (size.width - width) / 2;
    final top = size.height - height;
    final points = <Offset>[
      const Offset(.32, .01),
      const Offset(.69, .01),
      const Offset(.79, .18),
      const Offset(.71, .28),
      const Offset(.91, .40),
      const Offset(.90, .58),
      const Offset(.73, .56),
      const Offset(.77, .91),
      const Offset(.94, .98),
      const Offset(.54, .99),
      const Offset(.49, .68),
      const Offset(.39, .98),
      const Offset(.05, .98),
      const Offset(.24, .90),
      const Offset(.29, .56),
      const Offset(.10, .58),
      const Offset(.10, .40),
      const Offset(.29, .28),
      const Offset(.21, .18),
    ];
    final path = Path();
    for (var index = 0; index < points.length; index++) {
      final point = Offset(
        left + points[index].dx * width,
        top + points[index].dy * height,
      );
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(path..close(), paint);
  }

  void _within(Canvas canvas, Size size, Rect part, void Function(Size) draw) {
    canvas.save();
    canvas.translate(part.left * size.width, part.top * size.height);
    draw(Size(part.width * size.width, part.height * size.height));
    canvas.restore();
  }

  @override
  bool shouldRepaint(LostSceneObjectOutline oldDelegate) =>
      kind != oldDelegate.kind ||
      rejected != oldDelegate.rejected ||
      selected != oldDelegate.selected ||
      correct != oldDelegate.correct;
}

Path _deskOutline(Size size) => Path()
  ..moveTo(size.width * .06, size.height * .06)
  ..lineTo(size.width * .94, size.height * .06)
  ..lineTo(size.width * .94, size.height * .25)
  ..lineTo(size.width * .87, size.height * .25)
  ..lineTo(size.width * .87, size.height * .97)
  ..lineTo(size.width * .13, size.height * .97)
  ..lineTo(size.width * .13, size.height * .25)
  ..lineTo(size.width * .06, size.height * .25)
  ..close();

Path _fountainOutline(Size size) => Path()
  ..moveTo(size.width * .10, size.height * .75)
  ..quadraticBezierTo(
    size.width * .04,
    size.height,
    size.width * .50,
    size.height * .98,
  )
  ..quadraticBezierTo(
    size.width * .96,
    size.height,
    size.width * .90,
    size.height * .75,
  )
  ..lineTo(size.width * .61, size.height * .65)
  ..lineTo(size.width * .61, size.height * .48)
  ..lineTo(size.width * .70, size.height * .43)
  ..lineTo(size.width * .61, size.height * .37)
  ..lineTo(size.width * .55, size.height * .15)
  ..lineTo(size.width * .45, size.height * .15)
  ..lineTo(size.width * .39, size.height * .37)
  ..lineTo(size.width * .30, size.height * .43)
  ..lineTo(size.width * .39, size.height * .48)
  ..lineTo(size.width * .39, size.height * .65)
  ..close();

class _PlaceObjectPainter extends CustomPainter {
  const _PlaceObjectPainter(this.kind);

  final LostSceneObjectKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 160);
    switch (kind) {
      case LostSceneObjectKind.exit:
        _exit(canvas);
      case LostSceneObjectKind.fountain:
        _fountain(canvas);
      case LostSceneObjectKind.informationDesk:
        _desk(canvas);
      case LostSceneObjectKind.phone:
        _phone(canvas);
      case LostSceneObjectKind.safe:
        paintBaseboundIcon(
          canvas,
          const Rect.fromLTWH(8, 25, 84, 110),
          BaseboundIconName.check,
          color: BaseboundColors.green,
        );
      default:
        break;
    }
    canvas.restore();
  }

  void _exit(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(1, 1, 98, 154),
      Paint()..color = const Color(0xFFD6D0C3),
    );
    canvas.drawRect(
      const Rect.fromLTWH(14, 11, 73, 144),
      Paint()..color = const Color(0xFF7D776E),
    );
    canvas.drawRect(
      const Rect.fromLTWH(20, 17, 61, 138),
      Paint()..color = const Color(0xFF6D8778),
    );
    canvas.drawRect(
      const Rect.fromLTWH(26, 23, 49, 124),
      Paint()..color = const Color(0xFFBBD0D0),
    );
    canvas.drawLine(
      const Offset(25, 92),
      const Offset(75, 92),
      Paint()
        ..color = const Color(0xFF7D776E)
        ..strokeWidth = 5,
    );
    canvas.drawLine(
      const Offset(70, 98),
      const Offset(70, 117),
      Paint()
        ..color = BaseboundColors.ink
        ..strokeWidth = 3,
    );
    canvas.drawRect(
      const Rect.fromLTWH(8, 151, 84, 7),
      Paint()..color = const Color(0xFFADA99F),
    );
  }

  void _fountain(Canvas canvas) {
    final stone = Paint()..color = const Color(0xFF91A9AF);
    final water = Paint()..color = const Color(0xFF79ABBF);
    canvas.drawOval(const Rect.fromLTWH(8, 128, 84, 30), stone);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 120, 80, 29),
        const Radius.circular(8),
      ),
      stone,
    );
    canvas.drawOval(const Rect.fromLTWH(10, 116, 80, 22), water);
    canvas.drawRect(const Rect.fromLTWH(40, 69, 20, 61), stone);
    canvas.drawOval(const Rect.fromLTWH(29, 59, 42, 18), stone);
    canvas.drawOval(const Rect.fromLTWH(31, 58, 38, 12), water);
    final spray = Paint()
      ..color = const Color(0xFF79ABBF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(50, 64)
        ..lineTo(50, 23)
        ..moveTo(50, 64)
        ..quadraticBezierTo(20, 15, 16, 102)
        ..moveTo(50, 64)
        ..quadraticBezierTo(80, 15, 84, 102),
      spray,
    );
  }

  void _desk(Canvas canvas) {
    canvas.drawPath(
      _deskOutline(const Size(100, 160)),
      Paint()..color = const Color(0xFFB59272),
    );
    canvas.drawRect(
      const Rect.fromLTWH(6, 9, 88, 30),
      Paint()..color = const Color(0xFF716354),
    );
    paintBaseboundIcon(
      canvas,
      const Rect.fromLTWH(30, 64, 40, 56),
      BaseboundIconName.info,
      color: BaseboundColors.blue,
    );
  }

  void _phone(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 4, 84, 152),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF59666A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(15, 14, 70, 129),
        const Radius.circular(6),
      ),
      Paint()..color = BaseboundColors.cream,
    );
    paintBaseboundIcon(
      canvas,
      const Rect.fromLTWH(29, 55, 42, 60),
      BaseboundIconName.phone,
    );
  }

  @override
  bool shouldRepaint(_PlaceObjectPainter oldDelegate) =>
      kind != oldDelegate.kind;
}

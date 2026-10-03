import 'package:flutter/material.dart';

import '../features/parent/data/family_plan.dart';
import '../ui/basebound_ui.dart';

enum ChildPoseName { stand, walk, crouch, protect }

/// Source crops preserve the sheet's pose heights and transparent padding.
class ChildCharacter extends StatelessWidget {
  const ChildCharacter({
    super.key,
    required this.pose,
    this.gender = ChildGender.girl,
  });

  final ChildPoseName pose;
  final ChildGender gender;

  static const _sourceRects = [
    Rect.fromLTWH(161, 17, 308, 672),
    Rect.fromLTWH(773, 27, 335, 658),
    Rect.fromLTWH(194, 759, 291, 434),
    Rect.fromLTWH(780, 782, 304, 416),
  ];

  static const _boySourceRects = [
    Rect.fromLTRB(175, 10, 495, 705),
    Rect.fromLTRB(755, 10, 1135, 705),
    Rect.fromLTRB(195, 735, 515, 1215),
    Rect.fromLTRB(790, 745, 1105, 1215),
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final rects = gender == ChildGender.boy ? _boySourceRects : _sourceRects;
      final source = rects[pose.index];
      final scale = constraints.maxHeight / rects.first.height;
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
                    gender == ChildGender.boy
                        ? 'assets/illustrations/boy-poses.png'
                        : 'assets/illustrations/child-poses.png',
                    fit: BoxFit.fill,
                    excludeFromSemantics: true,
                    errorBuilder: (_, _, _) => CustomPaint(
                      painter: _ChildFallbackPainter(pose, source, gender),
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

class _ChildFallbackPainter extends CustomPainter {
  _ChildFallbackPainter(this.pose, this.source, this.gender);

  final ChildPoseName pose;
  final Rect source;
  final ChildGender gender;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 1254, size.height / 1254);
    canvas.translate(source.left, source.top);
    canvas.scale(source.width / 100, source.height / 100);
    final low = pose == ChildPoseName.crouch || pose == ChildPoseName.protect;
    const skin = Color(0xFFF6CAA7);
    const hair = Color(0xFF724127);
    final shirt = gender == ChildGender.boy
        ? const Color(0xFF299F9B)
        : const Color(0xFFB961BE);
    final head = Offset(low ? 48 : 50, low ? 57 : 24);
    canvas.drawOval(
      Rect.fromCenter(
        center: head + const Offset(0, 3),
        width: 40,
        height: gender == ChildGender.boy ? 30 : 47,
      ),
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
      pose == ChildPoseName.protect
          ? head + const Offset(-10, -14)
          : Offset(body.left - 7, body.bottom),
      skin,
      7,
    );
    _limb(
      canvas,
      Offset(body.right, body.top + 6),
      pose == ChildPoseName.protect
          ? head + const Offset(10, -14)
          : Offset(body.right + 6, body.bottom),
      skin,
      7,
    );
    final stride = pose == ChildPoseName.walk ? 13.0 : 5.0;
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
      pose != oldDelegate.pose || gender != oldDelegate.gender;
}

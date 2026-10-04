import 'package:flutter/material.dart';

import '../../ui/basebound_ui.dart';

class StreetForegroundPainter extends CustomPainter {
  const StreetForegroundPainter({required this.soundCue});

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
  bool shouldRepaint(StreetForegroundPainter oldDelegate) =>
      soundCue != oldDelegate.soundCue;
}

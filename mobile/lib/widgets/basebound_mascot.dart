/// Shared, decorative Basebound guide. Help never depends on motion or speech.
library;

import 'package:flutter/material.dart';

class BaseboundMascot extends StatelessWidget {
  const BaseboundMascot({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _MascotPainter()),
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 72, size.height / 72);
    final outline = Paint()
      ..color = const Color(0xFF263B57)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(5, 8, 62, 57),
        const Radius.circular(22),
      ),
      Paint()..color = const Color(0xFFDEE9F2),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(5, 8, 62, 57),
        const Radius.circular(22),
      ),
      outline,
    );
    final eyes = Paint()..color = const Color(0xFF263B57);
    canvas.drawCircle(const Offset(25, 34), 3, eyes);
    canvas.drawCircle(const Offset(47, 34), 3, eyes);
    canvas.drawPath(
      Path()
        ..moveTo(26, 47)
        ..quadraticBezierTo(36, 54, 46, 47),
      outline,
    );
    canvas.drawPath(
      Path()
        ..moveTo(36, 4)
        ..lineTo(31, 16)
        ..lineTo(41, 16)
        ..close(),
      eyes,
    );
  }

  @override
  bool shouldRepaint(covariant _MascotPainter oldDelegate) => false;
}

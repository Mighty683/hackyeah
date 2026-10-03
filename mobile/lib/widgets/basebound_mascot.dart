/// Decorative practice guide, rendered locally at any size without animation.
library;

import 'package:flutter/material.dart';

class BaseboundMascot extends StatelessWidget {
  const BaseboundMascot({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _MascotPainter()),
    ),
  );
}

class _MascotPainter extends CustomPainter {
  static const green = Color(0xFF66D649);
  static const darkGreen = Color(0xFF14974E);
  static const ink = Color(0xFF123C38);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 120, size.height / 120);
    canvas.drawOval(
      const Rect.fromLTWH(22, 105, 86, 9),
      Paint()..color = const Color(0x130D3760),
    );
    final tail = Path()
      ..moveTo(45, 76)
      ..quadraticBezierTo(15, 98, 11, 65)
      ..quadraticBezierTo(2, 90, 25, 99)
      ..quadraticBezierTo(42, 103, 56, 89)
      ..close();
    canvas.drawPath(tail, Paint()..color = darkGreen);
    final body = Rect.fromLTWH(37, 53, 53, 53);
    canvas.drawOval(
      body,
      Paint()
        ..shader = const LinearGradient(
          colors: [green, Color(0xFF39BB47)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(body),
    );
    canvas.drawOval(
      const Rect.fromLTWH(51, 65, 31, 38),
      Paint()..color = const Color(0xFFE1F58A),
    );
    final bellyLines = Paint()
      ..color = const Color(0xFFB9D95D)
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(53, 80), const Offset(80, 80), bellyLines);
    canvas.drawLine(const Offset(54, 88), const Offset(79, 88), bellyLines);
    for (final spike in [
      const Offset(42, 22),
      const Offset(53, 13),
      const Offset(68, 14),
      const Offset(83, 22),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: spike, width: 15, height: 20),
        Paint()..color = darkGreen,
      );
    }
    final head = RRect.fromRectAndRadius(
      const Rect.fromLTWH(32, 19, 65, 53),
      const Radius.circular(25),
    );
    canvas.drawRRect(
      head,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF8AE858), green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(head.outerRect),
    );
    _limb(canvas, const Offset(42, 68), const Offset(29, 77));
    _limb(canvas, const Offset(88, 68), const Offset(104, 55));
    _limb(canvas, const Offset(48, 96), const Offset(43, 108), width: 17);
    _limb(canvas, const Offset(78, 97), const Offset(83, 108), width: 17);
    canvas.drawOval(
      const Rect.fromLTWH(31, 103, 23, 10),
      Paint()..color = darkGreen,
    );
    canvas.drawOval(
      const Rect.fromLTWH(74, 103, 24, 10),
      Paint()..color = darkGreen,
    );
    final face = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    for (final x in [49.0, 79.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(x - 5, 43)
          ..quadraticBezierTo(x, 35, x + 5, 43),
        face,
      );
    }
    canvas.drawOval(
      const Rect.fromLTWH(37, 45, 13, 9),
      Paint()..color = const Color(0xFFFFAD91),
    );
    canvas.drawOval(
      const Rect.fromLTWH(79, 45, 13, 9),
      Paint()..color = const Color(0xFFFFAD91),
    );
    final mouth = Path()
      ..moveTo(53, 50)
      ..quadraticBezierTo(65, 60, 76, 50)
      ..quadraticBezierTo(73, 69, 63, 67)
      ..quadraticBezierTo(54, 64, 53, 50)
      ..close();
    canvas.drawPath(mouth, Paint()..color = ink);
    canvas.drawOval(
      const Rect.fromLTWH(60, 59, 12, 7),
      Paint()..color = const Color(0xFFFF8792),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(58, 52, 12, 4),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.white,
    );
  }

  void _limb(Canvas canvas, Offset start, Offset end, {double width = 12}) {
    canvas.drawLine(
      start,
      end,
      Paint()
        ..color = green
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(end, width / 2, Paint()..color = green);
  }

  @override
  bool shouldRepaint(covariant _MascotPainter oldDelegate) => false;
}

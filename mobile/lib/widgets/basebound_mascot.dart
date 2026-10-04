/// Decorative practice guide, rendered locally at any size without animation.
library;

import 'package:flutter/material.dart';

/// Decorative poses support the current activity without conveying instructions.
enum DinoPose { wave, point, think, listen, celebrate, calm, search }

class BaseboundMascot extends StatelessWidget {
  const BaseboundMascot({
    super.key,
    this.size = 72,
    this.pose = DinoPose.wave,
    this.faceLeft = false,
    this.holdingPhone = false,
  });

  final double size;
  final DinoPose pose;
  final bool faceLeft;
  final bool holdingPhone;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _MascotPainter(pose, faceLeft, holdingPhone)),
    ),
  );
}

class _MascotPainter extends CustomPainter {
  const _MascotPainter(this.pose, this.faceLeft, this.holdingPhone);

  final DinoPose pose;
  final bool faceLeft;
  final bool holdingPhone;

  static const green = Color(0xFF66D649);
  static const darkGreen = Color(0xFF14974E);
  static const ink = Color(0xFF123C38);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 120, size.height / 120);
    if (faceLeft) {
      canvas.translate(120, 0);
      canvas.scale(-1, 1);
    }
    canvas.save();
    if (pose == DinoPose.celebrate) canvas.translate(0, -6);
    _drawTail(canvas);
    _drawBody(canvas);
    _drawLegs(canvas);
    _drawHead(canvas);
    _drawArms(canvas);
    _drawPoseAccents(canvas);
    canvas.restore();
  }

  void _drawTail(Canvas canvas) {
    final tip = switch (pose) {
      DinoPose.celebrate => const Offset(8, 55),
      DinoPose.think => const Offset(14, 79),
      DinoPose.calm => const Offset(10, 86),
      _ => const Offset(11, 65),
    };
    final tail = Path()
      ..moveTo(45, 76)
      ..quadraticBezierTo(15, 98, tip.dx, tip.dy)
      ..quadraticBezierTo(2, 90, 25, 99)
      ..quadraticBezierTo(42, 103, 56, 89)
      ..close();
    canvas.drawPath(tail, Paint()..color = darkGreen);
  }

  void _drawBody(Canvas canvas) {
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
  }

  void _drawLegs(Canvas canvas) {
    final (leftFoot, rightFoot) = pose == DinoPose.celebrate
        ? (const Offset(34, 103), const Offset(92, 102))
        : (const Offset(43, 108), const Offset(83, 108));
    _limb(canvas, const Offset(48, 96), leftFoot, width: 17);
    _limb(canvas, const Offset(78, 97), rightFoot, width: 17);
    for (final foot in [leftFoot, rightFoot]) {
      canvas.drawOval(
        Rect.fromCenter(center: foot, width: 23, height: 10),
        Paint()..color = darkGreen,
      );
    }
  }

  void _drawHead(Canvas canvas) {
    final tilt = switch (pose) {
      DinoPose.think => -.12,
      DinoPose.listen => .10,
      DinoPose.point => .05,
      _ => 0.0,
    };
    canvas.save();
    canvas.translate(64, 43);
    canvas.rotate(tilt);
    canvas.translate(-64, -43);
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
    _drawFace(canvas);
    canvas.restore();
  }

  void _drawFace(Canvas canvas) {
    final face = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    final joyful = pose == DinoPose.wave || pose == DinoPose.celebrate;
    for (final x in [49.0, 79.0]) {
      if (joyful) {
        canvas.drawPath(
          Path()
            ..moveTo(x - 5, 43)
            ..quadraticBezierTo(x, 35, x + 5, 43),
          face,
        );
      } else {
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, 42), width: 10, height: 13),
          Paint()..color = Colors.white,
        );
        final look = pose == DinoPose.point ? 2.0 : 0.0;
        canvas.drawCircle(Offset(x + look, 43), 3.1, Paint()..color = ink);
      }
    }
    canvas.drawOval(
      const Rect.fromLTWH(37, 45, 13, 9),
      Paint()..color = const Color(0xFFFFAD91),
    );
    canvas.drawOval(
      const Rect.fromLTWH(79, 45, 13, 9),
      Paint()..color = const Color(0xFFFFAD91),
    );
    if (!joyful) {
      canvas.drawPath(
        Path()
          ..moveTo(56, 54)
          ..quadraticBezierTo(65, pose == DinoPose.think ? 58 : 63, 74, 54),
        face..strokeWidth = 2.8,
      );
      if (pose == DinoPose.think) {
        canvas.drawLine(const Offset(72, 31), const Offset(84, 33), face);
      }
      return;
    }
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

  void _drawArms(Canvas canvas) {
    final (leftElbow, leftHand, rightElbow, rightHand) = switch (pose) {
      DinoPose.wave => (
        const Offset(32, 76),
        const Offset(27, 80),
        const Offset(101, 59),
        const Offset(103, 39),
      ),
      DinoPose.point => (
        const Offset(37, 79),
        const Offset(43, 86),
        const Offset(101, 71),
        const Offset(111, 69),
      ),
      DinoPose.think => (
        const Offset(34, 78),
        const Offset(51, 84),
        const Offset(95, 77),
        const Offset(75, 62),
      ),
      DinoPose.listen => (
        const Offset(33, 80),
        const Offset(27, 79),
        const Offset(104, 61),
        const Offset(102, 42),
      ),
      DinoPose.celebrate => (
        const Offset(28, 57),
        const Offset(21, 37),
        const Offset(103, 52),
        const Offset(106, 30),
      ),
      DinoPose.search => (
        const Offset(38, 64),
        const Offset(100, 43),
        const Offset(97, 64),
        const Offset(83, 45),
      ),
      DinoPose.calm => (
        const Offset(37, 82),
        const Offset(53, 88),
        const Offset(95, 82),
        const Offset(81, 88),
      ),
    };
    _arm(canvas, const Offset(42, 68), leftElbow, leftHand);
    if (holdingPhone) {
      _arm(
        canvas,
        const Offset(88, 68),
        const Offset(102, 65),
        const Offset(103, 49),
      );
      _drawPhone(canvas);
    } else {
      _arm(canvas, const Offset(88, 68), rightElbow, rightHand);
    }
    if (!holdingPhone &&
        (pose == DinoPose.wave || pose == DinoPose.celebrate)) {
      _openHand(canvas, rightHand);
    }
    if (pose == DinoPose.celebrate) _openHand(canvas, leftHand);
    if (pose == DinoPose.point) {
      _limb(canvas, rightHand, const Offset(117, 65), width: 5);
    }
    if (pose == DinoPose.listen) {
      canvas.drawArc(
        const Rect.fromLTWH(94, 34, 13, 18),
        -1.6,
        3.2,
        false,
        Paint()
          ..color = darkGreen
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawPhone(Canvas canvas) {
    canvas.save();
    canvas.translate(103, 43);
    canvas.rotate(.12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-9, -17, 18, 32),
        const Radius.circular(4),
      ),
      Paint()..color = ink,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-6, -12, 12, 20),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF97C5EF),
    );
    canvas.drawLine(
      const Offset(-2, -14),
      const Offset(2, -14),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(const Offset(0, 11), 1.5, Paint()..color = Colors.white);
    // Draw fingers over the phone so the hand visibly grips it.
    _limb(canvas, const Offset(7, 5), const Offset(2, 5), width: 5);
    _limb(canvas, const Offset(7, 10), const Offset(3, 10), width: 4);
    canvas.restore();
  }

  void _arm(Canvas canvas, Offset shoulder, Offset elbow, Offset hand) {
    canvas.drawPath(
      Path()
        ..moveTo(shoulder.dx, shoulder.dy)
        ..lineTo(elbow.dx, elbow.dy)
        ..lineTo(hand.dx, hand.dy),
      Paint()
        ..color = green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(hand, 6.5, Paint()..color = green);
  }

  void _openHand(Canvas canvas, Offset center) {
    for (final finger in [
      const Offset(-6, -9),
      const Offset(0, -12),
      const Offset(6, -9),
    ]) {
      _limb(canvas, center, center + finger, width: 4.5);
    }
  }

  void _drawPoseAccents(Canvas canvas) {
    if (pose == DinoPose.search) _drawSpyglass(canvas);
    if (pose == DinoPose.think) {
      for (final (center, radius) in [
        (const Offset(102, 22), 2.5),
        (const Offset(109, 15), 4.0),
      ]) {
        canvas.drawCircle(
          center,
          radius,
          Paint()..color = const Color(0xFF97C5EF),
        );
      }
    }
    if (pose == DinoPose.listen) {
      final sound = Paint()
        ..color = const Color(0xFF0967DA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(const Rect.fromLTWH(105, 27, 8, 23), -1, 2, false, sound);
      canvas.drawArc(const Rect.fromLTWH(109, 22, 9, 33), -1, 2, false, sound);
    }
    if (pose == DinoPose.celebrate) {
      _sparkle(canvas, const Offset(15, 18), 6);
      _sparkle(canvas, const Offset(109, 13), 5);
    }
  }

  void _drawSpyglass(Canvas canvas) {
    canvas.save();
    canvas.translate(79, 42);
    canvas.rotate(-.12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, -4, 13, 8),
        const Radius.circular(2),
      ),
      Paint()..color = ink,
    );
    canvas.drawPath(
      Path()
        ..moveTo(9, -5)
        ..lineTo(37, -8)
        ..lineTo(37, 8)
        ..lineTo(9, 5)
        ..close(),
      Paint()..color = const Color(0xFFC59A52),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(31, -9, 6, 18),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF8C713E),
    );
    canvas.drawOval(
      const Rect.fromLTWH(34, -7, 4, 14),
      Paint()..color = const Color(0xFF97C5EF),
    );
    canvas.restore();
  }

  void _sparkle(Canvas canvas, Offset center, double radius) {
    final star = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + 2, center.dy - 2)
      ..lineTo(center.dx + radius, center.dy)
      ..lineTo(center.dx + 2, center.dy + 2)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - 2, center.dy + 2)
      ..lineTo(center.dx - radius, center.dy)
      ..lineTo(center.dx - 2, center.dy - 2)
      ..close();
    canvas.drawPath(star, Paint()..color = const Color(0xFFF4C44E));
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
  bool shouldRepaint(covariant _MascotPainter oldDelegate) =>
      oldDelegate.pose != pose ||
      oldDelegate.faceLeft != faceLeft ||
      oldDelegate.holdingPhone != holdingPhone;
}

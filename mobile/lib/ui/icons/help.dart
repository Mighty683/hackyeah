import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawHelp(StoryIconArt a) {
  final rope = Path()
    ..moveTo(9, 12)
    ..cubicTo(2, 17, 2, 32, 10, 38)
    ..moveTo(39, 12)
    ..cubicTo(46, 18, 46, 33, 38, 39);
  a.trace(rope, a.brown, 3.5);
  a.trace(rope, a.cream, 1.9);

  final underside = Path()
    ..fillType = PathFillType.evenOdd
    ..addOval(const Rect.fromLTWH(6, 8, 36, 36))
    ..addOval(const Rect.fromLTWH(16, 17, 16, 17));
  a.shape(underside, a.coral);
  final ring = Path()
    ..fillType = PathFillType.evenOdd
    ..addOval(const Rect.fromLTWH(6, 5, 36, 36))
    ..addOval(const Rect.fromLTWH(16, 15, 16, 16));
  a.shape(ring, a.cream);

  a.shape(
    Path()
      ..moveTo(19, 5.8)
      ..quadraticBezierTo(24, 4.3, 29, 5.8)
      ..lineTo(27.1, 15.5)
      ..quadraticBezierTo(24, 14.4, 20.9, 15.5)
      ..close(),
    a.blue,
  );
  a.shape(
    Path()
      ..moveTo(7, 18)
      ..quadraticBezierTo(5.1, 23, 7, 28)
      ..lineTo(16.5, 26)
      ..quadraticBezierTo(15.2, 23, 16.5, 20)
      ..close(),
    a.blue,
  );
  a.shape(
    Path()
      ..moveTo(41, 18)
      ..quadraticBezierTo(42.9, 23, 41, 28)
      ..lineTo(31.5, 26)
      ..quadraticBezierTo(32.8, 23, 31.5, 20)
      ..close(),
    a.blue,
  );
  a.shape(
    Path()
      ..moveTo(20.9, 30.5)
      ..quadraticBezierTo(24, 31.6, 27.1, 30.5)
      ..lineTo(29, 40.2)
      ..quadraticBezierTo(24, 42, 19, 40.2)
      ..close(),
    a.blue,
  );
  a.glint(
    Path()
      ..moveTo(10, 16)
      ..quadraticBezierTo(12, 11, 16, 9),
    2.2,
  );
  a.glint(
    Path()
      ..moveTo(22, 7.5)
      ..lineTo(21.3, 12.5),
  );
  a.glint(
    Path()
      ..moveTo(33, 10)
      ..quadraticBezierTo(36, 12, 38, 16),
  );
  a.trace(
    Path()
      ..moveTo(11, 34)
      ..quadraticBezierTo(13, 37, 17, 38),
    a.coral.withValues(alpha: .65),
    1.5,
  );
}

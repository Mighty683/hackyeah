import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawAlert(StoryIconArt a) {
  final rim = Path()
    ..moveTo(20.6, 8.3)
    ..quadraticBezierTo(24, 2.6, 27.4, 8.5)
    ..lineTo(43.4, 35.9)
    ..quadraticBezierTo(46, 41.8, 38.9, 42.1)
    ..lineTo(9, 42.1)
    ..quadraticBezierTo(2.6, 41.8, 5, 36.2)
    ..close();
  a.shape(rim, Color.lerp(a.gold, a.brown, .34)!);

  final face = Path()
    ..moveTo(20.6, 6.8)
    ..quadraticBezierTo(24, 1.9, 27.4, 7)
    ..lineTo(42.4, 33.5)
    ..quadraticBezierTo(45.1, 39.1, 38.7, 39.5)
    ..lineTo(9.5, 39.5)
    ..quadraticBezierTo(3.4, 39.3, 6.1, 33.9)
    ..close();
  a.shape(face, a.gold);

  final inset = Path()
    ..moveTo(22.2, 11)
    ..quadraticBezierTo(24, 7.8, 25.9, 11)
    ..lineTo(38.7, 33.3)
    ..quadraticBezierTo(40.2, 36.1, 36.8, 36.3)
    ..lineTo(11.6, 36.3)
    ..quadraticBezierTo(8.3, 36.2, 10, 33.3)
    ..close();
  a.shape(inset, Color.lerp(a.gold, a.cream, .37)!);

  final mark = Path()
    ..moveTo(22.1, 16.3)
    ..quadraticBezierTo(24.1, 15.4, 26, 16.4)
    ..lineTo(25.5, 26.7)
    ..quadraticBezierTo(24, 28.2, 22.6, 26.7)
    ..close();
  a.shape(mark, a.ink, outline: false);
  a.circle(24, 31.6, 2.2, a.ink, outline: false);
  a.glint(
    Path()
      ..moveTo(10, 30)
      ..lineTo(21.8, 9.2)
      ..quadraticBezierTo(23.6, 6.4, 25.4, 8.7),
    1.5,
  );
  a.line(const Offset(12, 38.4), const Offset(34, 38.4), a.cream, .9);
}

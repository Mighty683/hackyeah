import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawWindow(StoryIconArt a) {
  a.roundRect(const Rect.fromLTWH(8, 6, 32, 34), a.brown, radius: 4);
  a.roundRect(const Rect.fromLTWH(10, 7, 28, 31), a.gold, radius: 3);
  a.roundRect(const Rect.fromLTWH(13, 10, 22, 25), a.sky, radius: 2);
  a.shape(
    Path()
      ..moveTo(13, 27)
      ..quadraticBezierTo(23, 23, 35, 29)
      ..lineTo(35, 35)
      ..lineTo(13, 35)
      ..close(),
    a.blue,
    outline: false,
  );
  a.glint(
    Path()
      ..moveTo(16, 16)
      ..lineTo(20, 12)
      ..moveTo(29, 20)
      ..lineTo(32, 17),
    2,
  );
  a.line(const Offset(24, 10), const Offset(24, 35), a.gold, 3);
  a.line(const Offset(13, 23), const Offset(35, 23), a.gold, 3);
  a.shape(
    Path()
      ..moveTo(7, 8)
      ..quadraticBezierTo(13, 6, 18, 9)
      ..quadraticBezierTo(17, 19, 11, 25)
      ..quadraticBezierTo(14, 30, 13, 36)
      ..quadraticBezierTo(9, 38, 6, 35)
      ..quadraticBezierTo(8, 23, 7, 8)
      ..close(),
    a.lavender,
  );
  a.shape(
    Path()
      ..moveTo(41, 8)
      ..quadraticBezierTo(35, 6, 30, 9)
      ..quadraticBezierTo(31, 19, 37, 25)
      ..quadraticBezierTo(34, 30, 35, 36)
      ..quadraticBezierTo(39, 38, 42, 35)
      ..quadraticBezierTo(40, 23, 41, 8)
      ..close(),
    a.lavender,
  );
  a.glint(
    Path()
      ..moveTo(11, 11)
      ..quadraticBezierTo(12, 17, 10, 21),
  );
  a.glint(
    Path()
      ..moveTo(36, 11)
      ..quadraticBezierTo(36, 17, 38, 21),
  );
  a.line(const Offset(7, 26), const Offset(12, 26), a.gold, 2.5);
  a.line(const Offset(36, 26), const Offset(41, 26), a.gold, 2.5);
  a.roundRect(const Rect.fromLTWH(5, 38, 38, 5), a.gold, radius: 2);
  a.glint(
    Path()
      ..moveTo(9, 39.5)
      ..lineTo(36, 39.5),
  );
}

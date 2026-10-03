import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawWait(StoryIconArt a) {
  a.roundRect(const Rect.fromLTWH(9, 10, 4, 29), a.brown, radius: 2);
  a.roundRect(const Rect.fromLTWH(35, 10, 4, 29), a.brown, radius: 2);
  a.shape(
    Path()
      ..moveTo(15, 11)
      ..lineTo(33, 11)
      ..cubicTo(34, 17, 31, 20, 26, 24)
      ..cubicTo(31, 28, 34, 30, 33, 38)
      ..lineTo(15, 38)
      ..cubicTo(14, 31, 17, 28, 22, 24)
      ..cubicTo(17, 20, 14, 17, 15, 11)
      ..close(),
    a.sky,
  );
  a.shape(
    Path()
      ..moveTo(17, 16)
      ..quadraticBezierTo(24, 18, 31, 16)
      ..quadraticBezierTo(30, 20, 24, 23)
      ..quadraticBezierTo(18, 20, 17, 16)
      ..close(),
    a.gold,
    outline: false,
  );
  a.line(const Offset(24, 24), const Offset(24, 31), a.gold, 1.7);
  a.shape(
    Path()
      ..moveTo(16, 37)
      ..quadraticBezierTo(18, 34, 22, 32)
      ..quadraticBezierTo(24, 30, 26, 32)
      ..quadraticBezierTo(30, 34, 32, 37)
      ..close(),
    a.gold,
    outline: false,
  );
  a.glint(
    Path()
      ..moveTo(18, 13)
      ..quadraticBezierTo(17, 17, 20, 20)
      ..moveTo(19, 28)
      ..quadraticBezierTo(16, 31, 17, 34),
  );
  a.roundRect(const Rect.fromLTWH(7, 6, 34, 7), a.gold, radius: 3.5);
  a.roundRect(const Rect.fromLTWH(7, 37, 34, 7), a.gold, radius: 3.5);
  a.line(const Offset(11, 11), const Offset(37, 11), a.brown, 1);
  a.line(const Offset(11, 42), const Offset(37, 42), a.brown, 1);
  a.glint(
    Path()
      ..moveTo(11, 8)
      ..lineTo(28, 8),
  );
  a.glint(
    Path()
      ..moveTo(11, 39)
      ..lineTo(28, 39),
  );
}

import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawMessageRead(StoryIconArt a) {
  a.shape(
    Path()
      ..moveTo(5, 21)
      ..quadraticBezierTo(13, 13, 22, 6)
      ..quadraticBezierTo(24, 4, 27, 6)
      ..quadraticBezierTo(36, 13, 42, 20)
      ..lineTo(40, 39)
      ..quadraticBezierTo(23, 43, 7, 39)
      ..close(),
    a.cream,
  );
  a.shape(
    Path()
      ..moveTo(8, 22)
      ..lineTo(23, 10)
      ..quadraticBezierTo(24, 9, 26, 11)
      ..lineTo(39, 22)
      ..lineTo(24, 34)
      ..close(),
    a.gold,
  );
  a.shape(
    Path()
      ..moveTo(13, 11)
      ..quadraticBezierTo(23, 9, 33, 11)
      ..quadraticBezierTo(35, 11, 35, 14)
      ..lineTo(36, 32)
      ..lineTo(12, 34)
      ..lineTo(11, 14)
      ..quadraticBezierTo(11, 12, 13, 11)
      ..close(),
    a.sky,
  );
  a.glint(
    Path()
      ..moveTo(14, 14)
      ..quadraticBezierTo(21, 12.5, 29, 14),
  );
  a.line(const Offset(16, 19), const Offset(29, 19), a.blue, 1.8);
  a.line(const Offset(16, 24), const Offset(25, 24), a.blue, 1.8);
  a.shape(
    Path()
      ..moveTo(5, 21)
      ..quadraticBezierTo(14, 26, 23, 32)
      ..quadraticBezierTo(25, 33, 27, 31)
      ..lineTo(42, 21)
      ..lineTo(41, 39)
      ..quadraticBezierTo(41, 42, 37, 42)
      ..lineTo(9, 42)
      ..quadraticBezierTo(6, 42, 6, 39)
      ..close(),
    a.cream,
  );
  a.trace(
    Path()
      ..moveTo(8, 39)
      ..lineTo(19, 30)
      ..moveTo(29, 30)
      ..lineTo(38, 39),
    a.brown.withValues(alpha: .48),
    1.1,
  );
  a.glint(
    Path()
      ..moveTo(10, 39)
      ..quadraticBezierTo(20, 40, 29, 39),
  );
  a.trace(
    Path()
      ..moveTo(32, 27)
      ..lineTo(36, 31)
      ..lineTo(44, 21),
    a.leaf,
    4.4,
  );
  a.glint(
    Path()
      ..moveTo(33, 26.6)
      ..lineTo(36, 29.6)
      ..lineTo(42.5, 21.7),
    .9,
  );
}

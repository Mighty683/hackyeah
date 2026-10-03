import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawIdea(StoryIconArt a) {
  a.line(const Offset(24, 3), const Offset(24, 6), a.gold, 2.4);
  a.line(const Offset(9, 9), const Offset(11.5, 11.5), a.gold, 2.4);
  a.line(const Offset(39, 9), const Offset(36.5, 11.5), a.gold, 2.4);
  a.line(const Offset(4, 22), const Offset(7.5, 22), a.gold, 2.4);
  a.line(const Offset(40.5, 22), const Offset(44, 22), a.gold, 2.4);

  a.shape(
    Path()
      ..moveTo(19, 34)
      ..cubicTo(19, 30, 11, 28, 11, 20)
      ..cubicTo(11, 12, 16, 9, 24, 9)
      ..cubicTo(32, 9, 37, 13, 37, 20)
      ..cubicTo(37, 28, 29, 30, 29, 34)
      ..close(),
    a.gold,
  );
  a.oval(const Rect.fromLTWH(16, 13, 17, 17), a.cream, outline: false);
  a.trace(
    Path()
      ..moveTo(21.5, 34)
      ..lineTo(21.5, 27)
      ..cubicTo(16, 21, 21, 20, 24, 24)
      ..cubicTo(27, 20, 32, 21, 26.5, 27)
      ..lineTo(26.5, 34),
    a.brown.withValues(alpha: .78),
    1.7,
  );
  a.glint(
    Path()
      ..moveTo(15, 20)
      ..cubicTo(15, 16, 18, 13, 21, 13),
    2.3,
  );

  a.oval(const Rect.fromLTWH(21, 39, 6, 5), a.brown);
  a.shape(
    Path()
      ..moveTo(18, 33)
      ..quadraticBezierTo(24, 35, 30, 33)
      ..lineTo(29, 40)
      ..quadraticBezierTo(24, 44, 19, 40)
      ..close(),
    a.lavender,
  );
  a.line(
    const Offset(19.5, 36.5),
    const Offset(28.5, 35.5),
    a.ink.withValues(alpha: .34),
    1.3,
  );
  a.line(
    const Offset(20, 39.5),
    const Offset(28, 38.5),
    a.ink.withValues(alpha: .34),
    1.3,
  );
}

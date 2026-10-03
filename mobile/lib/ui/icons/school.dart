import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

/// A little brick schoolhouse, with its clock above the welcoming blue doors.
void drawSchool(StoryIconArt a) {
  final roof = Color.lerp(a.coral, a.brown, .38)!;
  a.roundRect(const Rect.fromLTRB(5, 21, 43, 41), a.coral, radius: 2.8);
  a.shape(
    Path()
      ..moveTo(3.5, 23)
      ..quadraticBezierTo(5, 19, 8, 17.5)
      ..lineTo(39.5, 17.5)
      ..quadraticBezierTo(42, 19.5, 44.5, 23)
      ..quadraticBezierTo(25, 24.5, 3.5, 23)
      ..close(),
    roof,
  );
  a.roundRect(const Rect.fromLTRB(17, 11, 31, 40), a.cream, radius: 2);
  a.shape(
    Path()
      ..moveTo(15.5, 12.5)
      ..quadraticBezierTo(19.5, 7, 23.5, 4.5)
      ..quadraticBezierTo(24, 4.1, 24.5, 4.5)
      ..quadraticBezierTo(29, 7.5, 32.5, 12.5)
      ..quadraticBezierTo(24, 13.5, 15.5, 12.5)
      ..close(),
    roof,
  );
  a.circle(24, 19.3, 4.6, a.paper);
  a.line(const Offset(24, 16.7), const Offset(24, 19.3), a.ink, 1.2);
  a.line(const Offset(24, 19.3), const Offset(26.1, 20.2), a.ink, 1.2);
  a.roundRect(const Rect.fromLTRB(19.5, 28, 28.5, 40.5), a.blue, radius: 2.5);
  a.line(
    const Offset(24, 29),
    const Offset(24, 40),
    a.ink.withValues(alpha: .55),
    1,
  );
  a.circle(22.1, 35.5, .7, a.gold, outline: false);
  a.circle(25.9, 35.5, .7, a.gold, outline: false);
  for (final x in [8.5, 33.5]) {
    a.roundRect(Rect.fromLTWH(x, 27, 6, 7), a.sky, radius: 1.6);
    a.line(Offset(x + 3, 27.6), Offset(x + 3, 33.5), a.cream, 1.1);
    a.line(Offset(x - .5, 34.8), Offset(x + 6.5, 34.8), a.cream, 1.8);
  }
  a.line(
    const Offset(7.5, 37.5),
    const Offset(11, 37.5),
    roof.withValues(alpha: .5),
    1,
  );
  a.line(
    const Offset(37, 38),
    const Offset(40, 38),
    roof.withValues(alpha: .5),
    1,
  );
  a.roundRect(const Rect.fromLTRB(15.5, 40, 32.5, 43.5), a.brown, radius: 1.5);
  a.glint(
    Path()
      ..moveTo(19, 10.7)
      ..quadraticBezierTo(21.5, 7.7, 24, 6.2),
    1.1,
  );
  a.glint(
    Path()
      ..moveTo(20.9, 30)
      ..lineTo(20.9, 33.2),
    1.1,
  );
}

import 'package:flutter/material.dart';

import '../basebound_icon_art.dart';

void drawDoor(StoryIconArt a) {
  // The visible inner jamb and broad threshold give the open door its depth.
  a.roundRect(const Rect.fromLTWH(18, 6, 23, 36), a.brown, radius: 4);
  a.roundRect(const Rect.fromLTWH(22, 10, 14, 29), a.cream, radius: 2);
  a.polygon(const [
    Offset(35, 10),
    Offset(38, 9),
    Offset(38, 40),
    Offset(35, 37),
  ], a.gold);
  a.polygon(const [
    Offset(17, 39),
    Offset(38, 38),
    Offset(43, 42),
    Offset(20, 45),
  ], a.brown);
  a.glint(
    Path()
      ..moveTo(28, 41)
      ..lineTo(38, 40.5),
  );
  a.glint(
    Path()
      ..moveTo(28, 8)
      ..lineTo(37, 8)
      ..quadraticBezierTo(39, 8, 39, 11)
      ..lineTo(39, 33),
  );

  final door = Path()
    ..moveTo(8, 13)
    ..quadraticBezierTo(7, 13.3, 7, 15)
    ..lineTo(7, 41)
    ..quadraticBezierTo(7, 44, 10, 43)
    ..lineTo(27, 39)
    ..lineTo(27, 7)
    ..close();
  a.shape(door, a.gold);
  a.polygon(const [
    Offset(27, 7),
    Offset(29, 8.5),
    Offset(29, 39.5),
    Offset(27, 39),
  ], a.brown);

  a.shape(
    Path()
      ..moveTo(11, 17)
      ..lineTo(23, 13)
      ..lineTo(23, 23)
      ..lineTo(11, 26)
      ..close(),
    a.cream,
  );
  a.shape(
    Path()
      ..moveTo(11, 30)
      ..lineTo(23, 27)
      ..lineTo(23, 36)
      ..lineTo(11, 39)
      ..close(),
    a.gold,
  );
  a.line(const Offset(12, 32), const Offset(12, 36), a.brown, .8);
  a.glint(
    Path()
      ..moveTo(9, 16)
      ..lineTo(9, 38),
  );
  a.oval(const Rect.fromLTWH(21, 24, 4, 6), a.brown);
  a.circle(23.5, 26.4, 2.5, a.gold);
  a.glint(
    Path()
      ..moveTo(22.4, 25.5)
      ..lineTo(23.2, 25.1),
    1,
  );
}

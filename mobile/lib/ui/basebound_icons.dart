/// Small, local vector illustrations shared by practice and adult setup.
/// Callers own labels and actions; the drawings contain no font glyphs.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'basebound_icon_art.dart';
import 'icons/speaker.dart';
import 'icons/wait.dart';
import 'icons/idea.dart';
import 'icons/phone.dart';
import 'icons/message.dart';
import 'icons/message_read.dart';
import 'icons/help.dart';
import 'icons/no_signal.dart';
import 'icons/edit.dart';
import 'icons/delete.dart';
import 'icons/lock.dart';
import 'icons/alert.dart';
import 'icons/child.dart';
import 'icons/adult.dart';
import 'icons/family.dart';
import 'icons/add_adult.dart';
import 'icons/mother.dart';
import 'icons/father.dart';
import 'icons/grandparent.dart';
import 'icons/home.dart';
import 'icons/park.dart';
import 'icons/school.dart';
import 'icons/shelter.dart';
import 'icons/bus_stop.dart';
import 'icons/window.dart';
import 'icons/door.dart';
import 'icons/hallway.dart';
import 'icons/living_room.dart';
import 'icons/bedroom.dart';
import 'icons/kitchen.dart';

enum BaseboundIconName {
  back,
  next,
  up,
  down,
  replay,
  play,
  plus,
  minus,
  fitMap,
  info,
  check,
  cross,
  speaker,
  wait,
  idea,
  phone,
  message,
  messageRead,
  help,
  noSignal,
  edit,
  delete,
  lock,
  alert,
  child,
  adult,
  family,
  addAdult,
  mother,
  father,
  grandparent,
  birthday,
  home,
  map,
  pin,
  addPlace,
  park,
  school,
  shelter,
  busStop,
  window,
  door,
  hallway,
  livingRoom,
  bedroom,
  kitchen,
  alarm,
  heart,
  unresponsive,
  lost,
  unsure,
  stay,
  protectHead,
  badge,
  sun,
}

class BaseboundIcon extends StatelessWidget {
  const BaseboundIcon(
    this.name, {
    super.key,
    this.size = 24,
    this.color,
    this.calm = false,
  });

  final BaseboundIconName name;
  final double size;
  final Color? color;
  final bool calm;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Center(
      widthFactor: 1,
      heightFactor: 1,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _IconPainter(name, color, calm)),
      ),
    ),
  );
}

class BaseboundBackButton extends StatelessWidget {
  const BaseboundBackButton({
    super.key,
    this.onPressed,
    this.tooltip,
    this.enabled = true,
  });

  final VoidCallback? onPressed;
  final String? tooltip;
  final bool enabled;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: enabled
        ? onPressed ?? () => Navigator.of(context).maybePop()
        : null,
    tooltip: tooltip ?? MaterialLocalizations.of(context).backButtonTooltip,
    icon: const BaseboundIcon(BaseboundIconName.back),
  );
}

/// Paint into any rectangle; all motifs share a transparent 48-unit artboard.
void paintBaseboundIcon(
  Canvas canvas,
  Rect bounds,
  BaseboundIconName name, {
  Color? color,
  bool calm = false,
}) {
  final side = math.min(bounds.width, bounds.height);
  if (side <= 0) return;
  canvas.save();
  canvas.translate(bounds.center.dx - side / 2, bounds.center.dy - side / 2);
  canvas.scale(side / 48);
  final draw = _storyDrawings[name];
  if (draw != null) {
    draw(StoryIconArt(canvas, color: color, calm: calm));
  } else {
    canvas.scale(2);
    _IconDrawing(canvas, name, color, calm).paint();
  }
  canvas.restore();
}

class _IconPainter extends CustomPainter {
  const _IconPainter(this.name, this.color, this.calm);

  final BaseboundIconName name;
  final Color? color;
  final bool calm;

  @override
  void paint(Canvas canvas, Size size) => paintBaseboundIcon(
    canvas,
    Offset.zero & size,
    name,
    color: color,
    calm: calm,
  );

  @override
  bool shouldRepaint(covariant _IconPainter oldDelegate) =>
      oldDelegate.name != name ||
      oldDelegate.color != color ||
      oldDelegate.calm != calm;
}

final _storyDrawings = <BaseboundIconName, void Function(StoryIconArt)>{
  BaseboundIconName.speaker: drawSpeaker,
  BaseboundIconName.wait: drawWait,
  BaseboundIconName.idea: drawIdea,
  BaseboundIconName.phone: drawPhone,
  BaseboundIconName.message: drawMessage,
  BaseboundIconName.messageRead: drawMessageRead,
  BaseboundIconName.help: drawHelp,
  BaseboundIconName.noSignal: drawNoSignal,
  BaseboundIconName.edit: drawEdit,
  BaseboundIconName.delete: drawDelete,
  BaseboundIconName.lock: drawLock,
  BaseboundIconName.alert: drawAlert,
  BaseboundIconName.child: drawChild,
  BaseboundIconName.adult: drawAdult,
  BaseboundIconName.family: drawFamily,
  BaseboundIconName.addAdult: drawAddAdult,
  BaseboundIconName.mother: drawMother,
  BaseboundIconName.father: drawFather,
  BaseboundIconName.grandparent: drawGrandparent,
  BaseboundIconName.home: drawHome,
  BaseboundIconName.park: drawPark,
  BaseboundIconName.school: drawSchool,
  BaseboundIconName.shelter: drawShelter,
  BaseboundIconName.busStop: drawBusStop,
  BaseboundIconName.window: drawWindow,
  BaseboundIconName.door: drawDoor,
  BaseboundIconName.hallway: drawHallway,
  BaseboundIconName.livingRoom: drawLivingRoom,
  BaseboundIconName.bedroom: drawBedroom,
  BaseboundIconName.kitchen: drawKitchen,
};

class _IconDrawing {
  _IconDrawing(this.canvas, this.name, this.override, this.calm);

  final Canvas canvas;
  final BaseboundIconName name;
  final Color? override;
  final bool calm;

  Color get ink => override ?? const Color(0xFF112568);
  Color get blue =>
      override ?? (calm ? const Color(0xFF536184) : const Color(0xFF1677FF));
  Color get warm =>
      override ?? (calm ? const Color(0xFFA1B0C5) : const Color(0xFFFFBF46));
  Color get green =>
      override ?? (calm ? const Color(0xFF536184) : const Color(0xFF28A36A));
  Color get light =>
      override?.withValues(alpha: .22) ??
      (calm ? const Color(0xFFE4EBF4) : const Color(0xFFE6F2FF));

  Paint _fill(Color color) => Paint()..color = color;

  Paint _stroke(Color color, [double width = 1.8]) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void paint() {
    switch (name) {
      case BaseboundIconName.back:
      case BaseboundIconName.next:
      case BaseboundIconName.up:
      case BaseboundIconName.down:
        _arrow();
      case BaseboundIconName.replay:
        _replay();
      case BaseboundIconName.play:
        _circle(12, 12, 10, light);
        _polygon([
          const Offset(9, 6),
          const Offset(19, 12),
          const Offset(9, 18),
        ], blue);
      case BaseboundIconName.plus:
      case BaseboundIconName.minus:
        _circle(12, 12, 10, light);
        _line(6, 12, 18, 12, blue, 2.6);
        if (name == BaseboundIconName.plus) _line(12, 6, 12, 18, blue, 2.6);
      case BaseboundIconName.fitMap:
        _rect(7, 7, 10, 10, light, radius: 2);
        for (final angle in [0.0, math.pi / 2, math.pi, math.pi * 1.5]) {
          canvas.save();
          canvas.translate(12, 12);
          canvas.rotate(angle);
          _polyline(
            [const Offset(-3, -9), const Offset(-9, -9), const Offset(-9, -3)],
            blue,
            2.2,
          );
          canvas.restore();
        }
      case BaseboundIconName.info:
        _circle(12, 12, 10, light);
        _circle(12, 7, 1.25, blue);
        _line(12, 11, 12, 17, blue, 2.5);
        _line(10, 17, 14, 17, blue, 2);
      case BaseboundIconName.check:
        _circle(12, 12, 10, override == null ? green : light);
        _polyline(
          [
            const Offset(6.5, 12),
            const Offset(10.5, 16),
            const Offset(17.5, 8),
          ],
          override ?? Colors.white,
          2.6,
        );
      case BaseboundIconName.cross:
        _circle(12, 12, 10, light);
        final cross = override ?? (calm ? ink : const Color(0xFFE54949));
        _line(8, 8, 16, 16, cross, 2.7);
        _line(16, 8, 8, 16, cross, 2.7);
      case BaseboundIconName.speaker:
        _polygon([
          const Offset(3, 9),
          const Offset(7, 9),
          const Offset(13, 4),
          const Offset(13, 20),
          const Offset(7, 15),
          const Offset(3, 15),
        ], blue);
        _rect(2.5, 9, 4.5, 6, warm, radius: 1);
        canvas.drawArc(
          const Rect.fromLTWH(9, 6.5, 10, 11),
          -.7,
          1.4,
          false,
          _stroke(blue, 2),
        );
        canvas.drawArc(
          const Rect.fromLTWH(8, 2.5, 17, 19),
          -.7,
          1.4,
          false,
          _stroke(blue, 2),
        );
      case BaseboundIconName.wait:
        _hourglass();
      case BaseboundIconName.idea:
        _bulb();
      case BaseboundIconName.phone:
        _phone();
      case BaseboundIconName.message:
      case BaseboundIconName.messageRead:
        _message();
      case BaseboundIconName.help:
        _lifeRing();
      case BaseboundIconName.noSignal:
        _noSignal();
      case BaseboundIconName.edit:
        _pencil();
      case BaseboundIconName.delete:
        _trash();
      case BaseboundIconName.lock:
        _lock();
      case BaseboundIconName.alert:
        _alert();
      case BaseboundIconName.child:
      case BaseboundIconName.adult:
      case BaseboundIconName.mother:
      case BaseboundIconName.father:
      case BaseboundIconName.grandparent:
        _person();
      case BaseboundIconName.family:
      case BaseboundIconName.addAdult:
        _family();
      case BaseboundIconName.birthday:
        _birthday();
      case BaseboundIconName.home:
        _home();
      case BaseboundIconName.map:
        _map();
      case BaseboundIconName.pin:
      case BaseboundIconName.addPlace:
        _pin();
      case BaseboundIconName.park:
        _park();
      case BaseboundIconName.school:
      case BaseboundIconName.shelter:
        _publicBuilding();
      case BaseboundIconName.busStop:
        _busStop();
      case BaseboundIconName.window:
        _window();
      case BaseboundIconName.door:
        _door();
      case BaseboundIconName.hallway:
        _hallway();
      case BaseboundIconName.livingRoom:
        _livingRoom();
      case BaseboundIconName.bedroom:
        _bedroom();
      case BaseboundIconName.kitchen:
        _kitchen();
      case BaseboundIconName.alarm:
        _alarm();
      case BaseboundIconName.heart:
        _heart();
      case BaseboundIconName.unresponsive:
        _unresponsive();
      case BaseboundIconName.lost:
        _map();
        _circle(17, 15, 5.7, warm);
        _question(17, 15, blue, .58);
      case BaseboundIconName.unsure:
        _circle(12, 12, 10, light);
        _question(12, 12, blue, 1);
      case BaseboundIconName.stay:
        _stay();
      case BaseboundIconName.protectHead:
        _protectHead();
      case BaseboundIconName.badge:
        _badge();
      case BaseboundIconName.sun:
        _sun();
    }
  }

  void _circle(double x, double y, double radius, Color color) =>
      canvas.drawCircle(Offset(x, y), radius, _fill(color));

  void _line(
    double x1,
    double y1,
    double x2,
    double y2,
    Color color, [
    double width = 1.8,
  ]) => canvas.drawLine(Offset(x1, y1), Offset(x2, y2), _stroke(color, width));

  void _rect(
    double x,
    double y,
    double width,
    double height,
    Color color, {
    double radius = 2,
    Color? outline,
  }) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, width, height),
      Radius.circular(radius),
    );
    canvas.drawRRect(rect, _fill(color));
    if (outline != null) canvas.drawRRect(rect, _stroke(outline, 1.5));
  }

  Path _points(List<Offset> points, {bool close = false}) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    if (close) path.close();
    return path;
  }

  void _polygon(List<Offset> points, Color color) =>
      canvas.drawPath(_points(points, close: true), _fill(color));

  void _polyline(List<Offset> points, Color color, [double width = 1.8]) =>
      canvas.drawPath(_points(points), _stroke(color, width));

  void _arrow() {
    _circle(12, 12, 10.5, light);
    canvas.save();
    canvas.translate(12, 12);
    canvas.rotate(switch (name) {
      BaseboundIconName.back => math.pi,
      BaseboundIconName.up => -math.pi / 2,
      BaseboundIconName.down => math.pi / 2,
      _ => 0,
    });
    _line(-5.5, 0, 5.5, 0, blue, 2.3);
    _polyline(
      [const Offset(1, -5), const Offset(6, 0), const Offset(1, 5)],
      blue,
      2.3,
    );
    canvas.restore();
  }

  void _replay() {
    _circle(12, 12, 10.5, light);
    canvas.drawPath(
      Path()
        ..moveTo(19.5, 10)
        ..cubicTo(18, 4, 11, 2, 6, 7)
        ..cubicTo(1, 12, 5, 20, 12, 20)
        ..quadraticBezierTo(17, 20, 19, 16),
      _stroke(blue, 2.2),
    );
    _polygon([
      const Offset(20.5, 3.5),
      const Offset(20.5, 11),
      const Offset(13.5, 9),
    ], blue);
  }

  void _hourglass() {
    _rect(4, 2, 16, 3, blue, radius: 1.5);
    _rect(4, 19, 16, 3, blue, radius: 1.5);
    canvas.drawPath(
      Path()
        ..moveTo(6, 5)
        ..lineTo(6, 8)
        ..quadraticBezierTo(6, 10, 10, 12)
        ..quadraticBezierTo(6, 14, 6, 17)
        ..lineTo(6, 19)
        ..moveTo(18, 5)
        ..lineTo(18, 8)
        ..quadraticBezierTo(18, 10, 14, 12)
        ..quadraticBezierTo(18, 14, 18, 17)
        ..lineTo(18, 19),
      _stroke(blue),
    );
    _polygon([
      const Offset(8, 6),
      const Offset(16, 6),
      const Offset(12, 10),
    ], warm);
    _polygon([
      const Offset(12, 14),
      const Offset(17, 18),
      const Offset(7, 18),
    ], warm);
  }

  void _bulb() {
    canvas.drawPath(
      Path()
        ..moveTo(9, 16)
        ..cubicTo(9, 14, 5, 13, 5, 8)
        ..cubicTo(5, 0, 19, 0, 19, 8)
        ..cubicTo(19, 13, 15, 14, 15, 16)
        ..close(),
      _fill(warm),
    );
    _rect(9, 15, 6, 5, blue, radius: 1);
    _line(10, 22, 14, 22, blue, 2);
    _polyline(
      [const Offset(9, 8), const Offset(12, 11), const Offset(15, 8)],
      ink,
      1.3,
    );
    _line(12, 11, 12, 15, ink, 1.3);
  }

  void _phone() {
    _circle(12, 12, 10.5, light);
    final handset = Path()
      ..moveTo(5, 4)
      ..quadraticBezierTo(2, 7, 5, 13)
      ..quadraticBezierTo(9, 20, 16, 21)
      ..quadraticBezierTo(19, 21, 21, 17)
      ..lineTo(16, 13)
      ..lineTo(13, 16)
      ..quadraticBezierTo(9, 14, 8, 10)
      ..lineTo(11, 7)
      ..lineTo(8, 3)
      ..close();
    canvas.drawPath(handset, _fill(blue));
  }

  void _message() {
    _rect(2, 3, 20, 14, override == null ? blue : light, radius: 4);
    _polygon([
      const Offset(6, 15),
      const Offset(6, 22),
      const Offset(12, 16),
    ], blue);
    final detail = override ?? Colors.white;
    _line(6, 8, 17, 8, detail, 1.5);
    _line(6, 12, 13, 12, detail, 1.5);
    if (name == BaseboundIconName.messageRead) {
      _circle(18, 18, 5.5, override == null ? green : light);
      _polyline(
        [const Offset(15, 18), const Offset(17.3, 20), const Offset(21, 15.5)],
        detail,
        1.5,
      );
    }
  }

  void _lifeRing() {
    _circle(12, 12, 10, warm);
    for (final angle in [0.0, math.pi / 2, math.pi, math.pi * 1.5]) {
      canvas.drawArc(
        const Rect.fromLTWH(4, 4, 16, 16),
        angle - .3,
        .6,
        false,
        _stroke(blue, 4),
      );
    }
    _circle(12, 12, 5.5, override ?? Colors.white);
  }

  void _noSignal() {
    for (var i = 0; i < 4; i++) {
      _rect(3 + i * 5, 16 - i * 4, 3, 5 + i * 4, light, radius: 1);
    }
    _line(3, 3, 21, 21, ink, 2.4);
  }

  void _pencil() {
    canvas.save();
    canvas.translate(12, 12);
    canvas.rotate(math.pi / 4);
    _rect(-3.5, -9, 7, 15, warm, radius: 1);
    _rect(-3.5, -11, 7, 4, blue, radius: 1);
    _polygon([
      const Offset(-3.5, 6),
      const Offset(3.5, 6),
      const Offset(0, 11),
    ], ink);
    _line(0, -5, 0, 5, blue, 1.2);
    canvas.restore();
  }

  void _trash() {
    _rect(6, 6, 12, 15, light, radius: 3, outline: blue);
    _rect(3, 4, 18, 3, blue, radius: 1.5);
    _rect(9, 1, 6, 3, blue, radius: 1);
    _line(10, 10, 10, 17, blue, 1.5);
    _line(14, 10, 14, 17, blue, 1.5);
  }

  void _lock() {
    canvas.drawPath(
      Path()
        ..moveTo(7, 11)
        ..lineTo(7, 7)
        ..cubicTo(7, 0, 17, 0, 17, 7)
        ..lineTo(17, 11),
      _stroke(blue, 2.4),
    );
    _rect(4, 9, 16, 13, warm, radius: 4);
    _circle(12, 15, 2, blue);
    _line(12, 15, 12, 18, blue, 2.5);
  }

  void _alert() {
    canvas.drawPath(
      Path()
        ..moveTo(10, 3)
        ..quadraticBezierTo(12, 0, 14, 3)
        ..lineTo(22, 18)
        ..quadraticBezierTo(23, 21, 20, 21)
        ..lineTo(4, 21)
        ..quadraticBezierTo(1, 21, 2, 18)
        ..close(),
      _fill(warm),
    );
    _line(12, 7, 12, 13, ink, 2.3);
    _circle(12, 17, 1.25, ink);
  }

  void _person() {
    final child = name == BaseboundIconName.child;
    final mother = name == BaseboundIconName.mother;
    final elder = name == BaseboundIconName.grandparent;
    if (mother) _rect(5, 3, 14, 14, ink, radius: 6);
    _rect(
      child ? 5 : 3,
      14,
      child ? 14 : 18,
      8,
      mother ? green : blue,
      radius: 5,
    );
    _circle(12, child ? 9 : 8, child ? 5 : 6, warm);
    canvas.drawPath(
      Path()
        ..moveTo(6, 7)
        ..cubicTo(6, 0, 18, 0, 18, 7)
        ..quadraticBezierTo(13, elder ? 2 : 8, 10, 4)
        ..lineTo(6, 7),
      _fill(ink),
    );
    _circle(10, 8.7, .65, ink);
    _circle(14, 8.7, .65, ink);
    canvas.drawArc(
      const Rect.fromLTWH(10, 8.5, 4, 4),
      .25,
      2.6,
      false,
      _stroke(ink, .85),
    );
    if (elder) {
      canvas.drawCircle(const Offset(9.5, 8.5), 2, _stroke(ink, .8));
      canvas.drawCircle(const Offset(14.5, 8.5), 2, _stroke(ink, .8));
      _line(11.5, 8.5, 12.5, 8.5, ink, .8);
    }
    if (name == BaseboundIconName.father) _line(10, 11, 14, 11, ink, 1.3);
    if (name == BaseboundIconName.adult) {
      _polyline(
        [const Offset(9, 15), const Offset(12, 19), const Offset(15, 15)],
        warm,
        1.5,
      );
    }
    if (child) _circle(12, 18, 1.6, warm);
  }

  void _family() {
    _circle(7, 6, 3.5, blue);
    _rect(2, 10, 10, 11, blue, radius: 4);
    _circle(17, 6, 3.5, ink);
    _rect(12, 10, 10, 11, ink, radius: 4);
    if (name == BaseboundIconName.addAdult) {
      _circle(17.5, 17.5, 5.5, warm);
      _line(14.5, 17.5, 20.5, 17.5, ink, 1.7);
      _line(17.5, 14.5, 17.5, 20.5, ink, 1.7);
    } else {
      _circle(12, 13, 3, warm);
      _rect(7.5, 16, 9, 7, warm, radius: 3);
    }
  }

  void _birthday() {
    _rect(3, 10, 18, 11, blue, radius: 3);
    _rect(3, 10, 18, 4, warm, radius: 2);
    _line(12, 5, 12, 10, ink, 2);
    canvas.drawPath(
      Path()
        ..moveTo(12, 0)
        ..quadraticBezierTo(6, 6, 12, 6)
        ..quadraticBezierTo(17, 6, 12, 0),
      _fill(warm),
    );
    _line(3, 21, 21, 21, ink, 1.6);
  }

  void _home() {
    _rect(4, 10, 16, 12, light, radius: 2, outline: blue);
    _polygon([
      const Offset(1, 11),
      const Offset(12, 1),
      const Offset(23, 11),
    ], blue);
    _rect(10, 14, 5, 8, warm, radius: 1);
    _rect(5, 14, 3, 4, blue, radius: .8);
  }

  void _map() {
    final paper = [
      const Offset(2, 5),
      const Offset(8, 2),
      const Offset(16, 5),
      const Offset(22, 2),
      const Offset(22, 19),
      const Offset(16, 22),
      const Offset(8, 19),
      const Offset(2, 22),
    ];
    _polygon(paper, light);
    canvas.drawPath(_points(paper, close: true), _stroke(blue, 1.3));
    _line(8, 3, 8, 19, blue, 1);
    _line(16, 5, 16, 21, blue, 1);
    _polyline(
      [
        const Offset(4, 16),
        const Offset(10, 10),
        const Offset(14, 14),
        const Offset(20, 8),
      ],
      warm,
      2,
    );
  }

  void _pin() {
    canvas.drawOval(const Rect.fromLTWH(5, 19, 14, 4), _fill(light));
    canvas.drawPath(
      Path()
        ..moveTo(12, 22)
        ..cubicTo(10, 19, 4, 14, 4, 9)
        ..cubicTo(4, -1, 20, -1, 20, 9)
        ..cubicTo(20, 14, 14, 19, 12, 22),
      _fill(blue),
    );
    _circle(12, 8.5, 3.5, warm);
    if (name == BaseboundIconName.addPlace) {
      _circle(18, 17, 5.5, warm);
      _line(15, 17, 21, 17, blue, 1.8);
      _line(18, 14, 18, 20, blue, 1.8);
    }
  }

  void _park() {
    _rect(2, 20, 20, 3, light, radius: 1.5);
    _rect(10, 12, 4, 9, warm, radius: 1);
    _circle(12, 6, 5.5, green);
    _circle(7.5, 11, 5.5, green);
    _circle(16.5, 11, 5.5, green);
    _line(12, 10, 12, 19, warm, 1.8);
  }

  void _publicBuilding() {
    _rect(3, 9, 18, 13, light, radius: 2, outline: blue);
    if (name == BaseboundIconName.school) {
      _polygon([
        const Offset(1, 10),
        const Offset(12, 2),
        const Offset(23, 10),
      ], blue);
      _rect(9, 1, 6, 10, blue, radius: 1);
      _circle(12, 6, 2, warm);
      _line(12, 6, 12, 4.7, blue, .7);
      _line(12, 6, 13, 6, blue, .7);
    } else {
      _rect(2, 6, 20, 4, green, radius: 1);
      _polygon([
        const Offset(10, 1),
        const Offset(14, 1),
        const Offset(14, 4),
        const Offset(12, 6),
        const Offset(10, 4),
      ], green);
    }
    _rect(10, 15, 4, 7, blue, radius: 1);
    _rect(
      5,
      13,
      3,
      3,
      name == BaseboundIconName.school ? warm : green,
      radius: .6,
    );
    _rect(
      16,
      13,
      3,
      3,
      name == BaseboundIconName.school ? warm : green,
      radius: .6,
    );
  }

  void _busStop() {
    _line(5, 2, 5, 22, ink, 1.8);
    _rect(1, 2, 8, 8, blue, radius: 2);
    _rect(12, 7, 10, 12, warm, radius: 3);
    _rect(14, 9, 6, 5, blue, radius: 1);
    _line(13, 19, 13, 21, ink, 2);
    _line(21, 19, 21, 21, ink, 2);
    _circle(14.5, 16.5, .75, ink);
    _circle(19.5, 16.5, .75, ink);
  }

  void _window() {
    _rect(3, 2, 18, 20, warm, radius: 2);
    _rect(6, 3, 12, 17, light, radius: 1, outline: blue);
    _line(12, 4, 12, 20, blue, 1.3);
    _line(6, 11, 18, 11, blue, 1.3);
    _line(2, 22, 22, 22, blue, 1.8);
  }

  void _door() {
    _rect(4, 2, 16, 20, light, radius: 2, outline: blue);
    _polygon([
      const Offset(6, 3),
      const Offset(16, 6),
      const Offset(16, 21),
      const Offset(6, 21),
    ], warm);
    _circle(13, 13, 1.1, blue);
    _line(2, 22, 22, 22, blue, 1.5);
  }

  void _hallway() {
    _rect(2, 2, 20, 20, light, radius: 2, outline: blue);
    _polygon([
      const Offset(2, 22),
      const Offset(9, 15),
      const Offset(15, 15),
      const Offset(22, 22),
    ], warm);
    _polyline(
      [
        const Offset(2, 2),
        const Offset(9, 8),
        const Offset(9, 15),
        const Offset(2, 22),
      ],
      blue,
      1.2,
    );
    _polyline(
      [
        const Offset(22, 2),
        const Offset(15, 8),
        const Offset(15, 15),
        const Offset(22, 22),
      ],
      blue,
      1.2,
    );
    _rect(10, 9, 4, 6, blue, radius: .7);
  }

  void _livingRoom() {
    _rect(4, 8, 16, 8, light, radius: 3, outline: blue);
    _rect(2, 12, 20, 7, blue, radius: 3);
    _line(5, 19, 5, 22, blue, 2);
    _line(19, 19, 19, 22, blue, 2);
    _rect(6, 10, 5, 5, warm, radius: 1.5);
    _rect(13, 10, 5, 5, warm, radius: 1.5);
  }

  void _bedroom() {
    _rect(2, 7, 20, 13, blue, radius: 2);
    _rect(4, 8, 16, 5, warm, radius: 2);
    _rect(3, 13, 18, 6, light, radius: 1);
    _line(3, 20, 3, 23, blue, 2);
    _line(21, 20, 21, 23, blue, 2);
    _line(12, 8, 12, 13, blue, 1);
  }

  void _kitchen() {
    _rect(2, 4, 20, 8, light, radius: 1.5);
    _rect(2, 13, 20, 9, blue, radius: 1.5);
    _line(1, 12, 23, 12, blue, 2);
    _rect(5, 15, 7, 5, light, radius: 1);
    _rect(14, 7, 6, 5, warm, radius: 1.5);
    _line(16, 4, 18, 4, warm, 1.2);
    _line(20, 8, 22, 8, warm, 1.5);
    _circle(17, 16.5, .9, warm);
  }

  void _alarm() {
    _circle(12, 4, 2, warm);
    canvas.drawPath(
      Path()
        ..moveTo(5, 17)
        ..lineTo(7, 14)
        ..lineTo(7, 10)
        ..cubicTo(7, 3, 17, 3, 17, 10)
        ..lineTo(17, 14)
        ..lineTo(19, 17)
        ..close(),
      _fill(blue),
    );
    _line(9, 20, 15, 20, warm, 2.8);
    canvas.drawArc(
      const Rect.fromLTWH(1, 6, 5, 8),
      math.pi * .65,
      math.pi * .7,
      false,
      _stroke(blue, 1.5),
    );
    canvas.drawArc(
      const Rect.fromLTWH(18, 6, 5, 8),
      -math.pi * .35,
      math.pi * .7,
      false,
      _stroke(blue, 1.5),
    );
  }

  void _heart() {
    final heart = Path()
      ..moveTo(12, 21)
      ..cubicTo(2, 14, -1, 9, 3, 5)
      ..cubicTo(6, 2, 10, 4, 12, 7)
      ..cubicTo(14, 4, 18, 2, 21, 5)
      ..cubicTo(25, 9, 22, 14, 12, 21);
    canvas.drawPath(
      heart,
      _fill(override ?? (calm ? blue : const Color(0xFFF37985))),
    );
    canvas.drawPath(
      Path()
        ..moveTo(5, 8)
        ..quadraticBezierTo(7, 6, 9, 8),
      _stroke(override ?? Colors.white, 1.5),
    );
  }

  void _unresponsive() {
    _line(2, 21, 22, 21, ink, 1.5);
    _circle(5, 15.5, 3.5, warm);
    _rect(8, 13, 13, 6, blue, radius: 3);
    _line(4, 15, 6, 15, ink, .8);
    _line(11, 11, 13, 8, blue, 1.4);
    _line(16, 10, 17, 6, blue, 1.4);
  }

  void _question(double x, double y, Color color, double scale) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale);
    canvas.drawPath(
      Path()
        ..moveTo(-4, -4)
        ..cubicTo(-4, -9, 5, -9, 5, -4)
        ..cubicTo(5, -1, 0, -1, 0, 2),
      _stroke(color, 2.2),
    );
    _circle(0, 6, 1.2, color);
    canvas.restore();
  }

  void _stay() {
    _circle(12, 12, 10.5, light);
    _circle(12, 6, 3, warm);
    _rect(9, 10, 6, 7, blue, radius: 2);
    _polyline(
      [const Offset(8, 15), const Offset(4, 19), const Offset(15, 20)],
      blue,
      2.5,
    );
    _polyline(
      [const Offset(16, 15), const Offset(20, 19), const Offset(9, 20)],
      blue,
      2.5,
    );
  }

  void _protectHead() {
    _rect(6, 15, 12, 7, blue, radius: 4);
    _circle(12, 12, 4, warm);
    _polyline(
      [const Offset(5, 17), const Offset(4, 8), const Offset(10, 5)],
      blue,
      3.5,
    );
    _polyline(
      [const Offset(19, 17), const Offset(20, 8), const Offset(14, 5)],
      blue,
      3.5,
    );
    _line(9, 5, 12, 7, warm, 2.6);
    _line(15, 5, 12, 7, warm, 2.6);
    _circle(10.5, 12, .6, ink);
    _circle(13.5, 12, .6, ink);
  }

  void _badge() {
    _polygon([
      const Offset(6, 13),
      const Offset(5, 23),
      const Offset(10, 20),
      const Offset(13, 22),
      const Offset(14, 13),
    ], warm);
    _polygon([
      const Offset(13, 13),
      const Offset(13, 22),
      const Offset(17, 20),
      const Offset(21, 22),
      const Offset(19, 12),
    ], warm);
    _circle(12, 9, 8.5, override == null ? green : light);
    _polyline(
      [const Offset(7, 9), const Offset(11, 13), const Offset(17, 5)],
      override ?? Colors.white,
      2,
    );
  }

  void _sun() {
    _circle(12, 12, 5.5, warm);
    _circle(10, 11, .65, blue);
    _circle(14, 11, .65, blue);
    canvas.drawArc(
      const Rect.fromLTWH(9.5, 10, 5, 5),
      .3,
      2.5,
      false,
      _stroke(blue, .9),
    );
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      _line(
        12 + math.cos(angle) * 8.5,
        12 + math.sin(angle) * 8.5,
        12 + math.cos(angle) * 10.5,
        12 + math.sin(angle) * 10.5,
        warm,
        2,
      );
    }
  }
}

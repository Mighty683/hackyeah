import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../ui/basebound_ui.dart';
import 'mission_scene_layout.dart';

/// Loads the bundled furniture atlas once; the native plan remains the fallback.
class MissionHomePlan extends StatefulWidget {
  const MissionHomePlan({super.key});

  @override
  State<MissionHomePlan> createState() => _MissionHomePlanState();
}

class _MissionHomePlanState extends State<MissionHomePlan> {
  ImageStream? _stream;
  ImageInfo? _furniture;
  late final _listener = ImageStreamListener(_loaded, onError: (_, _) {});

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final stream = const AssetImage(
      'assets/illustrations/interior-furniture-v1.png',
    ).resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;
    _stream?.removeListener(_listener);
    _stream = stream..addListener(_listener);
  }

  void _loaded(ImageInfo info, bool synchronous) {
    _furniture?.dispose();
    setState(() => _furniture = info);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    _furniture?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: MissionHomePlanPainter(furniture: _furniture?.image),
  );
}

/// Fictional apartment: three windowed rooms and a windowless inside hallway.
/// Furniture is drawn as small top-down sprites so openings remain readable.
class MissionHomePlanPainter extends CustomPainter {
  const MissionHomePlanPainter({this.furniture});

  final ui.Image? furniture;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(
      size.width / missionSceneSize.width,
      size.height / missionSceneSize.height,
    );
    _floors(canvas);
    if (furniture == null) {
      _livingRoom(canvas);
      _bedroom(canvas);
      _kitchen(canvas);
    } else {
      _furnishedPlan(canvas);
    }
    _walls(canvas);
    _window(canvas, const Rect.fromLTWH(70, 43, 70, 14));
    _window(canvas, const Rect.fromLTWH(260, 43, 76, 14));
    _window(canvas, const Rect.fromLTWH(17, 350, 14, 74));
    _door(canvas, const Offset(178, 224), opensLeft: true);
    _door(canvas, const Offset(178, 400), opensLeft: true);
    _door(canvas, const Offset(230, 267), opensLeft: false, extent: 48);
    _entryDoor(canvas);
    _bedroomReadingCorner(canvas);
    canvas.restore();
  }

  void _furnishedPlan(Canvas canvas) {
    _sprite(
      canvas,
      const Rect.fromLTWH(43, 151, 119, 78),
      color: BaseboundColors.peach,
      radius: 8,
    );
    _furnitureSprite(
      canvas,
      const Rect.fromLTRB(40, 190, 533, 484),
      const Rect.fromLTWH(47, 132, 109, 65),
    );
    _sprite(
      canvas,
      const Rect.fromLTWH(76, 205, 54, 24),
      color: BaseboundColors.peach,
      radius: 8,
    );
    _sprite(
      canvas,
      const Rect.fromLTWH(66, 78, 70, 8),
      color: BaseboundColors.muted,
      radius: 2,
    );
    _furnitureSprite(
      canvas,
      const Rect.fromLTRB(873, 734, 1215, 1108),
      const Rect.fromLTWH(43, 88, 25, 27),
    );
    _furnitureSprite(
      canvas,
      const Rect.fromLTRB(590, 50, 845, 596),
      const Rect.fromLTWH(245, 82, 66, 135),
    );
    _sprite(
      canvas,
      const Rect.fromLTWH(340, 85, 22, 112),
      color: BaseboundColors.peach,
    );
    _line(
      canvas,
      const Offset(351, 87),
      const Offset(351, 195),
      color: BaseboundColors.border,
      width: 1.5,
    );
    _sprite(
      canvas,
      const Rect.fromLTWH(316, 94, 20, 25),
      color: BaseboundColors.peach,
    );
    _furnitureSprite(
      canvas,
      const Rect.fromLTRB(990, 45, 1160, 597),
      const Rect.fromLTWH(36, 331, 33, 103),
    );
    _furnitureSprite(
      canvas,
      const Rect.fromLTRB(120, 650, 285, 1205),
      const Rect.fromLTWH(36, 434, 33, 103),
    );
    _sprite(
      canvas,
      const Rect.fromLTWH(69, 509, 96, 27),
      color: BaseboundColors.peach,
    );
    _sprite(canvas, const Rect.fromLTWH(114, 337, 49, 55));
    _line(
      canvas,
      const Offset(115, 354),
      const Offset(162, 354),
      color: BaseboundColors.border,
      width: 1.5,
    );
    _line(canvas, const Offset(153, 363), const Offset(153, 374), width: 2);
    _furnitureSprite(
      canvas,
      const Rect.fromLTRB(428, 732, 805, 1090),
      const Rect.fromLTWH(91, 425, 78, 74),
    );
  }

  void _furnitureSprite(Canvas canvas, Rect source, Rect destination) {
    final sheet = furniture;
    if (sheet == null) return;
    final fit = applyBoxFit(BoxFit.contain, source.size, destination.size);
    canvas.drawImageRect(
      sheet,
      source,
      Alignment.center.inscribe(fit.destination, destination),
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  void _floors(Canvas canvas) {
    _panel(canvas, const Rect.fromLTWH(0, 0, 400, 600), BaseboundColors.cream);
    final floor = RRect.fromRectAndRadius(
      const Rect.fromLTWH(24, 50, 352, 504),
      const Radius.circular(12),
    );
    canvas.save();
    canvas.clipRRect(floor);
    canvas.drawRRect(floor, Paint()..color = const Color(0xFFF1E5D3));
    // All rooms share one continuous timber floor. Short staggered joints read
    // as floorboards, rather than a grid from an architectural drawing.
    for (var row = 0; row < 16; row++) {
      final y = 58.0 + row * 32;
      _line(
        canvas,
        Offset(24, y),
        Offset(376, y),
        color: const Color(0xFFE3D2BA),
        width: .8,
      );
      for (var x = 54.0 + (row.isEven ? 0 : 58); x < 376; x += 116) {
        _line(
          canvas,
          Offset(x, y),
          Offset(x, y + 32),
          color: const Color(0xFFE3D2BA),
          width: .8,
        );
      }
    }
    canvas.restore();
    _sprite(
      canvas,
      const Rect.fromLTWH(188, 370, 32, 126),
      color: BaseboundColors.sky,
      radius: 12,
      outline: BaseboundColors.sky,
    );
  }

  void _walls(Canvas canvas) {
    // A central hallway connects three rooms and the actual front door. The
    // bedroom uses the whole right side; there is no inset room or double shell.
    for (final (start, end) in [
      (const Offset(24, 50), const Offset(70, 50)),
      (const Offset(140, 50), const Offset(260, 50)),
      (const Offset(336, 50), const Offset(376, 50)),
      (const Offset(24, 50), const Offset(24, 350)),
      (const Offset(24, 424), const Offset(24, 554)),
      (const Offset(376, 50), const Offset(376, 554)),
      (const Offset(24, 554), const Offset(182, 554)),
      (const Offset(226, 554), const Offset(376, 554)),
    ]) {
      _wall(canvas, start, end, width: 16);
    }
    for (final (start, end) in [
      (const Offset(178, 50), const Offset(178, 224)),
      (const Offset(178, 266), const Offset(178, 400)),
      (const Offset(178, 442), const Offset(178, 554)),
      (const Offset(230, 50), const Offset(230, 267)),
      (const Offset(230, 315), const Offset(230, 554)),
      (const Offset(24, 292), const Offset(178, 292)),
    ]) {
      _wall(canvas, start, end);
    }
  }

  void _wall(Canvas canvas, Offset start, Offset end, {double width = 12}) {
    // Painted wall faces and soft caps give the cutaway a dollhouse feel.
    // Keep the shading on the illustration, separate from the action controls.
    for (final (offset, color, stroke) in [
      (const Offset(0, 4), const Color(0xFFD4C1A5), width + 2),
      (Offset.zero, const Color(0xFFF4EADB), width),
      (const Offset(0, -2), const Color(0xFFFFFCF5), width * .42),
    ]) {
      canvas.drawLine(
        start + offset,
        end + offset,
        Paint()
          ..color = color
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _bedroomReadingCorner(Canvas canvas) {
    _sprite(
      canvas,
      const Rect.fromLTWH(251, 407, 105, 115),
      color: BaseboundColors.peach,
      radius: 14,
      outline: BaseboundColors.peach,
    );
    if (furniture != null) {
      _furnitureSprite(
        canvas,
        const Rect.fromLTRB(428, 732, 805, 1090),
        const Rect.fromLTWH(264, 431, 79, 75),
      );
      _furnitureSprite(
        canvas,
        const Rect.fromLTRB(873, 734, 1215, 1108),
        const Rect.fromLTWH(337, 367, 25, 27),
      );
    } else {
      _sprite(
        canvas,
        const Rect.fromLTWH(275, 434, 55, 70),
        color: BaseboundColors.peach,
        radius: 6,
      );
      _plant(canvas, const Offset(347, 380));
    }
  }

  void _livingRoom(Canvas canvas) {
    _sprite(
      canvas,
      const Rect.fromLTWH(43, 155, 119, 65),
      color: BaseboundColors.peach,
      radius: 8,
    );
    _sprite(
      canvas,
      const Rect.fromLTWH(53, 143, 95, 48),
      color: BaseboundColors.sky,
      radius: 6,
    );
    _sprite(
      canvas,
      const Rect.fromLTWH(53, 139, 95, 12),
      color: BaseboundColors.sky,
      radius: 4,
    );
    _sprite(
      canvas,
      const Rect.fromLTWH(47, 149, 12, 38),
      color: BaseboundColors.sky,
      radius: 4,
    );
    _sprite(
      canvas,
      const Rect.fromLTWH(143, 149, 12, 38),
      color: BaseboundColors.sky,
      radius: 4,
    );
    _line(
      canvas,
      const Offset(101, 152),
      const Offset(101, 185),
      color: BaseboundColors.border,
      width: 1.5,
    );
    _sprite(canvas, const Rect.fromLTWH(73, 199, 58, 23), radius: 8);
    _sprite(
      canvas,
      const Rect.fromLTWH(89, 202, 17, 11),
      color: BaseboundColors.sky,
      radius: 2,
    );
    _sprite(
      canvas,
      const Rect.fromLTWH(66, 78, 70, 8),
      color: BaseboundColors.muted,
      radius: 2,
    );
    _plant(canvas, const Offset(52, 91));
  }

  void _bedroom(Canvas canvas) {
    _sprite(canvas, const Rect.fromLTWH(246, 85, 62, 110), radius: 5);
    _sprite(
      canvas,
      const Rect.fromLTWH(252, 91, 50, 99),
      color: BaseboundColors.sky,
      radius: 4,
    );
    _sprite(canvas, const Rect.fromLTWH(256, 97, 42, 20), radius: 5);
    _line(
      canvas,
      const Offset(252, 126),
      const Offset(302, 126),
      color: BaseboundColors.blue,
      width: 2,
    );
    _sprite(canvas, const Rect.fromLTWH(316, 92, 19, 26));
    canvas.drawCircle(
      const Offset(325, 104),
      5,
      Paint()..color = BaseboundColors.peach,
    );
    _sprite(canvas, const Rect.fromLTWH(340, 85, 22, 112));
    _line(
      canvas,
      const Offset(351, 87),
      const Offset(351, 195),
      color: BaseboundColors.border,
      width: 1.5,
    );
    _sprite(canvas, const Rect.fromLTWH(249, 212, 56, 18));
    _sprite(
      canvas,
      const Rect.fromLTWH(268, 219, 19, 17),
      color: BaseboundColors.sky,
      radius: 4,
    );
  }

  void _kitchen(Canvas canvas) {
    _sprite(canvas, const Rect.fromLTWH(36, 332, 33, 204));
    _sprite(canvas, const Rect.fromLTWH(69, 509, 96, 27));
    for (var y = 394.0; y < 509; y += 38) {
      _line(
        canvas,
        Offset(37, y),
        Offset(68, y),
        color: BaseboundColors.border,
        width: 1.5,
      );
    }
    _sprite(
      canvas,
      const Rect.fromLTWH(40, 343, 25, 38),
      color: BaseboundColors.sky,
    );
    for (final center in [
      const Offset(46, 353),
      const Offset(59, 353),
      const Offset(46, 371),
      const Offset(59, 371),
    ]) {
      canvas.drawCircle(
        center,
        4,
        Paint()
          ..color = BaseboundColors.muted
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
    _sprite(
      canvas,
      const Rect.fromLTWH(41, 440, 22, 33),
      color: BaseboundColors.sky,
      radius: 4,
    );
    _line(canvas, const Offset(53, 439), const Offset(53, 447), width: 2);
    _sprite(canvas, const Rect.fromLTWH(114, 337, 49, 55));
    _line(
      canvas,
      const Offset(115, 354),
      const Offset(162, 354),
      color: BaseboundColors.border,
      width: 1.5,
    );
    _line(canvas, const Offset(153, 363), const Offset(153, 374), width: 2);
    _sprite(
      canvas,
      const Rect.fromLTWH(107, 439, 13, 26),
      color: BaseboundColors.sky,
      radius: 4,
    );
    _sprite(
      canvas,
      const Rect.fromLTWH(157, 439, 13, 26),
      color: BaseboundColors.sky,
      radius: 4,
    );
    _sprite(canvas, const Rect.fromLTWH(119, 427, 38, 49), radius: 8);
    for (final center in [const Offset(129, 441), const Offset(147, 462)]) {
      canvas.drawCircle(center, 5, Paint()..color = BaseboundColors.sky);
    }
  }

  void _plant(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 10, Paint()..color = BaseboundColors.peach);
    for (final delta in [
      const Offset(-3, -3),
      const Offset(4, -2),
      const Offset(0, 4),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: center + delta, width: 9, height: 7),
        Paint()..color = BaseboundColors.muted,
      );
    }
  }

  void _window(Canvas canvas, Rect bounds) {
    _sprite(
      canvas,
      bounds,
      color: BaseboundColors.sky,
      radius: 0,
      outline: BaseboundColors.blue,
    );
    final horizontal = bounds.width > bounds.height;
    _line(
      canvas,
      horizontal ? bounds.centerLeft : bounds.topCenter,
      horizontal ? bounds.centerRight : bounds.bottomCenter,
      color: BaseboundColors.blue,
      width: 1,
    );
    _line(
      canvas,
      horizontal ? bounds.topCenter : bounds.centerLeft,
      horizontal ? bounds.bottomCenter : bounds.centerRight,
      color: BaseboundColors.blue,
      width: 1,
    );
  }

  void _door(
    Canvas canvas,
    Offset hinge, {
    required bool opensLeft,
    double extent = 42,
  }) {
    final left = opensLeft ? hinge.dx - extent : hinge.dx;
    _sprite(
      canvas,
      Rect.fromLTWH(left, hinge.dy - 4, extent, 8),
      color: const Color(0xFFCDA578),
      radius: 3,
      outline: const Color(0xFFB88D5F),
    );
    canvas.drawCircle(
      Offset(opensLeft ? left + 7 : left + extent - 7, hinge.dy),
      1.8,
      Paint()..color = const Color(0xFF947244),
    );
  }

  void _entryDoor(Canvas canvas) {
    _sprite(
      canvas,
      const Rect.fromLTWH(182, 549, 44, 10),
      color: const Color(0xFFCDA578),
      radius: 3,
      outline: const Color(0xFFB88D5F),
    );
    canvas.drawCircle(
      const Offset(218, 554),
      2,
      Paint()..color = const Color(0xFF947244),
    );
    _panel(
      canvas,
      const Rect.fromLTWH(184, 565, 40, 13),
      BaseboundColors.peach,
    );
  }

  void _panel(Canvas canvas, Rect bounds, Color color) =>
      canvas.drawRect(bounds, Paint()..color = color);

  void _sprite(
    Canvas canvas,
    Rect bounds, {
    Color color = Colors.white,
    double radius = 3,
    Color outline = BaseboundColors.border,
  }) {
    final shape = RRect.fromRectAndRadius(bounds, Radius.circular(radius));
    canvas.drawRRect(shape, Paint()..color = color);
    canvas.drawRRect(
      shape,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _line(
    Canvas canvas,
    Offset start,
    Offset end, {
    Color color = BaseboundColors.muted,
    double width = 6,
  }) => canvas.drawLine(
    start,
    end,
    Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.square,
  );

  @override
  bool shouldRepaint(MissionHomePlanPainter oldDelegate) =>
      furniture != oldDelegate.furniture;
}

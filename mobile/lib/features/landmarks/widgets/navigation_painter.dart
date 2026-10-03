import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../game/maps/demo_map.dart';
import '../../../ui/basebound_ui.dart';

class NavigationPainter extends CustomPainter {
  NavigationPainter({
    required this.map,
    required this.position,
    required this.route,
    required this.zoom,
  });
  final DemoMap map;
  final Position? position;
  final List<Vector2> route;
  final double zoom;
  @override
  void paint(Canvas canvas, Size size) {
    Offset project(Vector2 point) => Offset(
      (point.x - DemoMap.mapLeft) / DemoMap.mapSize * size.width,
      (point.y - DemoMap.mapTop) / DemoMap.mapSize * size.height,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (route.isNotEmpty) {
      final first = project(route.first);
      final path = Path()..moveTo(first.dx, first.dy);
      for (final point in route.skip(1)) {
        final offset = project(point);
        path.lineTo(offset.dx, offset.dy);
      }
      canvas.drawPath(
        path,
        paint
          ..color = Colors.white
          ..strokeWidth = 7 / zoom,
      );
      canvas.drawPath(
        path,
        paint
          ..color = BaseboundColors.blue
          ..strokeWidth = 4 / zoom,
      );
      canvas.drawCircle(
        project(route.last),
        8 / zoom,
        paint..strokeWidth = 3 / zoom,
      );
    }
    final fix = position;
    if (fix == null) return;
    final dot = project(map.project([fix.longitude, fix.latitude]));
    final radius = fix.accuracy / 2000 * size.width;
    canvas.drawCircle(
      dot,
      radius,
      paint
        ..style = PaintingStyle.fill
        ..color = BaseboundColors.blue.withValues(alpha: .14),
    );
    canvas.drawCircle(
      dot,
      radius,
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 / zoom
        ..color = BaseboundColors.blue.withValues(alpha: .5),
    );
    canvas.drawCircle(
      dot,
      10 / zoom,
      paint
        ..style = PaintingStyle.fill
        ..color = Colors.white,
    );
    canvas.drawCircle(dot, 7 / zoom, paint..color = BaseboundColors.blue);
  }

  @override
  bool shouldRepaint(covariant NavigationPainter old) =>
      old.position != position || old.route != route || old.zoom != zoom;
}

import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../maps/demo_map.dart';
import '../maps/offline_router.dart';

/// A bordered path, direction chevrons and an endpoint ring, visible at any zoom.
class PracticeRouteComponent extends Component {
  PracticeRouteComponent({required this.points, this.blockage});

  final List<Vector2> Function() points;
  final PracticeBlockage? Function()? blockage;
  final _paint = Paint();

  @override
  void render(Canvas canvas) {
    final route = points();
    final transform = canvas.getTransform();
    final scale = math.max(
      .01,
      math.sqrt(transform[0] * transform[0] + transform[1] * transform[1]),
    );
    _drawBlockage(canvas, scale);
    if (route.isEmpty) return;
    final path = Path()..moveTo(route.first.x, route.first.y);
    for (final point in route.skip(1)) {
      path.lineTo(point.x, point.y);
    }
    _paint
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 7 / scale
      ..color = const Color(0xFFFFFFFF);
    canvas.drawPath(path, _paint);
    _paint
      ..strokeWidth = 4 / scale
      ..color = const Color(0xFF235B83);
    canvas.drawPath(path, _paint);
    // Spacing follows the entire polyline, not individual short source segments.
    var untilArrow = 28 / scale;
    for (var i = 1; i < route.length; i++) {
      final delta = route[i] - route[i - 1];
      final length = delta.length;
      if (length == 0) continue;
      final direction = delta / length;
      while (untilArrow < length) {
        final tip = route[i - 1] + direction * untilArrow;
        final back = tip - direction * (5 / scale);
        final normal = Vector2(-direction.y, direction.x) * (3 / scale);
        _paint
          ..strokeWidth = 1.8 / scale
          ..color = const Color(0xFFFFFFFF);
        canvas.drawPath(
          Path()
            ..moveTo((back + normal).x, (back + normal).y)
            ..lineTo(tip.x, tip.y)
            ..lineTo((back - normal).x, (back - normal).y),
          _paint,
        );
        untilArrow += 28 / scale;
      }
      untilArrow -= length;
    }
    _paint
      ..strokeWidth = 3 / scale
      ..color = const Color(0xFF235B83);
    canvas.drawCircle(route.last.toOffset(), 8 / scale, _paint);
  }

  void _drawBlockage(Canvas canvas, double scale) {
    final area = blockage?.call();
    if (area == null) return;
    canvas.save();
    canvas.clipRect(
      const Rect.fromLTWH(
        DemoMap.mapLeft,
        DemoMap.mapTop,
        DemoMap.mapSize,
        DemoMap.mapSize,
      ),
    );
    final center = area.center.toOffset();
    _paint
      ..style = PaintingStyle.fill
      ..color = const Color(0x66DA6A37);
    canvas.drawCircle(center, area.radius, _paint);
    _paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 / scale
      ..color = const Color(0xFF8A351E);
    canvas.drawCircle(center, area.radius, _paint);
    final cross = 4 / scale;
    canvas.drawLine(
      center + Offset(-cross, -cross),
      center + Offset(cross, cross),
      _paint,
    );
    canvas.drawLine(
      center + Offset(-cross, cross),
      center + Offset(cross, -cross),
      _paint,
    );
    canvas.restore();
  }
}

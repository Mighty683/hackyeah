import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

/// Screen-fixed bearing to the practice target, never a route instruction.
class TargetIndicatorComponent extends Component {
  TargetIndicatorComponent({
    required this.camera,
    required this.target,
    required this.isActive,
  });

  final CameraComponent camera;
  final Vector2 target;
  final bool Function() isActive;
  final _paint = Paint();

  @override
  void render(Canvas canvas) {
    if (!isActive()) return;
    final size = camera.viewport.virtualSize;
    final targetPoint = camera.viewfinder.localToGlobal(target).toOffset();
    final viewport = Rect.fromLTWH(0, 0, size.x, size.y);
    if (viewport.contains(targetPoint)) return;

    // Intersect the bearing ray with an inset rectangle. The complete badge
    // stays inside the rounded map corners, including diagonal bearings.
    final center = viewport.center;
    final direction = targetPoint - center;
    final inset = viewport.deflate(30);
    final horizontal = direction.dx == 0
        ? double.infinity
        : inset.width / 2 / direction.dx.abs();
    final vertical = direction.dy == 0
        ? double.infinity
        : inset.height / 2 / direction.dy.abs();
    final position = center + direction * math.min(horizontal, vertical);

    canvas.save();
    canvas.translate(position.dx, position.dy);
    _paint
      ..style = PaintingStyle.fill
      ..color = const Color(0x330F2542);
    canvas.drawCircle(const Offset(0, 2), 23, _paint);
    _paint.color = const Color(0xFFFFFEF8);
    canvas.drawCircle(Offset.zero, 23, _paint);
    _paint.color = const Color(0xFF244F80);
    canvas.drawCircle(Offset.zero, 20, _paint);
    canvas.rotate(math.atan2(direction.dy, direction.dx));
    _paint.color = const Color(0xFFFFDB83);
    canvas.drawPath(
      Path()
        ..moveTo(12, 0)
        ..lineTo(-1, -10)
        ..lineTo(-1, -4)
        ..lineTo(-11, -4)
        ..lineTo(-11, 4)
        ..lineTo(-1, 4)
        ..lineTo(-1, 10)
        ..close(),
      _paint,
    );
    canvas.restore();
  }
}

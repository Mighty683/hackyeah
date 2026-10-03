import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../maps/demo_map.dart';

/// Demo character moving toward a point selected on the neighborhood map.
class PlayerComponent extends PositionComponent {
  PlayerComponent({required Vector2 startPosition})
    : super(
        position: startPosition,
        size: Vector2.all(34),
        anchor: Anchor.center,
      );

  // A close view needs time to recognise nearby landmarks while moving.
  static const speed = 30.0;
  final _paint = Paint();
  Vector2? _destination;

  void moveTo(Vector2 destination) {
    _destination = destination.clone();
  }

  void reset(Vector2 startPosition) {
    position.setFrom(startPosition);
    _destination = null;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final destination = _destination;
    if (destination == null) return;

    final distance = destination - position;
    final step = speed * dt;
    if (distance.length <= step) {
      position.setFrom(destination);
      _destination = null;
      return;
    }
    position.add(distance.normalized() * step);
  }

  /// Drawn bounds only: movement, component size and arrival stay unchanged.
  Rect markerBounds(double canvasScale) {
    final inset = math.min(
      math.min(
        position.x - DemoMap.mapLeft,
        DemoMap.mapLeft + DemoMap.mapSize - position.x,
      ),
      math.min(
        position.y - DemoMap.mapTop,
        DemoMap.mapTop + DemoMap.mapSize - position.y,
      ),
    );
    return Rect.fromCircle(
      center: position.toOffset(),
      radius: math.max(0, math.min(15 / canvasScale, inset)),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final transform = canvas.getTransform();
    final scale = math.max(
      0.01,
      math.sqrt(transform[0] * transform[0] + transform[1] * transform[1]),
    );
    final radius = markerBounds(scale).width / 2;
    // Keep the center true to the map; shrink only when close to its edges.
    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(
        DemoMap.mapLeft - position.x + 17,
        DemoMap.mapTop - position.y + 17,
        DemoMap.mapSize,
        DemoMap.mapSize,
      ),
    );
    canvas.translate(17, 17);
    canvas.scale(radius / 15);
    _paint
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(Offset.zero, 15, _paint);
    _paint.color = const Color(0xFF315D77);
    canvas.drawCircle(Offset.zero, 13.5, _paint);
    // A face and shoulders read as a person, not another destination pin.
    _paint.color = const Color(0xFFF2C79D);
    canvas.drawCircle(const Offset(0, -4), 5.5, _paint);
    _paint.color = const Color(0xFF243D50);
    canvas.drawArc(
      const Rect.fromLTWH(-5.5, -9.5, 11, 10),
      math.pi,
      math.pi,
      true,
      _paint,
    );
    _paint.color = const Color(0xFFFFF4D5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-8, 3, 8, 11),
        const Radius.circular(5),
      ),
      _paint,
    );
    _paint.color = const Color(0xFF243D50);
    canvas.drawCircle(const Offset(-2, -4), 0.8, _paint);
    canvas.drawCircle(const Offset(2, -4), 0.8, _paint);
    _paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      const Rect.fromLTWH(-2, -3, 4, 3),
      0,
      math.pi,
      false,
      _paint,
    );
    canvas.restore();
  }
}

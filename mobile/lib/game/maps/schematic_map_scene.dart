import 'dart:math' as math;

import 'package:flame/extensions.dart';
import 'package:flutter/painting.dart';

import 'demo_map.dart';

/// A deliberately incomplete practice diagram, not a street-navigation map.
/// OSM supplies positions and a few broad outlines; artwork replaces its detail.
class SchematicMapScene {
  SchematicMapScene(DemoMap map) {
    for (final feature in map.features) {
      if (feature.id == 'relation/61707') {
        park = _polygonPath(map, feature);
      } else if (feature.id == 'way/423699174') {
        pond = _polygonPath(map, feature);
      } else if (feature.id == 'way/164250193') {
        shop = _polygonPath(map, feature).getBounds().center;
      } else if (feature.properties['waterway'] == 'river' &&
          feature.properties['name'] == 'Wisła') {
        river.add(_linePath(map, feature));
      } else if (feature.layer == 'road' &&
          _roadNames.contains(feature.properties['name']) &&
          feature.properties['highway'] == 'secondary') {
        roads.add(_linePath(map, feature));
      }
    }
    arena = map.project(map.center).toOffset();
    _prepareTrees();
  }

  static const _roadNames = {
    'Aleja Jana Pawła II',
    'Aleja Pokoju',
    'Mogilska',
    'Stanisława Lema',
    'Nowohucka',
    'Izydora Stella-Sawickiego',
    'Janusza Meissnera',
  };

  Path park = Path();
  Path pond = Path();
  Offset? shop;
  late final Offset arena;
  final roads = <Path>[];
  final river = <Path>[];
  final _trees = <Offset>[];
  final _paint = Paint();

  Offset? get parkLabel => park.getBounds().isEmpty
      ? null
      : Offset(park.getBounds().center.dx, park.getBounds().top + 68);
  Offset? get pondLabel =>
      pond.getBounds().isEmpty ? null : pond.getBounds().center;

  void paint(Canvas canvas, double scale) {
    _fill(const Color(0xFFF9F3E4));
    canvas.drawRect(
      const Rect.fromLTWH(
        DemoMap.mapLeft,
        DemoMap.mapTop,
        DemoMap.mapSize,
        DemoMap.mapSize,
      ),
      _paint,
    );
    _fill(const Color(0xFFD4E7AC));
    canvas.drawPath(park, _paint);
    _stroke(const Color(0xFFAEC77C), 1.5);
    canvas.drawPath(park, _paint);
    _fill(const Color(0xFF95D5E5));
    canvas.drawPath(pond, _paint);
    _stroke(const Color(0xFF63B4CD), 1.5);
    canvas.drawPath(pond, _paint);
    _stroke(const Color(0xFF95D5E5), 20);
    for (final path in river) {
      canvas.drawPath(path, _paint);
    }
    _paintRoads(canvas);
    for (final tree in _trees) {
      _paintTree(canvas, tree);
    }
    _paintPondRipples(canvas);
    _paintArena(canvas, scale);
    final shopPosition = shop;
    if (shopPosition != null) _paintShop(canvas, shopPosition, scale);
  }

  void _paintRoads(Canvas canvas) {
    _stroke(const Color(0xFFDCCCA8), 12);
    for (final path in roads) {
      canvas.drawPath(path, _paint);
    }
    _stroke(const Color(0xFFFFFEF8), 8);
    for (final path in roads) {
      canvas.drawPath(path, _paint);
    }
  }

  void _prepareTrees() {
    final bounds = park.getBounds();
    if (bounds.isEmpty) return;
    for (var row = 0; row < 4; row++) {
      for (var column = 0; column < 3; column++) {
        final point = Offset(
          bounds.left + 26 + column * 58 + (row.isOdd ? 10 : 0),
          bounds.top + 25 + row * 48,
        );
        if (!park.contains(point) || (point - arena).distance <= 42) continue;
        _trees.add(point);
      }
    }
  }

  void _paintTree(Canvas canvas, Offset point) {
    _fill(const Color(0xFF62853D));
    canvas.drawOval(
      Rect.fromCenter(center: point, width: 19, height: 6),
      _paint,
    );
    _stroke(const Color(0xFF95704B), 3);
    canvas.drawLine(point, point - const Offset(0, 11), _paint);
    _fill(const Color(0xFF7AAA53));
    canvas.drawCircle(point - const Offset(0, 13), 9, _paint);
    _fill(const Color(0xFF90BC64));
    canvas.drawCircle(point - const Offset(4, 15), 5, _paint);
  }

  void _paintPondRipples(Canvas canvas) {
    final bounds = pond.getBounds();
    if (bounds.isEmpty) return;
    _stroke(const Color(0xFFDDF6F8), 1.5);
    for (final dy in [-5.0, 4.0]) {
      final center = bounds.center + Offset(0, dy);
      canvas.drawLine(
        center - const Offset(7, 0),
        center + const Offset(7, 0),
        _paint,
      );
    }
  }

  double illustrationRadius(double scale) =>
      math.max(23, math.min(23 / scale, 34));

  void _paintArena(Canvas canvas, double scale) {
    final radius = illustrationRadius(scale);
    canvas.save();
    canvas.translate(arena.dx, arena.dy);
    canvas.scale(radius / 23);
    _fill(const Color(0xFFB9ACCE));
    canvas.drawOval(const Rect.fromLTRB(-24, -13, 24, 20), _paint);
    _fill(const Color(0xFFB9B0DE));
    canvas.drawOval(const Rect.fromLTRB(-24, -20, 24, 12), _paint);
    _stroke(const Color(0xFF786994), 1.5);
    canvas.drawOval(const Rect.fromLTRB(-24, -20, 24, 12), _paint);
    _fill(const Color(0xFFEDE7F7));
    canvas.drawOval(const Rect.fromLTRB(-18, -15, 18, 6), _paint);
    _fill(const Color(0xFF9B8EC3));
    canvas.drawOval(const Rect.fromLTRB(-12, -11, 12, 2), _paint);
    _stroke(const Color(0xFF786994), 2);
    for (final x in [-15.0, -7.0, 7.0, 15.0]) {
      canvas.drawLine(Offset(x, 10), Offset(x, 16), _paint);
    }
    _fill(const Color(0xFF63527E));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-4, 9, 4, 20),
        const Radius.circular(2),
      ),
      _paint,
    );
    canvas.restore();
  }

  void _paintShop(Canvas canvas, Offset center, double scale) {
    final radius = illustrationRadius(scale);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(radius / 23);
    _fill(const Color(0xFFE8D9B9));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-23, -13, 23, 19),
        const Radius.circular(4),
      ),
      _paint,
    );
    _fill(const Color(0xFFFFF9E8));
    canvas.drawRect(const Rect.fromLTRB(-19, -6, 19, 16), _paint);
    _fill(const Color(0xFFBBDDE0));
    canvas.drawRect(const Rect.fromLTRB(-15, -2, -2, 11), _paint);
    canvas.drawRect(const Rect.fromLTRB(6, -2, 15, 16), _paint);
    _fill(const Color(0xFFDD8269));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(-25, -17, 25, -5),
        const Radius.circular(3),
      ),
      _paint,
    );
    _fill(const Color(0xFFFFF3D4));
    for (final x in [-16.0, -2.0, 12.0]) {
      canvas.drawRect(Rect.fromLTWH(x, -17, 7, 12), _paint);
    }
    _stroke(const Color(0xFF9C6851), 1.5);
    canvas.drawLine(const Offset(-25, -5), const Offset(25, -5), _paint);
    canvas.restore();
  }

  void _fill(Color color) {
    _paint
      ..style = PaintingStyle.fill
      ..color = color;
  }

  void _stroke(Color color, double width) {
    _paint
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }

  static Path _polygonPath(DemoMap map, DemoMapFeature feature) {
    final path = Path()..fillType = PathFillType.evenOdd;
    final polygons = feature.geometryType == 'MultiPolygon'
        ? feature.coordinates
        : [feature.coordinates];
    for (final polygon in polygons) {
      for (final ring in polygon as List) {
        _addOutline(path, _projectPoints(map, ring as List), closed: true);
      }
    }
    return path;
  }

  static Path _linePath(DemoMap map, DemoMapFeature feature) {
    final path = Path();
    final lines = feature.geometryType == 'MultiLineString'
        ? feature.coordinates
        : feature.geometryType == 'LineString'
        ? [feature.coordinates]
        : const <List>[];
    for (final line in lines) {
      _addOutline(path, _projectPoints(map, line as List), closed: false);
    }
    return path;
  }

  static List<Offset> _projectPoints(DemoMap map, List coordinates) => [
    for (final point in coordinates)
      map.project((point as List).cast<num>()).toOffset(),
  ];

  static void _addOutline(
    Path path,
    List<Offset> points, {
    required bool closed,
  }) {
    if (points.length < 2) return;
    final simplified = _simplify(points, 5);
    path.moveTo(simplified.first.dx, simplified.first.dy);
    for (final point in simplified.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    if (closed) path.close();
  }

  /// Iterative line simplification keeps rendering independent of source detail.
  static List<Offset> _simplify(List<Offset> points, double tolerance) {
    final retained = {0, points.length - 1};
    final pending = [(0, points.length - 1)];
    while (pending.isNotEmpty) {
      final (start, end) = pending.removeLast();
      var farthest = tolerance;
      var split = -1;
      for (var index = start + 1; index < end; index++) {
        final distance = _segmentDistance(
          points[index],
          points[start],
          points[end],
        );
        if (distance <= farthest) continue;
        farthest = distance;
        split = index;
      }
      if (split == -1) continue;
      retained.add(split);
      pending.addAll([(start, split), (split, end)]);
    }
    final indexes = retained.toList()..sort();
    return [for (final index in indexes) points[index]];
  }

  static double _segmentDistance(Offset point, Offset start, Offset end) {
    final delta = end - start;
    if (delta.distanceSquared == 0) return (point - start).distance;
    final fraction =
        ((point.dx - start.dx) * delta.dx + (point.dy - start.dy) * delta.dy) /
        delta.distanceSquared;
    final nearest = start + delta * fraction.clamp(0.0, 1.0);
    return (point - nearest).distance;
  }
}

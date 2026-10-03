import 'dart:math' as math;

import 'package:flame/extensions.dart';
import 'package:flutter/painting.dart';

import 'demo_map.dart';

/// Offline practice geography with soft colors and illustrated landmarks.
/// Source outlines give nearby places context; they do not provide safe routes.
class SchematicMapScene {
  SchematicMapScene(DemoMap map) {
    arena = map.project(map.center).toOffset();
    for (final feature in map.features) {
      if (feature.geometryType == 'Point') continue;
      if (feature.layer == 'road') {
        _addRoad(map, feature);
      } else if (feature.layer == 'railway') {
        if (const {'rail', 'tram'}.contains(feature.properties['railway'])) {
          _railways.add(_MapShape(_linePath(map, feature)));
        }
      } else if (feature.layer == 'water') {
        _addWater(map, feature);
      } else if (feature.layer == 'building') {
        _addBuilding(map, feature);
      } else if (_isPolygon(feature)) {
        _addLand(map, feature);
      }
    }
    _prepareTrees();
  }

  late Offset arena;
  Offset? shop;
  Path park = Path();
  Path pond = Path();
  final _districts = <_MapShape>[];
  final _greenAreas = <_MapShape>[];
  final _parks = <_MapShape>[];
  final _woodlands = <_MapShape>[];
  final _waterAreas = <_MapShape>[];
  final _rivers = <_MapShape>[];
  final _streams = <_MapShape>[];
  final _majorRoads = <_MapShape>[];
  final _localRoads = <_MapShape>[];
  final _serviceRoads = <_MapShape>[];
  final _footpaths = <_MapShape>[];
  final _railways = <_MapShape>[];
  final _plazas = <_MapShape>[];
  final _homes = <_MapShape>[];
  final _shops = <_MapShape>[];
  final _publicBuildings = <_MapShape>[];
  final _playgrounds = <_MapShape>[];
  final _pitches = <_MapShape>[];
  final _trees = <Offset>[];
  final _paint = Paint();

  Offset? parkLabelIn(Rect visible) {
    for (final park in _parks) {
      if (!park.bounds.overlaps(visible)) continue;
      final nearby = park.bounds.intersect(visible);
      for (final x in [.5, .25, .75]) {
        for (final y in [.5, .25, .75]) {
          final point = Offset(
            nearby.left + nearby.width * x,
            nearby.top + nearby.height * y,
          );
          if (park.path.contains(point)) return point;
        }
      }
    }
    return null;
  }

  Offset? get pondLabel =>
      pond.getBounds().isEmpty ? null : pond.getBounds().center;

  Offset? playgroundLabelIn(Rect visible, double scale) {
    _MapShape? nearest;
    for (final playground in _playgrounds) {
      if (!visible.contains(playground.bounds.center) ||
          playground.bounds.shortestSide * scale < 14) {
        continue;
      }
      if (nearest == null ||
          (playground.bounds.center - visible.center).distanceSquared <
              (nearest.bounds.center - visible.center).distanceSquared) {
        nearest = playground;
      }
    }
    return nearest?.bounds.center;
  }

  void _addRoad(DemoMap map, DemoMapFeature feature) {
    final highway = feature.properties['highway'];
    if (_isPolygon(feature)) {
      if (const {'pedestrian', 'footway', 'service'}.contains(highway)) {
        _plazas.add(_MapShape(_polygonPath(map, feature)));
      }
      return;
    }
    final shape = _MapShape(_linePath(map, feature));
    if (const {
      'primary',
      'primary_link',
      'secondary',
      'secondary_link',
      'tertiary',
      'tertiary_link',
    }.contains(highway)) {
      _majorRoads.add(shape);
    } else if (const {
      'residential',
      'living_street',
      'unclassified',
      'pedestrian',
    }.contains(highway)) {
      _localRoads.add(shape);
    } else if (highway == 'service') {
      _serviceRoads.add(shape);
    } else if (const {
      'footway',
      'path',
      'cycleway',
      'steps',
      'track',
    }.contains(highway)) {
      _footpaths.add(shape);
    }
  }

  void _addWater(DemoMap map, DemoMapFeature feature) {
    if (_isPolygon(feature)) {
      final path = _polygonPath(map, feature);
      _waterAreas.add(_MapShape(path));
      if (feature.id == 'way/423699174') pond = path;
      return;
    }
    final shape = _MapShape(_linePath(map, feature));
    if (feature.properties['waterway'] == 'river') {
      // River polygons provide their width; the centerline fills small rivers.
      if (feature.properties['name'] != 'Wisła') _rivers.add(shape);
    } else if (feature.properties['waterway'] == 'stream') {
      _streams.add(shape);
    }
  }

  void _addBuilding(DemoMap map, DemoMapFeature feature) {
    if (!_isPolygon(feature)) return;
    final shape = _MapShape(_polygonPath(map, feature));
    final building = feature.properties['building'];
    if (feature.id == 'way/292867512') arena = shape.bounds.center;
    if (feature.id == 'way/164250193') shop = shape.bounds.center;
    if (const {
      'retail',
      'commercial',
      'supermarket',
      'office',
      'warehouse',
      'industrial',
    }.contains(building)) {
      _shops.add(shape);
    } else if (const {
      'school',
      'kindergarten',
      'university',
      'college',
      'church',
      'sports_centre',
      'stadium',
    }.contains(building)) {
      _publicBuildings.add(shape);
    } else {
      _homes.add(shape);
    }
  }

  void _addLand(DemoMap map, DemoMapFeature feature) {
    final shape = _MapShape(_polygonPath(map, feature));
    final landuse = feature.properties['landuse'];
    final natural = feature.properties['natural'];
    final leisure = feature.properties['leisure'];
    if (feature.id == 'relation/61707') park = shape.path;
    if (leisure == 'park') _parks.add(shape);
    if (leisure == 'playground') {
      _playgrounds.add(shape);
    } else if (leisure == 'pitch') {
      _pitches.add(shape);
    } else if (const {'wood', 'scrub', 'shrubbery'}.contains(natural) ||
        landuse == 'forest') {
      _woodlands.add(shape);
    } else if (const {'park', 'garden', 'nature_reserve'}.contains(leisure) ||
        const {
          'grass',
          'meadow',
          'greenery',
          'allotments',
          'recreation_ground',
          'village_green',
          'flowerbed',
        }.contains(landuse) ||
        const {'grassland', 'wetland'}.contains(natural)) {
      _greenAreas.add(shape);
    } else if (const {
      'residential',
      'retail',
      'commercial',
      'industrial',
    }.contains(landuse)) {
      _districts.add(shape);
    } else if (feature.properties['amenity'] == 'parking') {
      _plazas.add(shape);
    }
  }

  void paint(Canvas canvas, double scale) {
    final visible = canvas.getLocalClipBounds().inflate(18 / scale);
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
    _paintAreas(canvas, _districts, visible, const Color(0xFFF0E8D6));
    _paintAreas(canvas, _greenAreas, visible, const Color(0xFFD7E7B6));
    _paintAreas(canvas, _woodlands, visible, const Color(0xFFC3D9A2));
    _paintAreas(canvas, _plazas, visible, const Color(0xFFEAE2CF));
    _paintAreas(canvas, _waterAreas, visible, const Color(0xFF95D5E5));
    _paintLines(canvas, _rivers, visible, const Color(0xFF95D5E5), 1.2);
    _paintLines(canvas, _streams, visible, const Color(0xFF95D5E5), .5);
    _paintRoads(canvas, visible, scale);
    _paintBuildings(canvas, _homes, visible, const Color(0xFFDAC9AF), scale);
    _paintBuildings(canvas, _shops, visible, const Color(0xFFE2BEA9), scale);
    _paintBuildings(
      canvas,
      _publicBuildings,
      visible,
      const Color(0xFFC6BDDA),
      scale,
    );
    _paintPlayAreas(canvas, visible, scale);
    if (scale >= 1.5) {
      for (final tree in _trees) {
        if (visible.contains(tree)) _paintTree(canvas, tree);
      }
    }
    _paintPondRipples(canvas);
    if (Rect.fromCircle(
      center: arena,
      radius: illustrationRadius(scale),
    ).overlaps(visible)) {
      _paintArena(canvas, scale);
    }
    final shopPosition = shop;
    if (shopPosition != null &&
        Rect.fromCircle(
          center: shopPosition,
          radius: illustrationRadius(scale),
        ).overlaps(visible)) {
      _paintShop(canvas, shopPosition, scale);
    }
  }

  void _paintAreas(
    Canvas canvas,
    List<_MapShape> shapes,
    Rect visible,
    Color color,
  ) {
    _fill(color);
    for (final shape in shapes) {
      if (shape.bounds.overlaps(visible)) canvas.drawPath(shape.path, _paint);
    }
  }

  void _paintLines(
    Canvas canvas,
    List<_MapShape> shapes,
    Rect visible,
    Color color,
    double width,
  ) {
    _stroke(color, width);
    for (final shape in shapes) {
      if (shape.bounds.inflate(width).overlaps(visible)) {
        canvas.drawPath(shape.path, _paint);
      }
    }
  }

  void _paintRoads(Canvas canvas, Rect visible, double scale) {
    if (scale >= 1.5) {
      _paintLines(
        canvas,
        _footpaths,
        visible,
        const Color(0xFFEEE7CE),
        math.max(.6, 1.5 / scale),
      );
      _paintLines(canvas, _serviceRoads, visible, const Color(0xFFFCFAEF), 1.2);
    }
    _paintLines(canvas, _localRoads, visible, const Color(0xFFD7CBB2), 2.6);
    _paintLines(canvas, _localRoads, visible, const Color(0xFFFFFEF8), 1.9);
    _paintLines(canvas, _majorRoads, visible, const Color(0xFFD1C0A2), 3.8);
    _paintLines(canvas, _majorRoads, visible, const Color(0xFFFFFEF8), 2.9);
    _paintLines(canvas, _railways, visible, const Color(0xFFB6ADA0), .65);
    if (scale >= 2) {
      _paintLines(canvas, _railways, visible, const Color(0xFFE8E2D4), .25);
    }
  }

  void _paintBuildings(
    Canvas canvas,
    List<_MapShape> buildings,
    Rect visible,
    Color color,
    double scale,
  ) {
    for (final building in buildings) {
      if (!building.bounds.overlaps(visible)) continue;
      // Small sheds become noise in an overview; close zoom shows their outline.
      if (building.bounds.longestSide * scale < 3) continue;
      if (scale >= 2) {
        canvas.save();
        canvas.translate(.45, .65);
        _fill(const Color(0xFFC7BDA7));
        canvas.drawPath(building.path, _paint);
        canvas.restore();
      }
      _fill(color);
      canvas.drawPath(building.path, _paint);
      _stroke(const Color(0xFFAFA28D), math.max(.18, .65 / scale));
      canvas.drawPath(building.path, _paint);
    }
  }

  void _paintPlayAreas(Canvas canvas, Rect visible, double scale) {
    _paintAreas(canvas, _pitches, visible, const Color(0xFFAACB9A));
    _paintAreas(canvas, _playgrounds, visible, const Color(0xFFEAD397));
    if (scale < 2) return;
    for (final pitch in _pitches) {
      final bounds = pitch.bounds.deflate(.6);
      if (!bounds.overlaps(visible) || bounds.shortestSide * scale < 14) {
        continue;
      }
      canvas.save();
      canvas.clipPath(pitch.path);
      _stroke(const Color(0xFFE9F3DD), .3);
      canvas.drawRect(bounds, _paint);
      canvas.drawLine(
        Offset(bounds.left, bounds.center.dy),
        Offset(bounds.right, bounds.center.dy),
        _paint,
      );
      canvas.drawCircle(bounds.center, bounds.shortestSide / 6, _paint);
      canvas.restore();
    }
    for (final playground in _playgrounds) {
      final bounds = playground.bounds;
      if (!bounds.overlaps(visible) || bounds.shortestSide * scale < 18) {
        continue;
      }
      final radius = math.min(3.0, bounds.shortestSide / 3);
      final center = bounds.center;
      _stroke(const Color(0xFFB48A5B), .45);
      canvas.drawLine(
        center + Offset(-radius, radius),
        center - Offset(0, radius),
        _paint,
      );
      canvas.drawLine(
        center + Offset(radius, radius),
        center - Offset(0, radius),
        _paint,
      );
      canvas.drawLine(
        center - Offset(0, radius),
        center + Offset(0, radius / 2),
        _paint,
      );
      _stroke(const Color(0xFFD28C62), .65);
      canvas.drawLine(
        center + Offset(-radius / 2, radius / 2),
        center + Offset(radius / 2, radius / 2),
        _paint,
      );
    }
  }

  // Park trees are decorative texture, not surveyed individual positions.
  void _prepareTrees() {
    final bounds = park.getBounds();
    if (bounds.isEmpty) return;
    final occupiedAreas = [
      ..._homes,
      ..._shops,
      ..._publicBuildings,
      ..._playgrounds,
      ..._plazas,
    ];
    for (var y = bounds.top + 12; y < bounds.bottom; y += 25) {
      for (var x = bounds.left + 12; x < bounds.right; x += 27) {
        final point = Offset(x, y);
        if (!park.contains(point) || (point - arena).distance <= 25) continue;
        final occupied = occupiedAreas.any(
          (shape) => shape.bounds.inflate(3).contains(point),
        );
        if (!occupied) _trees.add(point);
      }
    }
  }

  void _paintTree(Canvas canvas, Offset point) {
    canvas.save();
    canvas.translate(point.dx, point.dy);
    canvas.scale(.3);
    _fill(const Color(0xFF8AA865));
    canvas.drawOval(const Rect.fromLTRB(-9, -3, 9, 3), _paint);
    _stroke(const Color(0xFF95704B), 3);
    canvas.drawLine(Offset.zero, const Offset(0, -11), _paint);
    _fill(const Color(0xFF7AAA53));
    canvas.drawCircle(const Offset(0, -13), 9, _paint);
    _fill(const Color(0xFF90BC64));
    canvas.drawCircle(const Offset(-4, -15), 5, _paint);
    canvas.restore();
  }

  void _paintPondRipples(Canvas canvas) {
    final bounds = pond.getBounds();
    if (bounds.isEmpty) return;
    _stroke(const Color(0xFFDDF6F8), .5);
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
      math.max(12, math.min(18 / scale, 22));

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

  static bool _isPolygon(DemoMapFeature feature) =>
      feature.geometryType == 'Polygon' ||
      feature.geometryType == 'MultiPolygon';

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
    final simplified = _simplify(points, .25);
    path.moveTo(simplified.first.dx, simplified.first.dy);
    for (final point in simplified.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    if (closed) path.close();
  }

  /// Remove tiny source wiggles while retaining street bends and building shape.
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

class _MapShape {
  _MapShape(this.path) : bounds = path.getBounds();

  final Path path;
  final Rect bounds;
}

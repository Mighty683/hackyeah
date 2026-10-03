import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:geolocator/geolocator.dart';

import '../../game/maps/demo_map.dart';
import '../../game/maps/offline_router.dart';

String metres(double distance) => distance < 1000
    ? '${(distance / 5).round() * 5} m'
    : '${(distance / 1000).toStringAsFixed(1)} km';

String compass(double bearing) => const [
  'north',
  'north-east',
  'east',
  'south-east',
  'south',
  'south-west',
  'west',
  'north-west',
][((bearing + 22.5) / 45).floor() % 8];

class WalkingTurn {
  const WalkingTurn({required this.distance, required this.action});
  final double distance;
  final String action;
}

class RouteLocation {
  const RouteLocation(this.progress, this.distance);
  final double progress;
  final double distance;
}

/// Turn cues from the mapped geometry and OSM names, never device heading.
/// They are relative to the route's incoming segment; the map stays north-up.
class WalkingRoute {
  WalkingRoute(this.map, this.path) {
    _distances.add(0);
    for (var i = 1; i < path.points.length; i++) {
      _distances.add(
        _distances.last + _distance(path.points[i - 1], path.points[i]),
      );
    }
    final indices = <int>{0, path.points.length - 1};
    if (path.points.length > 2) _simplify(0, path.points.length - 1, indices);
    for (var i = 1; i < path.segments.length; i++) {
      if (_description(path.segments[i - 1]) !=
          _description(path.segments[i])) {
        indices.add(i);
      }
    }
    final corners = indices.toList()..sort();
    for (var i = 1; i < corners.length - 1; i++) {
      final index = corners[i];
      final incoming = _bearing(
        path.points[corners[i - 1]],
        path.points[index],
      );
      final outgoing = _bearing(
        path.points[index],
        path.points[corners[i + 1]],
      );
      final angle = (outgoing - incoming + 540) % 360 - 180;
      final tags = path.segments[index];
      final description = _description(tags);
      final changed = description != _description(path.segments[index - 1]);
      if (angle.abs() < 35 && !changed) continue;
      final action = angle.abs() >= 150
          ? 'turn back'
          : angle >= 35
          ? 'turn right'
          : angle <= -35
          ? 'turn left'
          : 'continue';
      turns.add(
        WalkingTurn(
          distance: _distances[index],
          action: '$action${description.isEmpty ? '' : ' onto $description'}',
        ),
      );
    }
  }

  final DemoMap map;
  final RoutedPath path;
  final _distances = <double>[];
  final turns = <WalkingTurn>[];
  List<Vector2> get points => path.points;
  double get length => _distances.last;

  double _distance(Vector2 a, Vector2 b) {
    final start = map.unproject(a);
    final end = map.unproject(b);
    return Geolocator.distanceBetween(
      start[1].toDouble(),
      start[0].toDouble(),
      end[1].toDouble(),
      end[0].toDouble(),
    );
  }

  double _bearing(Vector2 a, Vector2 b) {
    final start = map.unproject(a);
    final end = map.unproject(b);
    return (Geolocator.bearingBetween(
              start[1].toDouble(),
              start[0].toDouble(),
              end[1].toDouble(),
              end[0].toDouble(),
            ) +
            360) %
        360;
  }

  static String _description(Map<String, dynamic> tags) {
    if (tags['footway'] == 'crossing') return 'the mapped crossing';
    if (tags['highway'] == 'steps') return 'the steps';
    return (tags['name'] as String?)?.trim() ?? '';
  }

  // Remove artificial segment samples and gentle bends, preserving significant
  // turns within about 3 m of the original line (snapshot axes cover 2 km).
  void _simplify(int start, int end, Set<int> result) {
    var maximum = .6;
    int? candidate;
    for (var i = start + 1; i < end; i++) {
      final distance = _projectOnto(
        points[i],
        points[start],
        points[end],
      ).distanceTo(points[i]);
      if (distance > maximum) {
        maximum = distance;
        candidate = i;
      }
    }
    if (candidate == null) return;
    result.add(candidate);
    _simplify(start, candidate, result);
    _simplify(candidate, end, result);
  }

  static Vector2 _projectOnto(Vector2 point, Vector2 start, Vector2 end) {
    final delta = end - start;
    final fraction = delta.length2 == 0
        ? 0.0
        : ((point - start).dot(delta) / delta.length2).clamp(0.0, 1.0);
    return start + delta * fraction;
  }

  RouteLocation locate(Vector2 position, {double minimumProgress = 0}) {
    var best = RouteLocation(0, _distance(position, points.first));
    for (var i = 1; i < points.length; i++) {
      if (_distances[i] < minimumProgress) continue;
      final closest = _projectOnto(position, points[i - 1], points[i]);
      final distance = _distance(position, closest);
      final progress = _distances[i - 1] + _distance(points[i - 1], closest);
      if (distance < best.distance || best.progress < minimumProgress) {
        best = RouteLocation(progress, distance);
      }
    }
    return best;
  }

  String instructionAt(double progress) {
    if (points.length < 2) return 'The mapped path ends here.';
    final next = turns
        .where((turn) => turn.distance >= progress - 8)
        .firstOrNull;
    if (next != null && next.distance - progress <= 12) {
      return '${_capitalise(next.action)}.';
    }
    final nextPoint = _distances.indexWhere((value) => value > progress);
    final segment = nextPoint < 0
        ? path.segments.length - 1
        : math.max(0, nextPoint - 1);
    final description = _description(path.segments[segment]);
    final direction = compass(_bearing(points[segment], points[segment + 1]));
    final heading =
        'Continue $direction${description.isEmpty ? '' : ' on $description'}';
    if (next != null) {
      return '$heading. In ${metres(next.distance - progress)}, ${next.action}.';
    }
    return '$heading for ${metres(math.max(0, length - progress))}.';
  }

  static String _capitalise(String text) =>
      '${text[0].toUpperCase()}${text.substring(1)}';
}

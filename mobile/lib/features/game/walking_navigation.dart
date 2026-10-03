import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../game/maps/demo_map.dart';
import '../../game/maps/offline_router.dart';
import '../landmarks/data/landmark.dart';
import 'navigation_location.dart';

bool withinMap(DemoMap map, double latitude, double longitude) =>
    longitude >= map.bounds[0] &&
    longitude <= map.bounds[2] &&
    latitude >= map.bounds[1] &&
    latitude <= map.bounds[3];

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

/// GPS drives route progress. Selecting a pin never changes the location.
class WalkingNavigation extends ChangeNotifier {
  WalkingNavigation({required this.map, required this.location})
    : _router = OfflineRouter(map) {
    location.addListener(_update);
  }

  final DemoMap map;
  final NavigationLocation location;
  final OfflineRouter _router;
  bool isCalculating = false;
  int _calculationRevision = 0;
  Landmark? destination;
  WalkingRoute? route;
  double progress = 0;
  double joinDistance = 0;
  double destinationDistance = 0;
  double destinationBearing = 0;
  bool nearPlace = false;
  String? problem;
  bool get outsideMap =>
      location.position != null &&
      !withinMap(
        map,
        location.position!.latitude,
        location.position!.longitude,
      );

  void navigateTo(Landmark place) {
    if (place.isDemo) return;
    _cancelCalculation();
    destination = place;
    route = null;
    progress = 0;
    _update();
  }

  void stop() {
    _cancelCalculation();
    destination = null;
    route = null;
    nearPlace = false;
    problem = null;
    notifyListeners();
  }

  void _update() {
    final fix = location.position;
    final target = destination;
    nearPlace = false;
    problem = null;
    if (fix == null || !location.isPrecise || outsideMap || target == null) {
      _cancelCalculation();
      route = null;
      progress = 0;
      notifyListeners();
      return;
    }
    if (!withinMap(map, target.latitude, target.longitude)) {
      _cancelCalculation();
      route = null;
      problem = 'This place is outside the downloaded map.';
      notifyListeners();
      return;
    }
    destinationDistance = Geolocator.distanceBetween(
      fix.latitude,
      fix.longitude,
      target.latitude,
      target.longitude,
    );
    destinationBearing =
        (Geolocator.bearingBetween(
              fix.latitude,
              fix.longitude,
              target.latitude,
              target.longitude,
            ) +
            360) %
        360;
    nearPlace = destinationDistance <= 20 && fix.accuracy <= 20;
    final point = map.project([fix.longitude, fix.latitude]);
    final existing = route;
    if (existing != null) {
      final nearest = existing.locate(point, minimumProgress: progress - 10);
      // Retain the route and its turn instructions while on it; replan only
      // after an accurate fix is more than 25 m from the mapped path.
      if (nearest.distance <= 25) {
        progress = math.max(progress, nearest.progress);
        joinDistance = nearest.distance;
        notifyListeners();
        return;
      }
    }
    if (!isCalculating) {
      _calculate(point, map.project([target.longitude, target.latitude]));
    }
  }

  void _cancelCalculation() {
    _calculationRevision++;
    isCalculating = false;
  }

  Future<void> _calculate(Vector2 start, Vector2 target) async {
    final revision = ++_calculationRevision;
    isCalculating = true;
    route = null;
    notifyListeners();
    try {
      // Keep A* off the UI isolate so the searching screen stays responsive.
      final path = await compute(_findPath, (_router, start, target));
      if (revision != _calculationRevision) return;
      isCalculating = false;
      progress = 0;
      if (path == null) {
        problem = 'No connected walking route here. Ask your adult to help choose another place.';
        notifyListeners();
        return;
      }
      route = WalkingRoute(map, path);
      // Apply the latest GPS fix; a calculation may finish after the child moved.
      _update();
    } catch (_) {
      if (revision != _calculationRevision) return;
      isCalculating = false;
      problem = 'Could not find a path. Ask your adult to try again.';
      notifyListeners();
    }
  }

  String get instruction {
    if (outsideMap) {
      return 'You are outside this offline map. Stay with your adult.';
    }
    if (!location.isPrecise) return location.message;
    if (problem != null) return problem!;
    if (destination == null) {
      return 'Choose a familiar place to walk to with your adult.';
    }
    if (nearPlace) {
      return 'You are near ${destination!.name}. Do you recognise the place?';
    }
    final current = route;
    if (current == null) return 'Finding a walking route…';
    if (joinDistance > 15) {
      return 'The mapped path is about ${metres(joinDistance)} away. Find it with your adult.';
    }
    if (current.length - progress <= 15) {
      return 'The mapped path ends here. Look for ${destination!.name} with your adult.';
    }
    return current.instructionAt(progress);
  }

  double get remaining => math.max(0, (route?.length ?? 0) - progress);

  @override
  void dispose() {
    _cancelCalculation();
    location.removeListener(_update);
    super.dispose();
  }
}

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

  List<num> _coordinate(Vector2 point) => [
    map.bounds[0] +
        (point.x - DemoMap.mapLeft) /
            DemoMap.mapSize *
            (map.bounds[2] - map.bounds[0]),
    map.bounds[3] -
        (point.y - DemoMap.mapTop) /
            DemoMap.mapSize *
            (map.bounds[3] - map.bounds[1]),
  ];

  double _distance(Vector2 a, Vector2 b) {
    final start = _coordinate(a);
    final end = _coordinate(b);
    return Geolocator.distanceBetween(
      start[1].toDouble(),
      start[0].toDouble(),
      end[1].toDouble(),
      end[0].toDouble(),
    );
  }

  double _bearing(Vector2 a, Vector2 b) {
    final start = _coordinate(a);
    final end = _coordinate(b);
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

RoutedPath? _findPath((OfflineRouter, Vector2, Vector2) request) =>
    request.$1.routeDetails(request.$2, request.$3);

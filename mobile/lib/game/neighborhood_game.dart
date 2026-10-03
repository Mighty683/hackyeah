import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../features/parent/data/family_plan.dart';
import 'components/neighborhood_component.dart';
import 'components/player_component.dart';
import 'components/practice_route_component.dart';
import 'components/target_indicator_component.dart';
import 'maps/demo_map.dart';
import 'maps/offline_router.dart';

/// Offline arena neighborhood with a touch-controlled demo mission.
class NeighborhoodGame extends FlameGame {
  NeighborhoodGame({
    required this.onArrived,
    this.destination,
    this.onRouteChanged,
    this.gender = ChildGender.girl,
  }) : super(
         camera: CameraComponent.withFixedResolution(
           width: DemoMap.mapSize,
           height: DemoMap.mapSize,
         ),
       );

  final ChildGender gender;

  final VoidCallback onArrived;
  final SafePoint? destination;
  final void Function(bool available, String? message)? onRouteChanged;
  late OfflineRouter _router;
  late final DemoMap _map;
  PracticeBlockage? _blockage;
  bool get hasPracticeBlockage => _blockage != null;
  bool get isCharacterMoving => _initialized && _player.isMoving;
  List<Vector2> _guide = [];
  List<Vector2> _tail = [];
  Vector2? _routeGoal;
  bool get hasRoute => _guide.isNotEmpty;
  static const nearbyZoom = 4.0;
  static const maximumZoom = 8.0;
  late final Vector2 _start;
  late final Vector2 _home;
  late final PlayerComponent _player;
  bool _completed = false;
  bool _initialized = false;
  bool _unavailable = false;
  bool _followPlayer = true;
  Vector2? _gestureWorldPoint;
  double _gestureZoom = 1;

  bool get isMapReady => isLoaded && _initialized && !_unavailable;
  double get mapZoom => camera.viewfinder.zoom;

  @override
  Color backgroundColor() => const Color(0xFFE9EFDC);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewfinder.anchor = Anchor.center;
    _showWholeMap();
    final map = await DemoMapRepository().load();
    _map = map;
    _router = OfflineRouter(map);
    final center = map.project(map.center);
    final startNode = _router.nearestNode(center);
    _start = startNode == null ? center : _router.pointAt(startNode);
    final target = destination;
    _home = map.project(
      target == null ? [20.0013, 50.0730] : [target.longitude, target.latitude],
    );
    _player = PlayerComponent(startPosition: _start.clone(), gender: gender);
    await world.add(
      NeighborhoodComponent(
        map: map,
        home: _home,
        homeLabel: destination?.displayName ?? 'Pretend base',
        // Flutter resolves taps versus pan/pinch before selecting a destination.
        onDestinationSelected: (_) {},
      ),
    );
    await world.add(
      PracticeRouteComponent(
        blockage: () => _blockage,
        points: () => _completed
            ? []
            : _player.isMoving
            ? [..._player.remainingPath, ..._tail.skip(1)]
            : _guide,
      ),
    );
    await world.add(_player);
    _refreshRoute();
    await camera.viewport.add(
      TargetIndicatorComponent(
        camera: camera,
        target: _routeGoal ?? _home,
        isActive: () =>
            _initialized && hasRoute && !_completed && !_unavailable,
      ),
    );
    _initialized = true;
    _showNearby();
  }

  /// [canvasPoint] is local to the GameWidget, not a geographic coordinate.
  void selectDestination(Offset canvasPoint) {
    if (!isMapReady || _completed) return;
    final point = camera.globalToLocal(Vector2(canvasPoint.dx, canvasPoint.dy));
    if (point.x < DemoMap.mapLeft ||
        point.x > DemoMap.mapLeft + DemoMap.mapSize ||
        point.y < DemoMap.mapTop ||
        point.y > DemoMap.mapTop + DemoMap.mapSize) {
      return;
    }
    if (_player.isMoving || _guide.isEmpty) return;
    var nearest = 0;
    var distance = double.infinity;
    for (var i = 0; i < _guide.length; i++) {
      final candidate = point.distanceTo(_guide[i]);
      if (candidate < distance) {
        distance = candidate;
        nearest = i;
      }
    }
    if (distance > 16 / mapZoom) {
      onRouteChanged?.call(hasRoute, 'Tap the marked path to move.');
      return;
    }
    _followPlayer = true;
    _tail = _guide.sublist(nearest);
    _player.followPath(_guide.sublist(0, nearest + 1));
    onRouteChanged?.call(hasRoute, null);
  }

  void beginMapGesture(Offset focalPoint) {
    endMapGesture();
    if (!isMapReady) return;
    _followPlayer = false;
    _gestureZoom = mapZoom;
    _gestureWorldPoint = camera.globalToLocal(
      Vector2(focalPoint.dx, focalPoint.dy),
    );
  }

  void updateMapGesture(Offset focalPoint, double scale) {
    final worldPoint = _gestureWorldPoint;
    if (!isMapReady || worldPoint == null) return;
    camera.viewfinder.zoom = (_gestureZoom * scale).clamp(1.0, maximumZoom);
    // Keep the starting world point under the moving focal point. Flame's
    // inverse includes the fixed viewport scale, its offset, and camera zoom.
    final currentPoint = camera.globalToLocal(
      Vector2(focalPoint.dx, focalPoint.dy),
    );
    camera.viewfinder.position =
        camera.viewfinder.position + worldPoint - currentPoint;
    _clampCamera();
  }

  void endMapGesture() => _gestureWorldPoint = null;

  void zoomMap(double factor) {
    if (!isMapReady) return;
    endMapGesture();
    camera.viewfinder.zoom = (mapZoom * factor).clamp(1.0, maximumZoom);
    _clampCamera();
  }

  /// Restore the close practice view after browsing another part of the map.
  void showNearby() {
    if (!isMapReady) return;
    _showNearby();
  }

  void _showNearby() {
    endMapGesture();
    _followPlayer = true;
    camera.viewfinder.zoom = nearbyZoom;
    camera.viewfinder.position = _player.position.clone();
    _clampCamera();
  }

  void showWholeMap() {
    if (!isMapReady) return;
    _followPlayer = false;
    _showWholeMap();
  }

  void _showWholeMap() {
    endMapGesture();
    camera.viewfinder.zoom = 1;
    camera.viewfinder.position = Vector2(
      DemoMap.mapLeft + DemoMap.mapSize / 2,
      DemoMap.mapTop + DemoMap.mapSize / 2,
    );
    camera.viewfinder.angle = 0;
  }

  void _clampCamera() {
    final halfView = DemoMap.mapSize / (2 * mapZoom);
    final position = camera.viewfinder.position;
    camera.viewfinder.position = Vector2(
      position.x.clamp(
        DemoMap.mapLeft + halfView,
        DemoMap.mapLeft + DemoMap.mapSize - halfView,
      ),
      position.y.clamp(
        DemoMap.mapTop + halfView,
        DemoMap.mapTop + DemoMap.mapSize - halfView,
      ),
    );
    camera.viewfinder.angle = 0;
  }

  void markMapUnavailable() {
    _unavailable = true;
    endMapGesture();
  }

  void _refreshRoute() {
    _guide = _router.route(_player.position, _home) ?? [];
    _tail = [];
    _routeGoal = _guide.isEmpty ? null : _guide.last.clone();
    onRouteChanged?.call(
      hasRoute,
      hasRoute
          ? _blockage == null
                ? null
                : 'A path is blocked. Follow the new route.'
          : _blockage == null
          ? 'No practice path here. Try another place.'
          : 'No path around this blockage. Clear it or start again.',
    );
  }

  /// Toggle a fictional blockage while stationary; no live hazard is inferred.
  void togglePracticeBlockage() {
    if (!isMapReady || _completed || isCharacterMoving) return;
    if (_blockage != null) {
      _blockage = null;
    } else {
      if (_guide.length < 3) return;
      _blockage = PracticeBlockage(
        center: _guide[_guide.length ~/ 2],
        radius: 4,
      );
    }
    _router = OfflineRouter(_map, blockage: _blockage);
    _refreshRoute();
    showWholeMap();
  }

  /// Move only the game character, after an explicit child action.
  void followPracticePath() {
    if (!isMapReady || _completed || _player.isMoving || !hasRoute) return;
    _followPlayer = true;
    _tail = [];
    _player.followPath(_guide);
    onRouteChanged?.call(true, null);
  }

  @override
  void update(double dt) {
    final wasMoving = _initialized && _player.isMoving;
    super.update(dt);
    if (!isMapReady) return;
    if (_followPlayer) {
      camera.viewfinder.position = _player.position.clone();
      _clampCamera();
    }
    if (_completed) return;
    if (wasMoving && !_player.isMoving) _refreshRoute();
    final goal = _routeGoal;
    if (goal != null &&
        !_player.isMoving &&
        _player.position.distanceTo(goal) < .01) {
      _completed = true;
      onArrived();
    }
  }

  void restart() {
    if (!isMapReady) return;
    _completed = false;
    _player.reset(_start);
    _blockage = null;
    _router = OfflineRouter(_map);
    _refreshRoute();
    showNearby();
  }
}

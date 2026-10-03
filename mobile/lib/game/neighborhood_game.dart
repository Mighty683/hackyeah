import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'components/neighborhood_component.dart';
import 'components/player_component.dart';
import 'maps/demo_map.dart';

/// Offline arena neighborhood with a touch-controlled demo mission.
class NeighborhoodGame extends FlameGame {
  NeighborhoodGame({required this.onArrived})
    : super(
        camera: CameraComponent.withFixedResolution(
          width: DemoMap.mapSize,
          height: DemoMap.mapSize,
        ),
      );

  final VoidCallback onArrived;
  late final Vector2 _start;
  late final Vector2 _home;
  late final PlayerComponent _player;
  bool _completed = false;
  bool _initialized = false;
  bool _unavailable = false;
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
    _start = map.project(map.center);
    // Fictional home inside the real map, used only as a demo destination.
    _home = map.project([20.0013, 50.0730]);
    _player = PlayerComponent(startPosition: _start.clone());
    await world.add(
      NeighborhoodComponent(
        map: map,
        home: _home,
        // Flutter resolves taps versus pan/pinch before selecting a destination.
        onDestinationSelected: (_) {},
      ),
    );
    await world.add(_player);
    _initialized = true;
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
    _movePlayer(point);
  }

  void beginMapGesture(Offset focalPoint) {
    endMapGesture();
    if (!isMapReady) return;
    _gestureZoom = mapZoom;
    _gestureWorldPoint = camera.globalToLocal(
      Vector2(focalPoint.dx, focalPoint.dy),
    );
  }

  void updateMapGesture(Offset focalPoint, double scale) {
    final worldPoint = _gestureWorldPoint;
    if (!isMapReady || worldPoint == null) return;
    camera.viewfinder.zoom = (_gestureZoom * scale).clamp(1.0, 4.0);
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
    camera.viewfinder.zoom = (mapZoom * factor).clamp(1.0, 4.0);
    _clampCamera();
  }

  void showWholeMap() {
    if (!isMapReady) return;
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

  void _movePlayer(Vector2 point) {
    if (!isMapReady || _completed) return;
    _player.moveTo(
      Vector2(
        point.x
            .clamp(DemoMap.mapLeft + 17, DemoMap.mapLeft + DemoMap.mapSize - 17)
            .toDouble(),
        point.y
            .clamp(DemoMap.mapTop + 17, DemoMap.mapTop + DemoMap.mapSize - 17)
            .toDouble(),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isMapReady || _completed) return;
    if (_player.position.distanceTo(_home) < 32) {
      _completed = true;
      onArrived();
    }
  }

  void restart() {
    if (!isMapReady) return;
    _completed = false;
    _player.reset(_start);
    _showWholeMap();
  }
}

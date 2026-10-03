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
        camera: CameraComponent.withFixedResolution(width: 560, height: 420),
      );

  final VoidCallback onArrived;
  late final Vector2 _start;
  late final Vector2 _home;
  late final PlayerComponent _player;
  bool _completed = false;

  @override
  Color backgroundColor() => const Color(0xFFE9EFDC);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewfinder.anchor = Anchor.topLeft;
    final map = await DemoMapRepository().load();
    _start = map.project(map.center);
    // Fictional home inside the real map, used only as a demo destination.
    _home = map.project([20.0013, 50.0730]);
    _player = PlayerComponent(startPosition: _start.clone());
    await world.add(
      NeighborhoodComponent(
        map: map,
        home: _home,
        onDestinationSelected: _movePlayer,
      ),
    );
    await world.add(_player);
  }

  void _movePlayer(Vector2 point) {
    if (_completed) return;
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
    if (!isLoaded || _completed) return;
    if (_player.position.distanceTo(_home) < 32) {
      _completed = true;
      onArrived();
    }
  }

  void restart() {
    if (!isLoaded) return;
    _completed = false;
    _player.reset(_start);
  }
}

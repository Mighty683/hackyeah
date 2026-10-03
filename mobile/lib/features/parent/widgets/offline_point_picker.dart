/// Parent-only geographic pin selection on the same bundled OSM map as the game.
library;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../../game/maps/demo_map.dart';
import '../../../ui/basebound_icons.dart';
import '../../../ui/basebound_ui.dart';
import '../data/family_plan.dart';
import 'offline_map_component.dart';

class OfflinePointPicker extends StatefulWidget {
  const OfflinePointPicker({
    required this.otherPoints,
    required this.onSelected,
    this.initialPoint,
    this.selectionLabel = 'safe place',
    super.key,
  });

  final List<SafePoint> otherPoints;
  final SafePoint? initialPoint;
  final String selectionLabel;
  final ValueChanged<SafePoint> onSelected;

  @override
  State<OfflinePointPicker> createState() => _OfflinePointPickerState();
}

class _OfflinePointPickerState extends State<OfflinePointPicker> {
  late final _game = _PointPickerGame(
    initialPoint: widget.initialPoint,
    otherPoints: widget.otherPoints,
    onSelected: widget.onSelected,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          label:
              'Offline Kraków map. Tap to choose a ${widget.selectionLabel}. '
              'Alternatively, use the direction buttons below.',
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: BaseboundColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: GameWidget<_PointPickerGame>(
                  game: _game,
                  loadingBuilder: (_) =>
                      const Center(child: CircularProgressIndicator()),
                  errorBuilder: (_, _) => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Map could not load. Go back and try again.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Map data © OpenStreetMap contributors · ODbL 1.0',
          style: TextStyle(fontSize: 12, color: BaseboundColors.muted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BaseboundColors.border),
          ),
          child: Column(
            children: [
              TextButton(
                onPressed: _game.selectCenter,
                child: const Text('Use arena centre'),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  _directionButton(
                    icon: BaseboundIconName.up,
                    tooltip: 'Move pin north',
                    dx: 0,
                    dy: -12,
                  ),
                  _directionButton(
                    icon: BaseboundIconName.down,
                    tooltip: 'Move pin south',
                    dx: 0,
                    dy: 12,
                  ),
                  _directionButton(
                    icon: BaseboundIconName.back,
                    tooltip: 'Move pin west',
                    dx: -12,
                    dy: 0,
                  ),
                  _directionButton(
                    icon: BaseboundIconName.next,
                    tooltip: 'Move pin east',
                    dx: 12,
                    dy: 0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _directionButton({
    required BaseboundIconName icon,
    required String tooltip,
    required double dx,
    required double dy,
  }) => IconButton(
    onPressed: () => _game.nudge(dx, dy),
    icon: BaseboundIcon(icon, size: 24, color: BaseboundColors.muted),
    tooltip: tooltip,
  );
}

class _PointPickerGame extends FlameGame {
  _PointPickerGame({
    required this.initialPoint,
    required this.otherPoints,
    required this.onSelected,
  }) : super(
         camera: CameraComponent.withFixedResolution(
           width: DemoMap.mapSize,
           height: DemoMap.mapSize,
         ),
       );

  final SafePoint? initialPoint;
  final List<SafePoint> otherPoints;
  final ValueChanged<SafePoint> onSelected;
  late final DemoMap _map;
  CircleComponent? _marker;
  bool _ready = false;

  @override
  Color backgroundColor() => const Color(0xFFE9EFDC);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2(DemoMap.mapLeft, DemoMap.mapTop);
    _map = await DemoMapRepository().load();
    await world.add(OfflineMapComponent(map: _map, onPointSelected: _select));
    for (var index = 0; index < otherPoints.length; index++) {
      final point = otherPoints[index];
      final position = _map.project([point.longitude, point.latitude]);
      await world.add(
        CircleComponent(
          radius: 7,
          anchor: Anchor.center,
          position: position,
          paint: Paint()..color = const Color(0xFF777777),
        ),
      );
      await world.add(
        TextComponent(
          text: '${index + 1}',
          position: position + Vector2(0, -16),
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(color: Color(0xFF333333)),
          ),
        ),
      );
    }
    _ready = true;
    final initial = initialPoint;
    if (initial != null) {
      _select(_map.project([initial.longitude, initial.latitude]));
    }
  }

  void selectCenter() {
    if (_ready) _select(_map.project(_map.center));
  }

  void nudge(double dx, double dy) {
    if (!_ready) return;
    final position = _marker?.position ?? _map.project(_map.center);
    _select(position + Vector2(dx, dy));
  }

  void _select(Vector2 position) {
    if (!_ready) return;
    final point = Vector2(
      position.x
          .clamp(DemoMap.mapLeft, DemoMap.mapLeft + DemoMap.mapSize)
          .toDouble(),
      position.y
          .clamp(DemoMap.mapTop, DemoMap.mapTop + DemoMap.mapSize)
          .toDouble(),
    );
    final marker = _marker;
    if (marker == null) {
      _marker = CircleComponent(
        radius: 10,
        anchor: Anchor.center,
        position: point,
        paint: Paint()..color = const Color(0xFF8C3152),
      );
      world.add(_marker!);
    } else {
      marker.position = point;
    }
    final longitude =
        _map.bounds[0] +
        (point.x - DemoMap.mapLeft) /
            DemoMap.mapSize *
            (_map.bounds[2] - _map.bounds[0]);
    final latitude =
        _map.bounds[3] -
        (point.y - DemoMap.mapTop) /
            DemoMap.mapSize *
            (_map.bounds[3] - _map.bounds[1]);
    onSelected(SafePoint(name: '', latitude: latitude, longitude: longitude));
  }
}

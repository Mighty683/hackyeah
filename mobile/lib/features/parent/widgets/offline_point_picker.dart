/// Parent-only geographic pin selection on the same bundled OSM map as the game.
library;

import 'dart:async';

import '../../../platform/photo_access.dart';

import 'dart:ui' as ui;

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
    this.selectionLabel = 'bezpieczne miejsce',
    this.selectionIcon = '📍',
    this.selectionPhotoPath,
    super.key,
  });

  final List<SafePoint> otherPoints;
  final SafePoint? initialPoint;
  final String selectionLabel;
  final String selectionIcon;
  final String? selectionPhotoPath;
  final ValueChanged<SafePoint> onSelected;

  @override
  State<OfflinePointPicker> createState() => _OfflinePointPickerState();
}

class _OfflinePointPickerState extends State<OfflinePointPicker> {
  late final _game = _PointPickerGame(
    initialPoint: widget.initialPoint,
    selectionIcon: widget.selectionIcon,
    selectionPhotoPath: widget.selectionPhotoPath,
    otherPoints: widget.otherPoints,
    onSelected: widget.onSelected,
  );

  @override
  void didUpdateWidget(covariant OfflinePointPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _game.updateSelectionIcon(widget.selectionIcon);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          label:
              'Mapa Krakowa offline. Dotknij, aby wybrać: ${widget.selectionLabel}. '
              'Możesz też użyć przycisków kierunku poniżej.',
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
                        'Nie udało się wczytać mapy. Wróć i spróbuj ponownie.',
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
          'Dane mapy © autorzy OpenStreetMap · ODbL 1.0',
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
                child: const Text('Użyj środka areny'),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  _directionButton(
                    icon: BaseboundIconName.up,
                    tooltip: 'Przesuń znacznik na północ',
                    dx: 0,
                    dy: -12,
                  ),
                  _directionButton(
                    icon: BaseboundIconName.down,
                    tooltip: 'Przesuń znacznik na południe',
                    dx: 0,
                    dy: 12,
                  ),
                  _directionButton(
                    icon: BaseboundIconName.back,
                    tooltip: 'Przesuń znacznik na zachód',
                    dx: -12,
                    dy: 0,
                  ),
                  _directionButton(
                    icon: BaseboundIconName.next,
                    tooltip: 'Przesuń znacznik na wschód',
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
    icon: BaseboundIcon(icon, size: 24),
    tooltip: tooltip,
  );
}

class _PointPickerGame extends FlameGame {
  _PointPickerGame({
    required this.initialPoint,
    required this.selectionIcon,
    required this.selectionPhotoPath,
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
  String selectionIcon;
  final String? selectionPhotoPath;
  PositionComponent? _marker;
  Sprite? _photo;
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
    for (final point in otherPoints) {
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
          text: point.icon,
          position: position + Vector2(0, -16),
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(fontSize: 20, color: Color(0xFF333333)),
          ),
        ),
      );
    }
    _ready = true;
    final initial = initialPoint;
    if (initial != null) {
      _select(_map.project([initial.longitude, initial.latitude]));
    }
    if (selectionPhotoPath != null) unawaited(_loadSelectionPhoto());
  }

  // Photo decoding must not delay map placement or the accessible controls.
  Future<void> _loadSelectionPhoto() async {
    try {
      final codec = await ui.instantiateImageCodec(
        await readPhotoBytes(selectionPhotoPath!),
        targetWidth: 120,
      );
      try {
        _photo = Sprite((await codec.getNextFrame()).image);
      } finally {
        codec.dispose();
      }
      final marker = _marker;
      if (marker != null) {
        marker.removeFromParent();
        _marker = _createMarker(marker.position.clone());
        await world.add(_marker!);
      }
    } catch (_) {
      // The form reports unavailable photos; keep manual pin placement usable.
    }
  }

  PositionComponent _createMarker(Vector2 position) {
    if (_photo != null) {
      return SpriteComponent(
        sprite: _photo,
        size: Vector2.all(48),
        anchor: Anchor.center,
        position: position,
      );
    }
    if (selectionPhotoPath != null) {
      return CircleComponent(
        radius: 8,
        anchor: Anchor.center,
        position: position,
        paint: Paint()..color = BaseboundColors.blue,
      );
    }
    return TextComponent(
      text: selectionIcon,
      anchor: Anchor.center,
      position: position,
      textRenderer: TextPaint(style: const TextStyle(fontSize: 24)),
    );
  }

  void updateSelectionIcon(String icon) {
    selectionIcon = icon;
    final marker = _marker;
    if (marker is TextComponent) marker.text = icon;
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
      _marker = _createMarker(point);
      world.add(_marker!);
    } else {
      marker.position = point;
    }
    final coordinates = _map.unproject(point);
    onSelected(
      SafePoint(
        name: '',
        latitude: coordinates[1].toDouble(),
        longitude: coordinates[0].toDouble(),
      ),
    );
  }
}

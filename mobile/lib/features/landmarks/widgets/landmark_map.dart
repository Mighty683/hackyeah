import 'dart:io';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../../game/components/neighborhood_component.dart';
import '../../../game/maps/demo_map.dart';
import '../../../ui/basebound_ui.dart';
import '../data/landmark.dart';

/// Photo markers over the game's existing geography. No route or movement.
class LandmarkMap extends StatefulWidget {
  const LandmarkMap({
    required this.landmarks,
    required this.photoDirectory,
    required this.onSelected,
    this.selectedId,
    this.hidePhotos = false,
    super.key,
  });

  final List<Landmark> landmarks;
  final String photoDirectory;
  final ValueChanged<Landmark> onSelected;
  final String? selectedId;
  final bool hidePhotos;

  @override
  State<LandmarkMap> createState() => _LandmarkMapState();
}

class _LandmarkMapState extends State<LandmarkMap> {
  late Future<DemoMap> _map = DemoMapRepository().load();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: FutureBuilder<DemoMap>(
            future: _map,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: TextButton(
                    onPressed: () =>
                        setState(() => _map = DemoMapRepository().load()),
                    child: const Text('Retry loading map'),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return _LandmarkMapCanvas(map: snapshot.data!, widget: widget);
            },
          ),
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Map data © OpenStreetMap contributors · ODbL 1.0',
        style: TextStyle(fontSize: 12, color: BaseboundColors.muted),
      ),
    ],
  );
}

class _LandmarkMapCanvas extends StatefulWidget {
  const _LandmarkMapCanvas({required this.map, required this.widget});
  final DemoMap map;
  final LandmarkMap widget;

  @override
  State<_LandmarkMapCanvas> createState() => _LandmarkMapCanvasState();
}

class _LandmarkMapCanvasState extends State<_LandmarkMapCanvas> {
  late final _game = _LandmarkMapGame(widget.map);

  @override
  Widget build(BuildContext context) => InteractiveViewer(
    maxScale: 4,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.maxWidth;
        final config = widget.widget;
        return Stack(
          children: [
            Positioned.fill(
              child: ExcludeSemantics(
                child: GameWidget(
                  game: _game,
                  errorBuilder: (_, _) =>
                      const Center(child: Text('Map unavailable')),
                ),
              ),
            ),
            for (var index = 0; index < config.landmarks.length; index++)
              _pin(config.landmarks[index], index, side, config),
          ],
        );
      },
    ),
  );

  Widget _pin(Landmark landmark, int index, double side, LandmarkMap config) {
    final position = widget.map.project([
      landmark.longitude,
      landmark.latitude,
    ]);
    final x = (position.x - DemoMap.mapLeft) / DemoMap.mapSize * side;
    final y = (position.y - DemoMap.mapTop) / DemoMap.mapSize * side;
    final selected = landmark.id == config.selectedId;
    return Positioned(
      left: (x - 24).clamp(0, side - 48),
      top: (y - 24).clamp(0, side - 56),
      width: 48,
      height: 56,
      child: Semantics(
        button: true,
        selected: selected,
        label: config.hidePhotos ? 'Pin ${index + 1}' : landmark.name,
        child: Tooltip(
          message: config.hidePhotos ? 'Pin ${index + 1}' : landmark.name,
          child: Material(
            color: selected ? BaseboundColors.green : BaseboundColors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.white, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => config.onSelected(landmark),
              child: ExcludeSemantics(
                child: Column(
                  children: [
                    if (!config.hidePhotos)
                      Expanded(
                        child: Image.file(
                          File(
                            '${config.photoDirectory}/${landmark.photoName}',
                          ),
                          width: 48,
                          fit: BoxFit.cover,
                          cacheWidth: 120,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.photo_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LandmarkMapGame extends FlameGame {
  _LandmarkMapGame(this.map)
    : super(
        camera: CameraComponent.withFixedResolution(
          width: DemoMap.mapSize,
          height: DemoMap.mapSize,
        ),
      );
  final DemoMap map;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2(DemoMap.mapLeft, DemoMap.mapTop);
    await world.add(
      NeighborhoodComponent(
        map: map,
        home: map.project(map.center),
        showHome: false,
        onDestinationSelected: (_) {},
      ),
    );
  }
}

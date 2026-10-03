import 'dart:io';

import 'package:flame/components.dart' hide Matrix4;
import 'package:flame/game.dart' hide Matrix4;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../game/components/neighborhood_component.dart';
import '../../../game/maps/demo_map.dart';
import '../../../ui/basebound_ui.dart';
import '../data/landmark.dart';

/// Shared parent/child geography. Pins open details; only GPS sets the live dot.
class LandmarkMap extends StatefulWidget {
  const LandmarkMap({
    required this.landmarks,
    required this.photoDirectory,
    required this.onSelected,
    this.selectedId,
    this.map,
    this.position,
    this.route = const [],
    this.showAttribution = true,
    super.key,
  });

  final List<Landmark> landmarks;
  final String photoDirectory;
  final ValueChanged<Landmark> onSelected;
  final String? selectedId;
  final DemoMap? map;
  final Position? position;
  final List<Vector2> route;
  final bool showAttribution;

  @override
  State<LandmarkMap> createState() => _LandmarkMapState();
}

class _LandmarkMapState extends State<LandmarkMap> {
  late Future<DemoMap> _map = widget.map == null
      ? DemoMapRepository().load()
      : Future.value(widget.map);

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
              return _LandmarkMapCanvas(map: snapshot.data!, config: widget);
            },
          ),
        ),
      ),
      if (widget.showAttribution) ...[
        const SizedBox(height: 8),
        const Text(
          'Map data © OpenStreetMap contributors · ODbL 1.0',
          style: TextStyle(fontSize: 12, color: BaseboundColors.muted),
        ),
      ],
    ],
  );
}

class _LandmarkMapCanvas extends StatefulWidget {
  const _LandmarkMapCanvas({required this.map, required this.config});
  final DemoMap map;
  final LandmarkMap config;
  @override
  State<_LandmarkMapCanvas> createState() => _LandmarkMapCanvasState();
}

class _LandmarkMapCanvasState extends State<_LandmarkMapCanvas> {
  late final _game = _LandmarkMapGame(widget.map);
  final _transform = TransformationController();
  double _side = 0;
  double get _zoom => _transform.value.getMaxScaleOnAxis();

  @override
  void initState() {
    super.initState();
    _transform.addListener(_redraw);
  }

  void _redraw() {
    if (mounted) setState(() {});
  }

  Offset _project(Vector2 point) => Offset(
    (point.x - DemoMap.mapLeft) / DemoMap.mapSize * _side,
    (point.y - DemoMap.mapTop) / DemoMap.mapSize * _side,
  );

  @override
  void dispose() {
    _transform.removeListener(_redraw);
    _transform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      _side = constraints.maxWidth;
      final config = widget.config;
      return InteractiveViewer(
        transformationController: _transform,
        maxScale: 8,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: GameWidget(
                    game: _game,
                    errorBuilder: (_, _) =>
                        const Center(child: Text('Map unavailable')),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _NavigationPainter(
                    map: widget.map,
                    position: null,
                    route: config.route,
                    zoom: _zoom,
                  ),
                ),
              ),
            ),
            for (final landmark in config.landmarks) _pin(landmark),
            if (config.position != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: Semantics(
                    label: 'Your live GPS position',
                    child: CustomPaint(
                      key: const ValueKey('live-gps-marker'),
                      painter: _NavigationPainter(
                        map: widget.map,
                        position: config.position,
                        route: const [],
                        zoom: _zoom,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );

  Widget _pin(Landmark landmark) {
    final config = widget.config;
    final position = _project(
      widget.map.project([landmark.longitude, landmark.latitude]),
    );
    final selected = landmark.id == config.selectedId;
    final width = 48 / _zoom;
    final height = 56 / _zoom;
    return Positioned(
      left: position.dx - width / 2,
      top: position.dy - height / 2,
      width: width,
      height: height,
      child: FittedBox(
        child: SizedBox(
          width: 48,
          height: 56,
          child: Semantics(
            button: true,
            selected: selected,
            label: landmark.name,
            child: Tooltip(
              message: landmark.name,
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
                        if (landmark.photoName.isNotEmpty)
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
                              landmark.icon,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 24,
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
        ),
      ),
    );
  }
}

class _NavigationPainter extends CustomPainter {
  _NavigationPainter({
    required this.map,
    required this.position,
    required this.route,
    required this.zoom,
  });
  final DemoMap map;
  final Position? position;
  final List<Vector2> route;
  final double zoom;
  @override
  void paint(Canvas canvas, Size size) {
    Offset project(Vector2 point) => Offset(
      (point.x - DemoMap.mapLeft) / DemoMap.mapSize * size.width,
      (point.y - DemoMap.mapTop) / DemoMap.mapSize * size.height,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (route.isNotEmpty) {
      final first = project(route.first);
      final path = Path()..moveTo(first.dx, first.dy);
      for (final point in route.skip(1)) {
        final offset = project(point);
        path.lineTo(offset.dx, offset.dy);
      }
      canvas.drawPath(
        path,
        paint
          ..color = Colors.white
          ..strokeWidth = 7 / zoom,
      );
      canvas.drawPath(
        path,
        paint
          ..color = BaseboundColors.blue
          ..strokeWidth = 4 / zoom,
      );
      canvas.drawCircle(
        project(route.last),
        8 / zoom,
        paint..strokeWidth = 3 / zoom,
      );
    }
    final fix = position;
    if (fix == null) return;
    final dot = project(map.project([fix.longitude, fix.latitude]));
    final radius = fix.accuracy / 2000 * size.width;
    canvas.drawCircle(
      dot,
      radius,
      paint
        ..style = PaintingStyle.fill
        ..color = BaseboundColors.blue.withValues(alpha: .14),
    );
    canvas.drawCircle(
      dot,
      radius,
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 / zoom
        ..color = BaseboundColors.blue.withValues(alpha: .5),
    );
    canvas.drawCircle(
      dot,
      10 / zoom,
      paint
        ..style = PaintingStyle.fill
        ..color = Colors.white,
    );
    canvas.drawCircle(dot, 7 / zoom, paint..color = BaseboundColors.blue);
  }

  @override
  bool shouldRepaint(covariant _NavigationPainter old) =>
      old.position != position || old.route != route || old.zoom != zoom;
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

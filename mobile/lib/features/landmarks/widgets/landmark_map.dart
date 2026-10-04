import 'package:flame/components.dart' hide Matrix4;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../../game/components/neighborhood_component.dart';
import '../../../game/maps/demo_map.dart';
import '../../../ui/basebound_ui.dart';
import '../data/landmark.dart';
import 'landmark_pin.dart';
import 'navigation_painter.dart';

/// Shared geography. GPS sets the Android dot; web uses a fictional position.
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
                    child: const Text('Wczytaj mapę ponownie'),
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
          'Dane mapy © autorzy OpenStreetMap · ODbL 1.0',
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
  late final _neighborhood = NeighborhoodComponent(map: widget.map);
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
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _NeighborhoodPainter(_neighborhood),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: NavigationPainter(
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
                    label: kIsWeb
                        ? 'Fikcyjna pozycja demo · bez GPS'
                        : 'Twoja bieżąca pozycja GPS',
                    child: CustomPaint(
                      key: const ValueKey('live-gps-marker'),
                      painter: NavigationPainter(
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
      child: LandmarkPin(
        landmark: landmark,
        photoDirectory: config.photoDirectory,
        selected: selected,
        onSelected: config.onSelected,
      ),
    );
  }
}

/// The geography is static. Painting on demand avoids running a game loop
/// while browsing places, showing a photo, or leaving this route underneath help.
class _NeighborhoodPainter extends CustomPainter {
  const _NeighborhoodPainter(this.neighborhood);

  final NeighborhoodComponent neighborhood;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / DemoMap.mapSize);
    canvas.translate(-DemoMap.mapLeft, -DemoMap.mapTop);
    neighborhood.render(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _NeighborhoodPainter oldDelegate) =>
      neighborhood != oldDelegate.neighborhood;
}

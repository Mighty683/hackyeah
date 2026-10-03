import 'dart:io';
import 'dart:math' as math;

import 'package:flame/components.dart' hide Matrix4;
import 'package:flame/game.dart' hide Matrix4;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../game/components/neighborhood_component.dart';
import '../../../game/maps/demo_map.dart';
import '../../../ui/basebound_ui.dart';
import '../data/landmark.dart';

class LandmarkMapController extends ChangeNotifier {
  String action = '';
  double factor = 1;
  void zoom(double value) {
    factor = value;
    action = 'zoom';
    notifyListeners();
  }

  void showMe() {
    action = 'me';
    notifyListeners();
  }

  void showWholeMap() {
    action = 'whole';
    notifyListeners();
  }
}

/// Shared parent/child geography. Pins open details; only GPS sets the live dot.
class LandmarkMap extends StatefulWidget {
  const LandmarkMap({
    required this.landmarks,
    required this.photoDirectory,
    required this.onSelected,
    this.selectedId,
    this.hidePhotos = false,
    this.map,
    this.position,
    this.route = const [],
    this.controller,
    this.showAttribution = true,
    super.key,
  });

  final List<Landmark> landmarks;
  final String photoDirectory;
  final ValueChanged<Landmark> onSelected;
  final String? selectedId;
  final bool hidePhotos;
  final DemoMap? map;
  final Position? position;
  final List<Vector2> route;
  final LandmarkMapController? controller;
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
  bool _follow = true;
  double _side = 0;
  double get _zoom => _transform.value.getMaxScaleOnAxis();

  @override
  void initState() {
    super.initState();
    widget.config.controller?.addListener(_command);
    _transform.addListener(_redraw);
  }

  @override
  void didUpdateWidget(covariant _LandmarkMapCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.controller != widget.config.controller) {
      oldWidget.config.controller?.removeListener(_command);
      widget.config.controller?.addListener(_command);
    }
    if (_follow && oldWidget.config.position != widget.config.position) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _centreOnPosition();
      });
    }
  }

  void _redraw() {
    if (mounted) setState(() {});
  }

  void _command() {
    final controller = widget.config.controller!;
    switch (controller.action) {
      case 'whole':
        _follow = false;
        _transform.value = Matrix4.identity();
      case 'me':
        _follow = true;
        _centreOnPosition();
      case 'zoom':
        _follow = false;
        final centre = _transform.toScene(Offset(_side / 2, _side / 2));
        _focus(centre, (_zoom * controller.factor).clamp(1, 8));
    }
  }

  Offset _project(Vector2 point) => Offset(
    (point.x - DemoMap.mapLeft) / DemoMap.mapSize * _side,
    (point.y - DemoMap.mapTop) / DemoMap.mapSize * _side,
  );

  void _centreOnPosition() {
    final position = widget.config.position;
    if (position == null || _side == 0) return;
    _focus(
      _project(widget.map.project([position.longitude, position.latitude])),
      math.max(4, _zoom),
    );
  }

  void _focus(Offset centre, double zoom) {
    if (_side == 0) return;
    final minimum = _side * (1 - zoom);
    final x = (_side / 2 - centre.dx * zoom).clamp(minimum, 0.0);
    final y = (_side / 2 - centre.dy * zoom).clamp(minimum, 0.0);
    _transform.value = Matrix4.identity()
      ..translateByDouble(x, y, 0, 1)
      ..scaleByDouble(zoom, zoom, 1, 1);
  }

  @override
  void dispose() {
    widget.config.controller?.removeListener(_command);
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
        onInteractionStart: (_) => _follow = false,
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
            for (var index = 0; index < config.landmarks.length; index++)
              _pin(config.landmarks[index], index),
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

  Widget _pin(Landmark landmark, int index) {
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
                            child: landmark.photoName.isEmpty
                                ? const Icon(
                                    Icons.place_outlined,
                                    color: Colors.white,
                                  )
                                : Image.file(
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

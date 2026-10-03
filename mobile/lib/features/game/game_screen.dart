import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../game/neighborhood_game.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final NeighborhoodGame _game;
  bool _arrived = false;
  bool _ready = false;
  bool _failed = false;
  bool _tapBlocked = false;
  final Map<int, Offset> _pointerStarts = {};

  @override
  void initState() {
    super.initState();
    _game = NeighborhoodGame(
      onArrived: () {
        if (mounted) setState(() => _arrived = true);
      },
    );
    _game.loaded.then((_) {
      if (mounted) setState(() => _ready = _game.isMapReady);
    });
  }

  void _restart() {
    if (!_game.isMapReady) return;
    _tapBlocked = true;
    _game.restart();
    setState(() => _arrived = false);
  }

  void _showDemoInfo() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About this demo'),
        scrollable: true,
        content: const Text(
          'This is a practice game, not real-world navigation. '
          'The base is pretend. Your character can move freely.\n\n'
          'This simplified map leaves out small streets and buildings. '
          'Trees and buildings are illustrations, not exact outlines.\n\n'
          'The source map covers 2 × 2 km around TAURON Arena in Kraków. '
          'Zooming shows a smaller part. Show whole map restores all of it.\n\n'
          'Map data © OpenStreetMap contributors · ODbL 1.0.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Practice game',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (!_arrived)
            IconButton(
              onPressed: _ready ? _restart : null,
              icon: const Icon(Icons.replay),
              tooltip: 'Start again',
            ),
          IconButton(
            onPressed: _showDemoInfo,
            icon: const Icon(Icons.info_outline),
            tooltip: 'About this demo',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) => _buildContent(constraints),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BoxConstraints constraints) {
    final landscape = constraints.maxWidth > constraints.maxHeight * 1.25;
    final compact =
        landscape ||
        constraints.maxHeight < 460 ||
        MediaQuery.textScalerOf(context).scale(18) > 24;
    final controls = SingleChildScrollView(child: _buildControls());
    final content = landscape
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildFittedMap()),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInstructions(compact: true),
                    const SizedBox(height: 8),
                    Expanded(child: controls),
                  ],
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInstructions(compact: compact),
              const SizedBox(height: 8),
              Expanded(child: _buildFittedMap()),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * .32,
                ),
                child: controls,
              ),
            ],
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: content),
        const SizedBox(height: 6),
        const Text(
          '© OpenStreetMap contributors · ODbL',
          style: TextStyle(fontSize: 12, color: Color(0xFF465448)),
        ),
      ],
    );
  }

  Widget _buildInstructions({required bool compact}) {
    final title = _failed
        ? compact
              ? 'Go back and try again.'
              : 'The map could not load'
        : _arrived
        ? 'You reached the base!'
        : compact
        ? 'Tap the pretend base.'
        : 'Reach the pretend base';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          header: true,
          child: Text(
            title,
            style: TextStyle(
              fontSize: compact ? 18 : 26,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: 4),
          Text(
            _failed
                ? 'Go back and try again.'
                : _arrived
                ? 'You guided your character to the base.'
                : 'Tap to move. Drag or pinch to explore.',
            style: const TextStyle(fontSize: 18),
          ),
        ],
        const SizedBox(height: 4),
        Text(
          compact ? 'Practice only.' : 'Practice only. Not real navigation.',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFittedMap() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        return Center(
          child: SizedBox(width: side, height: side, child: _buildMap()),
        );
      },
    );
  }

  Widget _buildControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_arrived) ...[
          FilledButton.icon(
            onPressed: _ready ? _restart : null,
            style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
            icon: const Icon(Icons.replay),
            label: const Text('Play again'),
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconButton.outlined(
              onPressed: _ready ? () => _zoom(1 / 1.4) : null,
              tooltip: 'Zoom out',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(Icons.remove),
            ),
            IconButton.outlined(
              onPressed: _ready ? () => _zoom(1.4) : null,
              tooltip: 'Zoom in',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(Icons.add),
            ),
            OutlinedButton.icon(
              onPressed: _ready ? _showWholeMap : null,
              style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
              icon: const Icon(Icons.fit_screen),
              label: const Text('Show whole map'),
            ),
          ],
        ),
      ],
    );
  }

  void _zoom(double factor) {
    _tapBlocked = true;
    _game.zoomMap(factor);
  }

  void _showWholeMap() {
    _tapBlocked = true;
    _game.showWholeMap();
  }

  void _pointerDown(PointerDownEvent event) {
    if (_pointerStarts.isEmpty) _tapBlocked = false;
    _pointerStarts[event.pointer] = event.localPosition;
    // Even a stationary two-finger contact must never become a move tap.
    if (_pointerStarts.length > 1) _tapBlocked = true;
  }

  void _pointerMove(PointerMoveEvent event) {
    final start = _pointerStarts[event.pointer];
    if (start != null && (event.localPosition - start).distance > kTouchSlop) {
      _tapBlocked = true;
    }
  }

  void _mapError() {
    _game.markMapUnavailable();
    _tapBlocked = true;
    if (!_failed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _ready = false;
            _failed = true;
          });
        }
      });
    }
  }

  Widget _buildMap() {
    return ClipRect(
      child: Listener(
        onPointerDown: _pointerDown,
        onPointerMove: _pointerMove,
        onPointerUp: (event) => _pointerStarts.remove(event.pointer),
        onPointerCancel: (event) {
          _tapBlocked = true;
          _pointerStarts.remove(event.pointer);
          _game.endMapGesture();
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) {
            if (!_tapBlocked) _game.selectDestination(details.localPosition);
          },
          onScaleStart: (details) {
            _tapBlocked = true;
            _game.beginMapGesture(details.localFocalPoint);
          },
          onScaleUpdate: (details) =>
              _game.updateMapGesture(details.localFocalPoint, details.scale),
          onScaleEnd: (_) => _game.endMapGesture(),
          // Remove Flame's recognizers from the arena; its onTapDown callback
          // is also a no-op, so movement only happens after a resolved tap-up.
          child: IgnorePointer(
            child: GameWidget<NeighborhoodGame>(
              game: _game,
              loadingBuilder: (_) =>
                  const Center(child: CircularProgressIndicator()),
              errorBuilder: (_, error) {
                _mapError();
                return const Center(child: Icon(Icons.map_outlined, size: 48));
              },
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../game/neighborhood_game.dart';
import '../../ui/basebound_ui.dart';
import '../../widgets/basebound_mascot.dart';
import '../help/help_screen.dart';
import '../parent/data/family_plan.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({this.destination, this.onNewGame, super.key});

  final SafePoint? destination;
  final VoidCallback? onNewGame;

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
  bool _helpOpen = false;

  Future<void> _openHelp() async {
    if (_helpOpen) return;
    _helpOpen = true;
    _tapBlocked = true;
    _pointerStarts.clear();
    _game.endMapGesture();
    final wasPaused = _game.paused;
    _game.pauseEngine();
    try {
      await openHelpScreen(context);
    } finally {
      _helpOpen = false;
      if (mounted && !wasPaused) _game.resumeEngine();
    }
  }

  @override
  void initState() {
    super.initState();
    _game = NeighborhoodGame(
      destination: widget.destination,
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
    if (widget.onNewGame != null) {
      widget.onNewGame!();
      return;
    }
    _game.restart();
    setState(() => _arrived = false);
  }

  void _showDemoInfo() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About this demo'),
        scrollable: true,
        content: Text(
          'This is a practice game, not real-world navigation. '
          '${widget.destination == null ? 'The base is pretend.' : 'The target is a parent-selected safe place. Its safety has not been checked.'} '
          'Your character can move freely.\n\n'
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
        title: const Row(
          children: [
            BaseboundMascot(size: 32),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Practice game',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _openHelp,
            icon: const Icon(Icons.support_outlined),
            tooltip: 'I need help · prototype',
          ),
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
        child: IllustratedBackdrop(
          warm: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: LayoutBuilder(
              builder: (context, constraints) => _buildContent(constraints),
            ),
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
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: BaseboundColors.muted),
        ),
      ],
    );
  }

  Widget _buildInstructions({required bool compact}) {
    final target = widget.destination?.displayName;
    final title = _failed
        ? compact
              ? 'Go back and try again.'
              : 'The map could not load'
        : _arrived
        ? 'You reached ${target ?? 'the base'}!'
        : compact
        ? 'Tap ${target ?? 'the pretend base'}.'
        : 'Reach ${target ?? 'the pretend base'}';
    return SoftPanel(
      padding: EdgeInsets.all(compact ? 12 : 16),
      borderColor: _arrived
          ? BaseboundColors.greenLight
          : _failed
          ? BaseboundColors.coralLight
          : Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!compact) ...[
            const BaseboundMascot(size: 62),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  liveRegion: true,
                  header: true,
                  child: Text(
                    title,
                    maxLines: compact ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: BaseboundColors.ink,
                      fontSize: compact ? 18 : 24,
                      height: 1.18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 6),
                  Text(
                    _failed
                        ? 'Go back and try again.'
                        : _arrived
                        ? widget.destination == null
                              ? 'Your character reached the pretend base.'
                              : 'Your character reached the safe place in this game.'
                        : 'Tap to move. Drag or pinch to explore.',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.3,
                      color: BaseboundColors.muted,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  compact
                      ? 'Practice only.'
                      : 'Practice only. Not real navigation.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: BaseboundColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFittedMap() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        return Center(
          child: Container(
            width: side,
            height: side,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x18112568),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _buildMap(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return SoftPanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_arrived) ...[
            FilledButton.icon(
              onPressed: _ready ? _restart : null,
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              icon: const Icon(Icons.replay_rounded),
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
                style: IconButton.styleFrom(
                  backgroundColor: BaseboundColors.sky,
                  foregroundColor: BaseboundColors.blue,
                  side: BorderSide.none,
                ),
                icon: const Icon(Icons.remove_rounded),
              ),
              IconButton.outlined(
                onPressed: _ready ? () => _zoom(1.4) : null,
                tooltip: 'Zoom in',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                style: IconButton.styleFrom(
                  backgroundColor: BaseboundColors.sky,
                  foregroundColor: BaseboundColors.blue,
                  side: BorderSide.none,
                ),
                icon: const Icon(Icons.add_rounded),
              ),
              OutlinedButton.icon(
                onPressed: _ready ? _showWholeMap : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                icon: const Icon(Icons.fit_screen_rounded),
                label: const Text('Show whole map'),
              ),
            ],
          ),
        ],
      ),
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

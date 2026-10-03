import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../game/neighborhood_game.dart';
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

  @override
  void initState() {
    super.initState();
    _game = NeighborhoodGame(
      destination: widget.destination,
      onArrived: () {
        if (mounted) setState(() => _arrived = true);
      },
    );
  }

  void _restart() {
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
        content: Text(
          'This is a practice game, not real-world navigation. '
          '${widget.destination == null ? 'The base is pretend.' : 'The target is a parent-selected practice place, not a verified safe destination.'} '
          'Your character can move freely.\n\n'
          'The map shows 2 × 2 km around TAURON Arena in Kraków.\n\n'
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
        title: const Text('Practice game'),
        actions: [
          if (!_arrived)
            IconButton(
              onPressed: _restart,
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
        child: LayoutBuilder(
          builder: (context, constraints) => _buildContent(constraints),
        ),
      ),
    );
  }

  Widget _buildContent(BoxConstraints constraints) {
    // Keep the map usable on short screens; larger text can scroll naturally.
    final mapHeight = math.max(260.0, constraints.maxHeight - 220);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            liveRegion: true,
            header: true,
            child: Text(
              _arrived
                  ? 'You reached ${widget.destination?.displayName ?? 'the base'}!'
                  : 'Reach ${widget.destination?.displayName ?? 'the pretend base'}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _arrived
                ? 'You guided your character to the practice target.'
                : 'Tap the map to move your character.',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          SizedBox(height: mapHeight, child: _buildMap()),
          const SizedBox(height: 8),
          const Text(
            '© OpenStreetMap contributors · ODbL',
            style: TextStyle(fontSize: 12, color: Color(0xFF465448)),
          ),
          if (_arrived) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _restart,
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              icon: const Icon(Icons.replay),
              label: const Text('Play again'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMap() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: GameWidget<NeighborhoodGame>(
        game: _game,
        loadingBuilder: (_) => const Center(child: CircularProgressIndicator()),
        errorBuilder: (_, error) => const Center(
          child: Text('The map could not load. Go back and try again.'),
        ),
      ),
    );
  }
}

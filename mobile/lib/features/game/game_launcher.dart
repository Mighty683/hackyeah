/// Loads saved safe places and picks a fresh target for each practice game.
library;

import 'dart:math';

import 'package:flutter/material.dart';

import '../../game/maps/demo_map.dart';
import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import '../help/help_screen.dart';
import '../parent/data/family_plan.dart';
import '../parent/data/family_plan_repository.dart';
import 'game_screen.dart';

class GameLauncher extends StatefulWidget {
  const GameLauncher({super.key, this.gender = ChildGender.girl});

  final ChildGender gender;

  @override
  State<GameLauncher> createState() => _GameLauncherState();
}

class _GameLauncherState extends State<GameLauncher> {
  final _repository = FamilyPlanRepository();
  final _random = Random();
  late Future<SafePoint?> _destination = _chooseDestination();
  int _round = 0;
  bool _helpOpen = false;

  Future<void> _openHelp() async {
    if (_helpOpen) return;
    setState(() => _helpOpen = true);
    try {
      await openHelpScreen(context);
    } finally {
      if (mounted) setState(() => _helpOpen = false);
    }
  }

  Future<SafePoint?> _chooseDestination() async {
    final plan = await _repository.load();
    if (plan.safePoints.isEmpty) return null;
    final map = await DemoMapRepository().load();
    final points = plan.safePoints
        .where(
          (point) =>
              point.longitude >= map.bounds[0] &&
              point.longitude <= map.bounds[2] &&
              point.latitude >= map.bounds[1] &&
              point.latitude <= map.bounds[3],
        )
        .toList();
    if (points.isEmpty) return null;
    return points[_random.nextInt(points.length)];
  }

  void _newGame() {
    setState(() {
      _round++;
      _destination = _chooseDestination();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SafePoint?>(
      key: ValueKey(_round),
      future: _destination,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError &&
            !_helpOpen) {
          return GameScreen(
            key: ValueKey(_round),
            destination: snapshot.data,
            gender: widget.gender,
            onNewGame: _newGame,
          );
        }
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: Navigator.canPop(context)
                ? const BaseboundBackButton()
                : null,
            title: const Text('Practice game'),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: HelpEntryButton(onPressed: _openHelp),
            ),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: _PracticePreparation(
                    hasError: snapshot.hasError,
                    onRetry: _newGame,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PracticePreparation extends StatelessWidget {
  const _PracticePreparation({required this.hasError, required this.onRetry});

  final bool hasError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Align(
        alignment: Alignment.centerLeft,
        child: BaseboundIcon(
          BaseboundIconName.map,
          size: 64,
          color: BaseboundColors.blue,
          calm: true,
        ),
      ),
      const SizedBox(height: 24),
      Text(
        hasError ? 'Let’s try that again' : 'Preparing your practice',
        style: Theme.of(context).textTheme.headlineMedium
            ?.copyWith(fontSize: 28),
      ),
      const SizedBox(height: 12),
      Text(
        hasError
            ? 'Your practice places could not load. Go back or try again.'
            : 'Choosing a place on the offline map.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 24),
      if (hasError)
        FilledButton(onPressed: onRetry, child: const Text('Try again'))
      else
        const Align(
          alignment: Alignment.centerLeft,
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              semanticsLabel: 'Loading practice game',
            ),
          ),
        ),
      const SizedBox(height: 24),
      const Text(
        'Practice only. Places are not verified safe destinations.',
        style: TextStyle(
          fontSize: 14,
          color: BaseboundColors.muted,
          height: 1.4,
        ),
      ),
    ],
  );
}

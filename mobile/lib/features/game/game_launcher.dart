/// Loads saved safe places and picks a fresh target for each practice game.
library;

import 'dart:math';

import 'package:flutter/material.dart';

import '../../game/maps/demo_map.dart';
import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import '../../widgets/basebound_mascot.dart';
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: HelpEntryButton(onPressed: _openHelp),
            ),
          ),
          body: Center(
            child: IllustratedBackdrop(
              warm: true,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: snapshot.hasError
                                ? Alignment.centerLeft
                                : Alignment.center,
                            child: BaseboundMascot(
                              size: snapshot.hasError ? 104 : 132,
                              pose: snapshot.hasError
                                  ? DinoPose.calm
                                  : DinoPose.listen,
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (snapshot.hasError) ...[
                            const Text(
                              'Could not load safe places. Go back or try again.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                height: 1.3,
                                color: BaseboundColors.ink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: _newGame,
                              child: const Text('Try again'),
                            ),
                          ] else
                            const Center(child: CircularProgressIndicator()),
                        ],
                      ),
                    ),
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

/// Loads saved practice places and picks a fresh target for each game/replay.
library;

import 'dart:math';

import 'package:flutter/material.dart';

import '../../game/maps/demo_map.dart';
import '../parent/data/family_plan.dart';
import '../parent/data/family_plan_repository.dart';
import 'game_screen.dart';

class GameLauncher extends StatefulWidget {
  const GameLauncher({super.key});

  @override
  State<GameLauncher> createState() => _GameLauncherState();
}

class _GameLauncherState extends State<GameLauncher> {
  final _repository = FamilyPlanRepository();
  final _random = Random();
  late Future<SafePoint?> _destination = _chooseDestination();
  int _round = 0;

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
            !snapshot.hasError) {
          return GameScreen(
            key: ValueKey(_round),
            destination: snapshot.data,
            onNewGame: _newGame,
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Practice game')),
          body: Center(
            child: snapshot.hasError
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Could not load practice places. Go back or try again.',
                        ),
                      ),
                      FilledButton(
                        onPressed: _newGame,
                        child: const Text('Try again'),
                      ),
                    ],
                  )
                : const CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

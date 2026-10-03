import 'package:flutter/material.dart';

import '../../game/maps/demo_map.dart';
import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import '../demo/data/demo_data_seeder.dart';
import '../help/help_screen.dart';
import '../landmarks/data/landmark.dart';
import '../landmarks/data/landmark_repository.dart';
import '../parent/data/family_plan_repository.dart';
import '../parent/data/family_plan.dart';
import 'game_screen.dart';

// Match the original seed coordinates so existing installs get the demo photo
// without rewriting saved family records or assigning it to real destinations.
bool _isDemoHome(SafePoint point) =>
    point.isDemo &&
    point.latitude == demoHome.latitude &&
    point.longitude == demoHome.longitude;

/// Opens one familiar-place map; no random destination or fictional player.
class GameLauncher extends StatefulWidget {
  const GameLauncher({super.key});
  @override
  State<GameLauncher> createState() => _GameLauncherState();
}

class _MapContent {
  const _MapContent(this.map, this.places, this.photoDirectory);
  final DemoMap map;
  final List<Landmark> places;
  final String photoDirectory;
}

class _GameLauncherState extends State<GameLauncher> {
  late Future<_MapContent> _content = _load();
  bool _helpOpen = false;

  Future<_MapContent> _load() async {
    final repository = LandmarkRepository();
    final landmarks = await repository.load();
    final directory = await repository.photoDirectory();
    final plan = await FamilyPlanRepository().load();
    final map = await DemoMapRepository().load();
    // Adapt existing named parent pins for this view only. Stored data and photo
    // records remain separate, so existing family setup is not migrated or lost.
    final places = <Landmark>[
      ...landmarks,
      for (var i = 0; i < plan.safePoints.length; i++)
        Landmark(
          id: 'family_place_$i',
          name: plan.safePoints[i].displayName,
          icon: _isDemoHome(plan.safePoints[i])
              ? '🏠'
              : plan.safePoints[i].icon,
          isDestination: true,
          photoAsset: _isDemoHome(plan.safePoints[i])
              ? 'assets/landmarks/demo-home.png'
              : null,
          photoName: '',
          latitude: plan.safePoints[i].latitude,
          longitude: plan.safePoints[i].longitude,
          isDemo: plan.safePoints[i].isDemo,
        ),
    ];
    return _MapContent(map, places, directory.path);
  }

  Future<void> _help() async {
    if (_helpOpen) return;
    setState(() => _helpOpen = true);
    try {
      await openHelpScreen(context);
    } finally {
      if (mounted) setState(() => _helpOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_MapContent>(
    future: _content,
    builder: (context, snapshot) {
      if (snapshot.hasData && !_helpOpen) {
        final data = snapshot.data!;
        return GameScreen(
          map: data.map,
          landmarks: data.places,
          photoDirectory: data.photoDirectory,
        );
      }
      return Scaffold(
        appBar: AppBar(
          leading: Navigator.canPop(context)
              ? const BaseboundBackButton()
              : null,
          title: const Text('Our map'),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: HelpEntryButton(onPressed: _help),
          ),
        ),
        body: IllustratedBackdrop(
          warm: true,
          child: Center(
            child: snapshot.hasError
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: SoftPanel(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: BaseboundIcon(
                              BaseboundIconName.map,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Could not load our map. Saved places have not been reset.',
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => setState(() => _content = _load()),
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  )
                : const CircularProgressIndicator(
                    semanticsLabel: 'Loading our map',
                  ),
          ),
        ),
      );
    },
  );
}

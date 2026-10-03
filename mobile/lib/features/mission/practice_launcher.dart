import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import '../../widgets/basebound_mascot.dart';
import '../game/game_launcher.dart';
import '../landmarks/landmark_library_screen.dart';
import '../parent/data/family_plan.dart';
import 'air_raid_mission.dart';
import 'mission_audio.dart';
import 'mission_screen.dart';

/// Keeps fictional alarm training separate from the existing map practice.
class PracticeLauncher extends StatefulWidget {
  const PracticeLauncher({super.key, this.child = const ChildProfile()});

  final ChildProfile child;

  @override
  State<PracticeLauncher> createState() => _PracticeLauncherState();
}

enum _Selection { activity, mode }

class _PracticeLauncherState extends State<PracticeLauncher>
    with WidgetsBindingObserver {
  MissionAudio _audio = MissionAudio();
  _Selection _selection = _Selection.activity;
  bool _audioAvailable = true;
  bool _opening = false;
  int _audioRevision = 0;

  String get _instruction => switch (_selection) {
    _Selection.activity => 'Choose your practice. Alarm practice, map practice, or familiar landmarks.',
    _Selection.mode => 'Choose where to practice. At home, or outside.',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _speak();
  }

  Future<void> _speak() async {
    final revision = ++_audioRevision;
    try {
      final available = await _audio.initialize();
      if (!mounted || revision != _audioRevision || _opening) return;
      setState(() => _audioAvailable = available);
      if (available) await _audio.narrate(_instruction);
    } catch (_) {
      if (mounted && revision == _audioRevision) {
        setState(() => _audioAvailable = false);
      }
    }
  }

  void _select(_Selection selection) {
    setState(() => _selection = selection);
    _speak();
  }

  void _openMission(MissionMode mode) => _open(
    MissionScreen(mode: mode, gender: widget.child.gender ?? ChildGender.girl),
  );

  Future<void> _open(Widget screen) async {
    if (_opening) return;
    setState(() => _opening = true);
    _audioRevision++;
    await _audio.dispose();
    if (!mounted) return;
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => screen));
    if (!mounted) return;
    _audio = MissionAudio();
    setState(() {
      _opening = false;
      _selection = _Selection.activity;
    });
    _speak();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _audioRevision++;
      _audio.stop();
    } else if (!_opening) {
      _speak();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioRevision++;
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_selection) {
      _Selection.activity => 'Choose practice',
      _Selection.mode => 'Where shall we practice?',
    };
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context) ? const BaseboundBackButton() : null,
        title: const Text('Practice only'),
      ),
      body: SafeArea(
        child: IllustratedBackdrop(
          warm: true,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.child.fullName.trim().isNotEmpty) ...[
                      Text(
                        'Hi, ${widget.child.fullName}!',
                        style: const TextStyle(
                          color: BaseboundColors.muted,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _PracticeHeading(
                      title: title,
                      instruction: _selection == _Selection.activity
                          ? 'Pick one activity to start.'
                          : 'Choose a scene for alarm practice.',
                    ),
                    const SizedBox(height: 24),
                    ..._choices(),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _opening ? null : _speak,
                        icon: const BaseboundIcon(
                          BaseboundIconName.speaker,
                          size: 24,
                        ),
                        label: const Text('Replay audio'),
                      ),
                    ),
                    if (!_audioAvailable)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: SoftPanel(
                          child: Text(
                            'Voice is unavailable. Ask an adult to help. '
                            'An offline English voice is needed for spoken practice.',
                            style: TextStyle(color: BaseboundColors.muted),
                          ),
                        ),
                      ),
                    if (_selection != _Selection.activity)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TextButton.icon(
                          onPressed: _opening
                              ? null
                              : () => _select(_Selection.activity),
                          icon: const BaseboundIcon(BaseboundIconName.back),
                          label: const Text('Choose practice'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _choices() => switch (_selection) {
    _Selection.activity => [
      _choice(
        'Alarm practice',
        BaseboundIconName.alarm,
        () => _select(_Selection.mode),
      ),
      _choice(
        'Landmark practice',
        BaseboundIconName.pin,
        () => _open(const LandmarkLibraryScreen()),
      ),
      _choice(
        'Map practice',
        BaseboundIconName.map,
        () => _open(
          GameLauncher(gender: widget.child.gender ?? ChildGender.girl),
        ),
      ),
    ],
    _Selection.mode => [
      _choice(
        'At home',
        BaseboundIconName.home,
        () => _openMission(MissionMode.home),
      ),
      _choice(
        'Outside',
        BaseboundIconName.park,
        () => _openMission(MissionMode.outdoor),
      ),
    ],
  };

  Widget _choice(
    String label,
    BaseboundIconName icon,
    VoidCallback onPressed,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: BaseboundActionTile(
      label: label,
      icon: icon,
      onPressed: _opening ? null : onPressed,
    ),
  );
}

class _PracticeHeading extends StatelessWidget {
  const _PracticeHeading({required this.title, required this.instruction});

  final String title;
  final String instruction;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final heading = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: BaseboundColors.ink,
              fontSize: 28,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            instruction,
            style: const TextStyle(
              color: BaseboundColors.muted,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      );
      if (constraints.maxWidth < 280 ||
          MediaQuery.textScalerOf(context).scale(28) > 38 ||
          MediaQuery.sizeOf(context).height < 600) {
        return heading;
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: heading),
          const SizedBox(width: 16),
          const BaseboundMascot(size: 64, pose: DinoPose.point),
        ],
      );
    },
  );
}

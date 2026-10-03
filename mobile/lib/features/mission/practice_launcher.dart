import 'package:flutter/material.dart';

import '../game/game_launcher.dart';
import 'air_raid_mission.dart';
import 'mission_audio.dart';
import 'mission_screen.dart';

/// Keeps fictional alarm training separate from the existing map practice.
class PracticeLauncher extends StatefulWidget {
  const PracticeLauncher({super.key});

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
    _Selection.activity =>
      'Choose your practice. An alarm at home, or the map game.',
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

  void _openMission(MissionMode mode) => _open(MissionScreen(mode: mode));

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
      appBar: AppBar(title: const Text('Practice only')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  ..._choices(),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _opening ? null : _speak,
                    icon: const Icon(Icons.volume_up_outlined),
                    label: const Text('Replay audio'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(64, 56),
                    ),
                  ),
                  if (!_audioAvailable)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Voice is unavailable. Ask an adult to help. '
                        'An offline English voice is needed for spoken practice.',
                      ),
                    ),
                  if (_selection != _Selection.activity)
                    TextButton.icon(
                      onPressed: _opening
                          ? null
                          : () => _select(_Selection.activity),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Choose practice'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _choices() => switch (_selection) {
    _Selection.activity => [
      _card(
        'Alarm practice',
        Icons.notifications_active_outlined,
        () => _select(_Selection.mode),
      ),
      _card(
        'Map practice',
        Icons.map_outlined,
        () => _open(const GameLauncher()),
      ),
    ],
    _Selection.mode => [
      _card(
        'At home',
        Icons.home_outlined,
        () => _openMission(MissionMode.home),
      ),
      _card(
        'Outside',
        Icons.apartment_outlined,
        () => _openMission(MissionMode.outdoor),
      ),
    ],
  };

  Widget _card(String label, IconData icon, VoidCallback onPressed) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: FilledButton.tonal(
      onPressed: _opening ? null : onPressed,
      style: FilledButton.styleFrom(padding: const EdgeInsets.all(24)),
      child: Column(
        children: [
          Icon(icon, size: 60),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );
}

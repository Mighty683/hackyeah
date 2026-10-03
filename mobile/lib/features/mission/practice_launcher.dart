import 'package:flutter/material.dart';

import '../../ui/basebound_ui.dart';
import '../../widgets/basebound_mascot.dart';
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
                    const Center(child: BaseboundMascot(size: 112)),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: BaseboundColors.ink,
                        fontSize: 30,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ..._choices(),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _opening ? null : _speak,
                      icon: const Icon(Icons.volume_up_rounded),
                      label: const Text('Replay audio'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size(64, 56),
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
                          icon: const Icon(Icons.arrow_back_rounded),
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
      _card(
        'Alarm practice',
        Icons.notifications_active_rounded,
        () => _select(_Selection.mode),
      ),
      _card(
        'Map practice',
        Icons.map_rounded,
        () => _open(const GameLauncher()),
      ),
    ],
    _Selection.mode => [
      _card(
        'At home',
        Icons.home_rounded,
        () => _openMission(MissionMode.home),
      ),
      _card(
        'Outside',
        Icons.park_rounded,
        () => _openMission(MissionMode.outdoor),
      ),
    ],
  };

  Widget _card(String label, IconData icon, VoidCallback onPressed) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: _ActivityCard(
      label: label,
      icon: icon,
      onPressed: _opening ? null : onPressed,
    ),
  );
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onPressed != null,
    child: Material(
      color: Colors.white,
      elevation: 3,
      shadowColor: BaseboundColors.ink.withValues(alpha: .08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: BaseboundColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(builder: _buildContent),
        ),
      ),
    ),
  );

  Widget _buildContent(BuildContext context, BoxConstraints constraints) {
    final illustration = Container(
      width: 88,
      height: 96,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [BaseboundColors.sky, BaseboundColors.cream],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(icon, size: 54, color: BaseboundColors.blue),
    );
    final text = Text(
      label,
      style: const TextStyle(
        color: BaseboundColors.ink,
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
    );
    if (constraints.maxWidth < 220 ||
        MediaQuery.textScalerOf(context).scale(24) > 32) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: illustration),
          const SizedBox(height: 16),
          text,
        ],
      );
    }
    return Row(
      children: [
        illustration,
        const SizedBox(width: 18),
        Expanded(child: text),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward_rounded, color: BaseboundColors.blue),
      ],
    );
  }
}

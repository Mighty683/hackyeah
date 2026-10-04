import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import '../../widgets/basebound_mascot.dart';
import '../game/game_launcher.dart';
import '../parent/data/family_plan.dart';
import 'air_raid_mission.dart';
import 'lost_mission_launcher.dart';
import '../../audio/practice_audio.dart';
import 'mission_screen.dart';

/// Offers a scenario list and the shared familiar-place map as two activities.
class PracticeLauncher extends StatelessWidget {
  const PracticeLauncher({super.key, this.child = const ChildProfile()});

  final ChildProfile child;

  @override
  Widget build(BuildContext context) => _PracticeSelectionScreen(
    child: child,
    initialSelection: _Selection.activity,
  );
}

/// Lists the available fictional training scenarios on a separate route.
class PracticeScenarioScreen extends StatelessWidget {
  const PracticeScenarioScreen({super.key, required this.child});

  final ChildProfile child;

  @override
  Widget build(BuildContext context) => _PracticeSelectionScreen(
    child: child,
    initialSelection: _Selection.scenario,
  );
}

enum _Selection { activity, scenario, mode }

class _PracticeSelectionScreen extends StatefulWidget {
  const _PracticeSelectionScreen({
    required this.child,
    required this.initialSelection,
  });

  final ChildProfile child;
  final _Selection initialSelection;

  @override
  State<_PracticeSelectionScreen> createState() =>
      _PracticeSelectionScreenState();
}

class _PracticeSelectionScreenState extends State<_PracticeSelectionScreen>
    with WidgetsBindingObserver {
  PracticeAudio _audio = PracticeAudio();
  late _Selection _selection = widget.initialSelection;
  bool _audioAvailable = true;
  bool _opening = false;
  int _audioRevision = 0;

  String get _instruction => switch (_selection) {
    _Selection.activity => 'Wybierz zajęcie. Ćwiczenia lub Nasza mapa.',
    _Selection.scenario => 'Wybierz scenariusz. Alarm lub zgubienie się.',
    _Selection.mode => 'Wybierz miejsce ćwiczenia. W domu lub na zewnątrz.',
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

  void _back() {
    if (_opening) return;
    if (_selection == _Selection.mode) {
      _select(_Selection.scenario);
      return;
    }
    Navigator.of(context).pop();
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
    final route = MaterialPageRoute<void>(builder: (_) => screen);
    await Navigator.of(context).push(route);
    // Native audio is shared; wait for the leaving screen to release it.
    await route.completed;
    if (!mounted) return;
    _audio = PracticeAudio();
    setState(() {
      _opening = false;
      _selection = widget.initialSelection;
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
      _Selection.activity => 'Wybierz zajęcie',
      _Selection.scenario => 'Wybierz scenariusz',
      _Selection.mode => 'Gdzie ćwiczymy?',
    };
    return PopScope(
      canPop: !_opening && _selection != _Selection.mode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Navigator.canPop(context) || _selection == _Selection.mode
              ? BaseboundBackButton(enabled: !_opening, onPressed: _back)
              : null,
          title: Text(
            _selection == _Selection.activity ? 'Tuptu' : 'Tylko ćwiczenie',
          ),
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
                          'Cześć, ${widget.child.fullName}!',
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
                        instruction: switch (_selection) {
                          _Selection.activity =>
                            'Wybierz jedno zajęcie na początek.',
                          _Selection.scenario =>
                            'Wybierz historię do ćwiczenia.',
                          _Selection.mode =>
                            'Wybierz scenę do ćwiczenia alarmu.',
                        },
                      ),
                      const SizedBox(height: 24),
                      ..._choices(),
                      const SizedBox(height: 8),
                      if (!kIsWeb)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _opening ? null : _speak,
                            icon: const BaseboundIcon(
                              BaseboundIconName.speaker,
                              size: 24,
                            ),
                            label: const Text('Posłuchaj ponownie'),
                          ),
                        ),
                      if (!_audioAvailable)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: SoftPanel(
                            child: Text(
                              kIsWeb
                                  ? 'Demo w przeglądarce: głos i dźwięki są wyłączone. Czytaj instrukcje z dorosłym.'
                                  : 'Głos jest niedostępny. Poproś dorosłego o pomoc. '
                                        'Do ćwiczeń z narracją potrzebny jest polski głos offline.',
                              style: TextStyle(color: BaseboundColors.muted),
                            ),
                          ),
                        ),
                      if (_selection == _Selection.mode)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: TextButton.icon(
                            onPressed: _opening
                                ? null
                                : () => _select(_Selection.scenario),
                            icon: const BaseboundIcon(BaseboundIconName.back),
                            label: const Text('Wybierz scenariusz'),
                          ),
                        ),
                    ],
                  ),
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
        'Ćwiczenia',
        BaseboundIconName.child,
        () => _open(PracticeScenarioScreen(child: widget.child)),
      ),
      _choice(
        'Nasza mapa',
        BaseboundIconName.map,
        () => _open(const GameLauncher()),
      ),
    ],
    _Selection.scenario => [
      _choice(
        'Ćwiczenie alarmu',
        BaseboundIconName.alarm,
        () => _select(_Selection.mode),
      ),
      _choice(
        "Ćwiczenie zgubienia się",
        BaseboundIconName.lost,
        () => _open(LostMissionLauncher(child: widget.child)),
      ),
    ],
    _Selection.mode => [
      _choice(
        'W domu',
        BaseboundIconName.home,
        () => _openMission(MissionMode.home),
      ),
      _choice(
        'Na zewnątrz',
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
      large: _selection == _Selection.activity,
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

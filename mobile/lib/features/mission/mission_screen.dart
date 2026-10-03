import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import '../../widgets/basebound_mascot.dart';
import 'air_raid_mission.dart';
import 'mission_audio.dart';
import 'mission_choice_card.dart';
import 'mission_scene.dart';

/// An explicitly fictional training session, separate from the help prototype.
class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key, required this.mode, this.audio});

  final MissionMode mode;
  final MissionAudio? audio;

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen>
    with WidgetsBindingObserver {
  late final MissionSession _session = MissionSession(mode: widget.mode);
  late MissionAudio _audio = widget.audio ?? MissionAudio();
  bool _audioReady = false;
  bool _initializingAudio = true;
  bool _speaking = false;
  bool _exiting = false;
  bool _foreground = true;
  int _audioRequest = 0;
  double _dragDistance = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initializeAudio());
  }

  Future<void> _initializeAudio({bool retry = false}) async {
    final request = ++_audioRequest;
    setState(() {
      _initializingAudio = true;
      _speaking = false;
    });
    if (retry && widget.audio == null) {
      await _audio.dispose();
      if (!mounted || _exiting || request != _audioRequest) return;
      _audio = MissionAudio();
    }
    var ready = false;
    try {
      ready = await _audio.initialize();
    } catch (_) {
      ready = false;
    }
    if (!mounted || _exiting || request != _audioRequest) return;
    setState(() {
      _audioReady = ready;
      _initializingAudio = false;
    });
    if (ready) await _narrate();
  }

  String get _spokenText {
    if (_session.isComplete) {
      return 'You finished the practice. You learned to move away from windows, '
          'find a protected place, tell a trusted adult, and wait for the all-clear.';
    }
    return _session.feedback ?? _session.step.narration;
  }

  Future<void> _narrate() async {
    if (!_audioReady || !_foreground || _exiting) return;
    final request = ++_audioRequest;
    final text = _spokenText;
    final sound = _session.hasFeedback || _session.isComplete
        ? null
        : _session.step.sound;
    setState(() => _speaking = true);
    try {
      await _audio.stop();
      if (!mounted || !_foreground || _exiting || request != _audioRequest) {
        return;
      }
      if (sound == 'alarm' || sound == 'all_clear') {
        unawaited(HapticFeedback.lightImpact());
      }
      await _audio.narrate(text, sound: sound);
    } catch (_) {
      if (mounted && request == _audioRequest) {
        setState(() => _audioReady = false);
      }
    } finally {
      if (mounted && request == _audioRequest) {
        setState(() => _speaking = false);
      }
    }
  }

  void _choose(String id) {
    if (_session.hasFeedback || _session.isComplete) return;
    setState(() => _session.choose(id));
    unawaited(_narrate());
  }

  void _next() {
    final choice = _session.selectedChoice;
    setState(() {
      if (choice != null &&
          !choice.isCorrect &&
          !choice.continuesAfterFeedback) {
        _session.retry();
      } else {
        _session.advance();
      }
      _dragDistance = 0;
    });
    unawaited(_narrate());
  }

  void _restart() {
    setState(_session.restart);
    unawaited(_narrate());
  }

  Future<void> _exit() async {
    if (_exiting) return;
    setState(() => _exiting = true);
    ++_audioRequest;
    await _audio.dispose();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) {
      unawaited(_narrate());
      return;
    }
    if (!_initializingAudio) ++_audioRequest;
    if (mounted) setState(() => _speaking = false);
    unawaited(_audio.stop());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ++_audioRequest;
    unawaited(_audio.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope<void>(
    canPop: _exiting,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) unawaited(_exit());
    },
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: BaseboundColors.cream,
        foregroundColor: BaseboundColors.ink,
        centerTitle: true,
        leading: BaseboundBackButton(
          enabled: !_exiting,
          tooltip: 'Leave practice',
          onPressed: _exiting ? null : () => unawaited(_exit()),
        ),
        title: _headerTitle(),
        actions: [
          Semantics(
            label: 'Replay audio',
            button: true,
            enabled: _audioReady,
            onTap: _audioReady ? () => unawaited(_narrate()) : null,
            child: ExcludeSemantics(
              child: IconButton(
                onPressed: _audioReady ? () => unawaited(_narrate()) : null,
                tooltip: 'Replay audio',
                style: IconButton.styleFrom(
                  backgroundColor: BaseboundColors.sky,
                ),
                icon: BaseboundIcon(
                  BaseboundIconName.speaker,
                  size: 28,
                  color: _speaking ? BaseboundColors.blue : BaseboundColors.ink,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: IllustratedBackdrop(
          warm: true,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: _session.isComplete
                    ? _completionLayout()
                    : _stepLayout(),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  bool get _needsChoiceList =>
      MediaQuery.sizeOf(context).width < 360 ||
      MediaQuery.textScalerOf(context).scale(1) > 1.1;

  Widget _headerTitle() {
    if (_needsChoiceList || _session.isComplete) {
      return const Text(
        'Practice · air raid',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Practice · air raid',
          style: TextStyle(fontSize: 11, color: BaseboundColors.muted),
        ),
        Text(
          _session.step.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            height: 1.1,
            color: BaseboundColors.ink,
          ),
        ),
      ],
    );
  }

  Widget _audioControls() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (_initializingAudio)
        const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text('Getting the voice ready…', textAlign: TextAlign.center),
        ),
      if (!_audioReady && !_initializingAudio)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: SoftPanel(
            color: BaseboundColors.cream,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const BaseboundIcon(BaseboundIconName.speaker, size: 30),
                const SizedBox(height: 8),
                const Text(
                  'The voice is unavailable. Ask an adult to read each step with you.',
                  style: TextStyle(fontSize: 17),
                  textAlign: TextAlign.center,
                ),
                TextButton.icon(
                  onPressed: () => unawaited(_initializeAudio(retry: true)),
                  icon: const BaseboundIcon(BaseboundIconName.replay),
                  label: const Text('Try the voice again'),
                  style: TextButton.styleFrom(minimumSize: const Size(64, 52)),
                ),
              ],
            ),
          ),
        ),
    ],
  );

  Widget _stepLayout() => LayoutBuilder(
    builder: (context, constraints) {
      final step = _session.step;
      final visual = _session.selectedChoice?.visual ?? step.visual;
      // Short screens use cards so pictured targets remain large enough to tap.
      final sceneChoices =
          _useSceneChoices(visual) && constraints.maxHeight >= 620;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CustomMultiChildLayout(
              delegate: _MissionViewportLayout(),
              children: [
                LayoutId(
                  id: _MissionRegion.instruction,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _audioControls(),
                        if (!_session.hasFeedback)
                          SoftPanel(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 11,
                            ),
                            child: Text(
                              step.narration,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                          ),
                        if (step.id == 'get_down' && !_session.hasFeedback)
                          const Text(
                            'Drag down, or tap the arrow.',
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ),
                LayoutId(
                  id: _MissionRegion.actions,
                  child: SingleChildScrollView(
                    child: _session.hasFeedback
                        ? _feedback()
                        : step.isDecision && !sceneChoices
                        ? _choiceGrid(step.choices)
                        : const SizedBox.shrink(),
                  ),
                ),
                LayoutId(
                  id: _MissionRegion.scene,
                  child: Center(
                    child: _scene(visual, sceneChoices: sceneChoices),
                  ),
                ),
              ],
            ),
          ),
          if (!step.isDecision || _session.hasFeedback) ...[
            const SizedBox(height: 10),
            _nextButton(),
          ],
        ],
      );
    },
  );

  Widget _scene(MissionVisual visual, {required bool sceneChoices}) {
    final scene = MissionScene(
      visual: visual,
      stepId: _session.step.id,
      choices: sceneChoices && !_session.hasFeedback
          ? _session.step.choices
          : const [],
      selectedChoice: _session.selectedChoice,
      onChoose: _session.hasFeedback ? null : _choose,
    );
    if (_session.step.id != 'get_down') return scene;
    return GestureDetector(
      onVerticalDragStart: (_) => _dragDistance = 0,
      onVerticalDragUpdate: (details) {
        _dragDistance += details.delta.dy;
        if (_dragDistance >= 48) _choose('down');
      },
      child: scene,
    );
  }

  bool _useSceneChoices(MissionVisual visual) =>
      missionUsesSceneChoices(visual) &&
      MediaQuery.sizeOf(context).width >= 360 &&
      MediaQuery.textScalerOf(context).scale(1) <= 1.1;

  Widget _choiceGrid(List<MissionChoice> choices) => LayoutBuilder(
    builder: (context, constraints) {
      final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.4;
      final columns = constraints.maxWidth < 330 || largeText ? 1 : 2;
      final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: choices
            .map(
              (choice) => SizedBox(
                width: width,
                child: MissionChoiceCard(
                  choice: choice,
                  compact: true,
                  onPressed: () => _choose(choice.id),
                ),
              ),
            )
            .toList(),
      );
    },
  );

  Widget _feedback() => Semantics(
    liveRegion: true,
    child: BaseboundGuide(
      message: _session.feedback!,
      positive: _session.selectedChoice!.isCorrect,
      pose: _session.selectedChoice!.isCorrect
          ? DinoPose.celebrate
          : DinoPose.think,
    ),
  );

  Widget _nextButton() {
    final choice = _session.selectedChoice;
    final retry =
        choice != null && !choice.isCorrect && !choice.continuesAfterFeedback;
    final label = retry ? 'Try again' : _nextLabel();
    return FilledButton.icon(
      onPressed: _next,
      icon: BaseboundIcon(
        retry ? BaseboundIconName.replay : BaseboundIconName.next,
      ),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 64),
        backgroundColor: BaseboundColors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 21,
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsets.all(18),
      ),
    );
  }

  String _nextLabel() => switch (_session.step.id) {
    'alarm' => 'Find a place',
    'outdoor_alarm' => 'Choose where to go',
    'contacts' => 'Tell them',
    'communication' => 'Hear the reply',
    'message' => 'Stay here',
    'noise' || 'outdoor_sheltered' => 'Keep waiting',
    'quiet' => 'Wait for the all-clear',
    'all_clear' => 'Remember the steps',
    'recall' => 'Finish practice',
    _ => 'Next step',
  };

  Widget _completionLayout() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _audioControls(),
              const BaseboundIcon(
                BaseboundIconName.badge,
                size: 64,
                color: BaseboundColors.green,
              ),
              const Text(
                'Practice complete',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * .25,
                child: const Center(
                  child: MissionScene(visual: MissionVisual.recall),
                ),
              ),
              const BaseboundGuide(
                message: 'Move inside. Tell someone. Stay until the all-clear.',
              ),
            ],
          ),
        ),
      ),
      FilledButton.icon(
        onPressed: _restart,
        icon: const BaseboundIcon(BaseboundIconName.replay),
        label: const Text('Play again'),
        style: FilledButton.styleFrom(minimumSize: const Size(64, 64)),
      ),
      TextButton.icon(
        onPressed: () => unawaited(_exit()),
        icon: const BaseboundIcon(BaseboundIconName.home),
        label: const Text('Back to practice choices'),
        style: TextButton.styleFrom(minimumSize: const Size(64, 56)),
      ),
    ],
  );
}

enum _MissionRegion { instruction, scene, actions }

/// Readable content takes priority; the uncropped illustration takes the rest.
/// Accessibility text can scroll without moving the primary button.
class _MissionViewportLayout extends MultiChildLayoutDelegate {
  _MissionViewportLayout();

  @override
  void performLayout(Size size) {
    final instruction = layoutChild(
      _MissionRegion.instruction,
      BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        maxHeight: size.height * .4,
      ),
    );
    final actions = layoutChild(
      _MissionRegion.actions,
      BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        maxHeight: (size.height - instruction.height) * .8,
      ),
    );
    final sceneHeight = (size.height - instruction.height - actions.height - 16)
        .clamp(0.0, size.height);
    layoutChild(
      _MissionRegion.scene,
      BoxConstraints.tight(Size(size.width, sceneHeight)),
    );
    positionChild(_MissionRegion.instruction, Offset.zero);
    positionChild(_MissionRegion.scene, Offset(0, instruction.height + 8));
    positionChild(
      _MissionRegion.actions,
      Offset(0, size.height - actions.height),
    );
  }

  @override
  bool shouldRelayout(_MissionViewportLayout oldDelegate) => false;
}

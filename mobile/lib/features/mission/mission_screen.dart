import 'dart:async';

import '../parent/data/family_plan.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import 'air_raid_mission.dart';
import 'mission_audio.dart';
import 'mission_scene.dart';

/// An explicitly fictional training session, separate from the help prototype.
class MissionScreen extends StatefulWidget {
  const MissionScreen({
    super.key,
    required this.mode,
    this.audio,
    this.gender = ChildGender.girl,
  });

  final MissionMode mode;
  final MissionAudio? audio;

  final ChildGender gender;

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
  bool _effectsEnabled = true;
  bool _exiting = false;
  bool _foreground = true;
  int _audioRequest = 0;

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
    await _narrate();
  }

  String get _spokenText {
    if (_session.isComplete) {
      return 'You finished the practice. You learned to move away from windows, '
          'find a protected place, tell a trusted adult, and wait for the all-clear.';
    }
    return _session.feedback ?? _session.step.narration;
  }

  String? get _soundCue {
    if (!_effectsEnabled) return null;
    if (_session.isComplete) return 'success';
    final choice = _session.selectedChoice;
    if (choice == null) return _session.step.sound;
    if (choice.continuesAfterFeedback || choice.id == 'more_places') {
      return 'select';
    }
    if (!choice.isCorrect) return 'retry';
    if (_session.step.id == 'get_down' || _session.step.id == 'protect_head') {
      return 'action';
    }
    return 'success';
  }

  Future<void> _narrate() async {
    if (_initializingAudio || !_foreground || _exiting) return;
    final request = ++_audioRequest;
    final text = _spokenText;
    final sound = _soundCue;
    setState(() => _speaking = _audioReady);
    try {
      await _audio.stop();
      if (!mounted || !_foreground || _exiting || request != _audioRequest) {
        return;
      }
      if (sound == 'alarm' || sound == 'all_clear') {
        unawaited(HapticFeedback.lightImpact());
      }
      if (_audioReady) {
        await _audio.narrate(text, sound: sound);
      } else if (sound != null) {
        await _audio.playCue(sound);
      }
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

  void _toggleEffects() {
    setState(() => _effectsEnabled = !_effectsEnabled);
    // Cancel an in-flight cue immediately, then keep the instruction audible.
    unawaited(_narrate());
  }

  bool get _canReplay =>
      !_initializingAudio && !_exiting && (_audioReady || _soundCue != null);

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
        leading: BaseboundBackButton(
          enabled: !_exiting,
          tooltip: 'Leave practice',
          onPressed: _exiting ? null : () => unawaited(_exit()),
        ),
        title: const Text(
          'Practice · air raid',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: _initializingAudio || _exiting ? null : _toggleEffects,
            tooltip: _effectsEnabled
                ? 'Mute sound effects'
                : 'Unmute sound effects',
            icon: Icon(
              _effectsEnabled ? Icons.music_note_outlined : Icons.music_off,
              size: 24,
              color: BaseboundColors.muted,
            ),
          ),
          Semantics(
            label: 'Replay audio',
            button: true,
            enabled: _canReplay,
            onTap: _canReplay ? () => unawaited(_narrate()) : null,
            child: ExcludeSemantics(
              child: IconButton(
                onPressed: _canReplay ? () => unawaited(_narrate()) : null,
                tooltip: 'Replay audio',
                icon: BaseboundIcon(
                  BaseboundIconName.speaker,
                  size: 24,
                  color: _speaking ? BaseboundColors.blue : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: IllustratedBackdrop(
          warm: true,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
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

  Widget _audioControls() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (_initializingAudio)
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'Getting the voice ready…',
            style: TextStyle(color: BaseboundColors.muted),
          ),
        ),
      if (!_audioReady && !_initializingAudio)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: SoftPanel(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BaseboundIcon(BaseboundIconName.speaker, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The voice is unavailable. Ask an adult to read each step with you.',
                        style: TextStyle(fontSize: 16, height: 1.4),
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => unawaited(_initializeAudio(retry: true)),
                  icon: const BaseboundIcon(BaseboundIconName.replay),
                  label: const Text('Try the voice again'),
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
      if (step.isDecision && !_session.hasFeedback) {
        return _decisionLayout(visual, constraints);
      }
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
                        Text(
                          step.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        if (!_session.hasFeedback)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              step.narration,
                              style: const TextStyle(fontSize: 17, height: 1.4),
                            ),
                          ),
                        _audioControls(),
                      ],
                    ),
                  ),
                ),
                LayoutId(
                  id: _MissionRegion.actions,
                  child: SingleChildScrollView(
                    child: _session.hasFeedback
                        ? _feedback()
                        : const SizedBox.shrink(),
                  ),
                ),
                LayoutId(
                  id: _MissionRegion.scene,
                  child: Center(child: _scene(visual)),
                ),
              ],
            ),
          ),
          if (!step.isDecision || _session.hasFeedback) ...[
            const SizedBox(height: 16),
            _nextButton(),
          ],
        ],
      );
    },
  );

  Widget _scene(MissionVisual visual) => MissionScene(
    visual: visual,
    gender: widget.gender,
    stepId: _session.step.id,
    selectedChoice: _session.selectedChoice,
    choices: _session.hasFeedback ? const [] : _session.step.choices,
    onChoose: _session.hasFeedback ? null : _choose,
  );

  Widget _decisionInstruction() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        _session.step.title,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        _session.step.narration,
        style: const TextStyle(fontSize: 17, height: 1.4),
      ),
      const SizedBox(height: 8),
      Text(
        _session.step.id == 'get_down' || _session.step.id == 'protect_head'
            ? 'Tap a pose to choose.'
            : 'Tap a highlighted part of the picture.',
        style: const TextStyle(color: BaseboundColors.muted),
      ),
      _audioControls(),
    ],
  );

  Widget _decisionLayout(MissionVisual visual, BoxConstraints constraints) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.4;
    if (largeText) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _decisionInstruction(),
            const SizedBox(height: 16),
            _scene(visual),
          ],
        ),
      );
    }
    if (constraints.maxWidth > constraints.maxHeight) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: SingleChildScrollView(child: _decisionInstruction())),
          const SizedBox(width: 16),
          Expanded(child: Center(child: _scene(visual))),
        ],
      );
    }
    // Keep the complete scene and every object target visible. Longer voice
    // fallback instructions can scroll independently of the interactive art.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: (constraints.maxHeight - constraints.maxWidth * 1.5 - 12)
              .clamp(64.0, constraints.maxHeight * .35),
          child: SingleChildScrollView(child: _decisionInstruction()),
        ),
        const SizedBox(height: 12),
        Expanded(child: Center(child: _scene(visual))),
      ],
    );
  }

  Widget _feedback() => Semantics(
    liveRegion: true,
    child: SoftPanel(
      color: _session.selectedChoice!.isCorrect
          ? BaseboundColors.greenLight
          : BaseboundColors.coralLight,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BaseboundIcon(
            _session.selectedChoice!.isCorrect
                ? BaseboundIconName.check
                : BaseboundIconName.idea,
            size: 24,
            color: _session.selectedChoice!.isCorrect
                ? BaseboundColors.green
                : BaseboundColors.coral,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _session.feedback!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
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
    );
  }

  String _nextLabel() => switch (_session.step.id) {
    'alarm' => 'Find a place',
    'outdoor_alarm' => 'Choose where to go',
    'destination' || 'outdoor_places' =>
      _session.selectedChoice?.continuesAfterFeedback == true
          ? 'See what happens'
          : _session.selectedChoice?.id == 'more_places'
          ? 'See nearby places'
          : 'Enter the shelter',
    'outdoor_noise' => 'Choose what to do',
    'get_down' => 'Protect my head',
    'protect_head' => 'Stay down',
    'outdoor_recover' => 'Follow the adult',
    'outdoor_sheltered' => 'Tell a trusted adult',
    'contacts' => 'Tell them',
    'communication' => 'Hear the reply',
    'message' => 'Stay here',
    'noise' => 'Keep waiting',
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
              const Text(
                'Practice complete',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * .25,
                child: const Center(
                  child: MissionScene(visual: MissionVisual.recall),
                ),
              ),
              const Text(
                'Move inside. Tell someone. Stay until the all-clear.',
                style: TextStyle(fontSize: 18, height: 1.4),
              ),
              _audioControls(),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: _restart,
        icon: const BaseboundIcon(BaseboundIconName.replay),
        label: const Text('Play again'),
      ),
      TextButton.icon(
        onPressed: () => unawaited(_exit()),
        icon: const BaseboundIcon(BaseboundIconName.home),
        label: const Text('Back to practice choices'),
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

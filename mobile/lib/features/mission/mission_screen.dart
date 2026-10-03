import 'dart:async';

import '../parent/data/family_plan.dart';
import '../parent/data/family_plan_repository.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import 'air_raid_mission.dart';
import 'mission_audio.dart';
import 'mission_scene.dart';
import 'practice_message_conversation.dart';
import 'practice_phone_keypad.dart';

/// An explicitly fictional training session, separate from the help prototype.
class MissionScreen extends StatefulWidget {
  const MissionScreen({
    super.key,
    required this.mode,
    this.audio,
    this.repository,
    this.gender = ChildGender.girl,
  });

  final MissionMode mode;
  final MissionAudio? audio;
  final FamilyPlanRepository? repository;

  final ChildGender gender;

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen>
    with WidgetsBindingObserver {
  late final MissionSession _session = MissionSession(mode: widget.mode);
  late MissionAudio _audio = widget.audio ?? MissionAudio();
  late final _repository = widget.repository ?? FamilyPlanRepository();
  List<TrustedContact>? _phoneContacts;
  bool _enteringPhoneNumber = false;
  bool _phoneLoadFailed = false;
  String _phoneNarration = '';
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
    if (_enteringPhoneNumber) return _phoneNarration;
    if (_session.step.id == 'message') {
      return 'Practice only. Nothing was sent. ${_session.step.narration}';
    }
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
    if (_session.hasFeedback || _session.isComplete || _enteringPhoneNumber) {
      return;
    }
    if (_session.step.id == 'communication' && id == 'message') {
      setState(() => _enteringPhoneNumber = true);
      unawaited(_loadPhoneContacts());
      return;
    }
    setState(() => _session.choose(id));
    unawaited(_narrate());
  }

  Future<void> _loadPhoneContacts() async {
    setState(() {
      _phoneContacts = null;
      _phoneLoadFailed = false;
      _phoneNarration = 'Loading saved numbers.';
    });
    unawaited(_narrate());
    try {
      final plan = await _repository.load();
      if (!mounted || _exiting || !_enteringPhoneNumber) return;
      setState(() {
        _phoneContacts = plan.contacts
            .where((contact) => RegExp(r'[0-9]').hasMatch(contact.phone))
            .toList();
        _phoneNarration = _phoneContacts!.isEmpty
            ? 'No phone number is saved yet. Ask an adult to add one in parent '
                  'setup. You can continue without a number.'
            : 'Type your trusted adult’s phone number. This is practice only. '
                  'No calls or messages are sent.';
      });
    } catch (_) {
      if (!mounted || _exiting || !_enteringPhoneNumber) return;
      setState(() {
        _phoneLoadFailed = true;
        _phoneNarration =
            'Your saved numbers could not be read. '
            'Try loading again, or continue without a number.';
      });
    }
    unawaited(_narrate());
  }

  void _phoneInstructionChanged(String instruction) {
    setState(() => _phoneNarration = instruction);
    unawaited(_narrate());
  }

  void _completePhonePractice() {
    if (!_enteringPhoneNumber || _exiting) return;
    setState(() {
      _enteringPhoneNumber = false;
      _phoneContacts = null;
      _phoneNarration = '';
      _session.choose('message');
      // The pretend message and reply share one screen after number practice.
      _session.advance();
    });
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
    setState(() {
      _session.restart();
      _enteringPhoneNumber = false;
      _phoneContacts = null;
      _phoneNarration = '';
    });
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
          Semantics(
            label: 'Replay audio',
            button: true,
            enabled: _audioReady,
            onTap: _audioReady ? () => unawaited(_narrate()) : null,
            child: ExcludeSemantics(
              child: IconButton(
                onPressed: _audioReady ? () => unawaited(_narrate()) : null,
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
      if (_enteringPhoneNumber) return _phonePracticeLayout();
      final step = _session.step;
      if (step.id == 'message') return _messageLayout();
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
                        if (step.id == 'get_down' && !_session.hasFeedback)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'Drag down, or tap the arrow.',
                              style: TextStyle(color: BaseboundColors.muted),
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

  Widget _phonePracticeLayout() => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_phoneContacts case final contacts?)
          PracticePhoneKeypad(
            contacts: contacts,
            onComplete: _completePhonePractice,
            onInstructionChanged: _phoneInstructionChanged,
          )
        else ...[
          const Text(
            'Type their phone number',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            child: Text(
              _phoneNarration,
              style: const TextStyle(fontSize: 17, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          if (_phoneLoadFailed) ...[
            FilledButton(
              onPressed: () => unawaited(_loadPhoneContacts()),
              child: const Text('Try loading again'),
            ),
            TextButton(
              onPressed: _completePhonePractice,
              child: const Text('Continue without a number'),
            ),
          ] else
            const Center(child: CircularProgressIndicator()),
        ],
        _audioControls(),
      ],
    ),
  );

  Widget _messageLayout() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [const PracticeMessageConversation(), _audioControls()],
          ),
        ),
      ),
      const SizedBox(height: 16),
      _nextButton(),
    ],
  );

  Widget _scene(MissionVisual visual) {
    final scene = MissionScene(
      visual: visual,
      gender: widget.gender,
      stepId: _session.step.id,
      selectedChoice: _session.selectedChoice,
      choices: _session.hasFeedback ? const [] : _session.step.choices,
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
        _session.step.id == 'get_down'
            ? 'Drag down, or tap a highlighted action.'
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

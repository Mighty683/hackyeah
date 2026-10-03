import 'dart:async';

import '../parent/data/family_plan.dart';
import '../parent/data/family_plan_repository.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import 'air_raid_mission.dart';
import '../../audio/practice_audio.dart';
import '../../audio/practice_narration_controller.dart';
import 'mission_scene.dart';
import 'mission_recap_layout.dart';
import 'practice_message_conversation.dart';
import 'mission_phone_practice.dart';
import 'mission_decision_layout.dart';
import 'mission_viewport_layout.dart';

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
  final PracticeAudio? audio;
  final FamilyPlanRepository? repository;

  final ChildGender gender;

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen>
    with WidgetsBindingObserver {
  late final MissionSession _session = MissionSession(mode: widget.mode);
  late final _narration = PracticeNarrationController(
    widget.audio ?? PracticeAudio(),
    recreateAudio: widget.audio == null ? PracticeAudio.new : null,
  );
  late final _repository = widget.repository ?? FamilyPlanRepository();
  List<TrustedContact>? _phoneContacts;
  bool _enteringPhoneNumber = false;
  bool _phoneLoadFailed = false;
  String _phoneNarration = '';
  bool _effectsEnabled = true;
  bool _exiting = false;
  bool _foreground = true;
  int _feedbackRequest = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _narration.addListener(_narrationChanged);
    unawaited(_initializeAudio());
  }

  void _narrationChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _initializeAudio({bool retry = false}) async {
    await _narration.initialize(retry: retry);
    if (!mounted || _exiting) return;
    await _playCurrent();
  }

  String get _spokenText {
    if (_enteringPhoneNumber) return _phoneNarration;
    if (_session.step.id == 'message') {
      return 'Practice only. Nothing was sent. ${_session.step.narration}';
    }
    if (_session.isComplete) {
      return AirRaidPracticeRecap.narration;
    }
    return _session.feedback ?? _session.step.narration;
  }

  String? get _soundCue {
    if (!_effectsEnabled || _enteringPhoneNumber) return null;
    if (_session.isComplete) return 'success';
    final choice = _session.selectedChoice;
    if (choice == null) return _session.step.sound;
    if (choice.continuesAfterFeedback ||
        choice.id == 'more_places' ||
        (_session.step.id == 'communication' && choice.id == 'call')) {
      return 'select';
    }
    if (!choice.isCorrect) return 'retry';
    if (_session.step.id == 'get_down' || _session.step.id == 'protect_head') {
      return 'action';
    }
    return 'success';
  }

  Future<void> _narrate() {
    final sound = _soundCue;
    return _narration.narrate(
      _spokenText,
      sound: sound,
      beforePlayback: sound == 'alarm' || sound == 'all_clear'
          ? () => unawaited(HapticFeedback.lightImpact())
          : null,
    );
  }

  void _toggleEffects() {
    setState(() => _effectsEnabled = !_effectsEnabled);
    // Cancel an in-flight cue immediately, then keep the instruction audible.
    unawaited(_playCurrent());
  }

  bool get _canReplay =>
      !_narration.initializing &&
      !_exiting &&
      (_narration.ready || _soundCue != null);

  void _choose(String id) {
    if (!_session.canChoose ||
        _session.rejectedChoiceIds.contains(id) ||
        _enteringPhoneNumber) {
      return;
    }
    if (_session.step.id == 'sms' && id == 'message') {
      ++_feedbackRequest;
      setState(() => _enteringPhoneNumber = true);
      unawaited(_loadPhoneContacts());
      return;
    }
    setState(() => _session.choose(id));
    unawaited(_respondToChoice());
  }

  Future<void> _playCurrent() => _session.hasFeedback && !_enteringPhoneNumber
      ? _respondToChoice()
      : _narrate();

  Future<void> _respondToChoice() async {
    if (_narration.initializing) return;
    final request = ++_feedbackRequest;
    final choice = _session.selectedChoice;
    // Keep feedback readable even if the voice is unavailable or very short.
    final advances =
        choice?.isCorrect == true || choice?.continuesAfterFeedback == true;
    final readingTime = advances
        ? Future<void>.delayed(const Duration(seconds: 3))
        : Future<void>.value();
    await _narrate();
    await readingTime;
    if (!mounted ||
        _exiting ||
        !_foreground ||
        request != _feedbackRequest ||
        !advances) {
      return;
    }
    _next();
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
    ++_feedbackRequest;
    setState(() {
      _session.advance();
    });
    unawaited(_narrate());
  }

  void _restart() {
    ++_feedbackRequest;
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
    ++_feedbackRequest;
    await _narration.close();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    ++_feedbackRequest;
    _narration.setForeground(_foreground);
    if (_foreground) {
      unawaited(_playCurrent());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ++_feedbackRequest;
    _narration.removeListener(_narrationChanged);
    _narration.dispose();
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
            onPressed: _narration.initializing || _exiting
                ? null
                : _toggleEffects,
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
            onTap: _canReplay ? () => unawaited(_playCurrent()) : null,
            child: ExcludeSemantics(
              child: IconButton(
                onPressed: _canReplay ? () => unawaited(_playCurrent()) : null,
                tooltip: 'Replay audio',
                icon: BaseboundIcon(
                  BaseboundIconName.speaker,
                  size: 24,
                  color: _narration.speaking ? BaseboundColors.blue : null,
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
      if (_narration.initializing)
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'Getting the voice ready…',
            style: TextStyle(color: BaseboundColors.muted),
          ),
        ),
      if (!_narration.ready && !_narration.initializing)
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
                        kIsWeb
                            ? 'Web demo has no narration. Ask an adult to read each step with you.'
                            : 'The voice is unavailable. Ask an adult to read each step with you.',
                        style: TextStyle(fontSize: 16, height: 1.4),
                      ),
                    ),
                  ],
                ),
                if (!kIsWeb)
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
      if (step.id == 'recall') return _recallLayout();
      final visual = _session.selectedChoice?.isCorrect == true
          ? _session.selectedChoice?.visual ?? step.visual
          : step.visual;
      if (step.isDecision) {
        return _decisionLayout(visual);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CustomMultiChildLayout(
              delegate: MissionViewportLayout(),
              children: [
                LayoutId(
                  id: MissionRegion.instruction,
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
                  id: MissionRegion.actions,
                  child: SingleChildScrollView(
                    child: _session.hasFeedback
                        ? _feedback()
                        : const SizedBox.shrink(),
                  ),
                ),
                LayoutId(
                  id: MissionRegion.scene,
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

  Widget _phonePracticeLayout() => MissionPhonePractice(
    contacts: _phoneContacts,
    narration: _phoneNarration,
    loadFailed: _phoneLoadFailed,
    onComplete: _completePhonePractice,
    onInstructionChanged: _phoneInstructionChanged,
    onRetry: () => unawaited(_loadPhoneContacts()),
    audioControls: _audioControls(),
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

  Widget _scene(MissionVisual visual) => MissionScene(
    visual: visual,
    gender: widget.gender,
    stepId: _session.step.id,
    selectedChoice: _session.selectedChoice,
    choices:
        visual == _session.step.visual &&
            !((visual == MissionVisual.getDown ||
                    visual == MissionVisual.protectHead) &&
                _session.selectedChoice?.isCorrect == true)
        ? _session.step.choices
        : const [],
    rejectedChoiceIds: _session.rejectedChoiceIds,
    onChoose: _session.canChoose ? _choose : null,
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
            : 'Tap a highlighted object to choose.',
        style: const TextStyle(color: BaseboundColors.muted),
      ),
      _audioControls(),
    ],
  );

  Widget _decisionLayout(MissionVisual visual) => MissionDecisionLayout(
    instruction: _decisionInstruction(),
    scene: _scene(visual),
    feedback: _session.hasFeedback ? _feedback() : const SizedBox.shrink(),
    hasFeedback: _session.hasFeedback,
  );

  Widget _feedback() => Semantics(
    liveRegion: true,
    child: SoftPanel(
      color: _session.selectedChoice!.isCorrect
          ? BaseboundColors.greenLight
          : BaseboundColors.coralLight,
      padding: const EdgeInsets.all(12),
      child: BaseboundGuide(
        message: _session.feedback!,
        positive: _session.selectedChoice!.isCorrect,
      ),
    ),
  );

  Widget _nextButton() {
    return FilledButton.icon(
      onPressed: _next,
      icon: const BaseboundIcon(BaseboundIconName.next),
      label: Text(_nextLabel()),
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
    'communication' => 'Send an SMS',
    'sms' => 'Hear the reply',
    'message' => 'Stay here',
    'noise' => 'Keep waiting',
    'quiet' => 'Wait for the all-clear',
    'all_clear' => 'Remember the steps',
    'recall' => 'Finish practice',
    _ => 'Next step',
  };

  Widget _recallLayout() => MissionRecapLayout(
    title: _session.step.title,
    audioControls: _audioControls(),
    actions: [_nextButton()],
  );

  Widget _completionLayout() => MissionRecapLayout(
    title: 'Practice complete',
    audioControls: _audioControls(),
    actions: [
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

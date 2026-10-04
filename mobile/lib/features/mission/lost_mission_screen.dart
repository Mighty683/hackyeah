import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../ui/unavailable_audio_tooltip.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import '../../game/maps/demo_map.dart';
import '../landmarks/data/landmark.dart';
import 'data/lost_practice_context.dart';
import 'lost_meeting_point_map.dart';
import 'lost_mission.dart';
import 'lost_mission_scene.dart';
import 'mission_decision_layout.dart';
import 'mission_recap_layout.dart';
import '../../audio/practice_audio.dart';
import '../../audio/practice_narration_controller.dart';
import 'practice_recap.dart';
import 'practice_feedback.dart';
import 'practice_step_header.dart';

/// Offline decision practice; calls and safety confirmation are pretend.
class LostMissionScreen extends StatefulWidget {
  const LostMissionScreen({
    super.key,
    required this.variant,
    required this.practiceContext,
    this.audio,
    this.map,
    this.mapLandmarks = const [],
    this.photoDirectory = '',
  });

  final LostPracticeVariant variant;
  final LostPracticeContext practiceContext;
  final PracticeAudio? audio;
  final DemoMap? map;
  final List<Landmark> mapLandmarks;
  final String photoDirectory;

  @override
  State<LostMissionScreen> createState() => _LostMissionScreenState();
}

class _LostMissionScreenState extends State<LostMissionScreen>
    with WidgetsBindingObserver {
  late final _session = LostMissionSession(
    variant: widget.variant,
    context: widget.practiceContext,
  );
  late final _narration = PracticeNarrationController(
    widget.audio ?? PracticeAudio(),
    recreateAudio: widget.audio == null ? PracticeAudio.new : null,
  );
  final _scroll = ScrollController();
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
    ++_feedbackRequest;
    await _narration.initialize(retry: retry);
    if (!mounted || _exiting) return;
    await _playCurrent();
  }

  String get _spokenText {
    if (_session.isComplete) return LostPracticeRecap.narration;
    if (_session.hasFeedback) return _session.feedback!;
    final step = _session.step;
    if (!step.isDecision) return step.narration;
    final choices = step.choices.map((choice) => choice.label).join('. ');
    return '${step.narration} Możesz wybrać: $choices.';
  }

  Future<void> _narrate() =>
      _narration.ready ? _narration.narrate(_spokenText) : Future<void>.value();

  Future<void> _playCurrent() =>
      _session.hasFeedback ? _respondToChoice() : _narrate();

  Future<void> _respondToChoice() async {
    if (_narration.initializing) return;
    final request = ++_feedbackRequest;
    final advances = _session.selectedChoice?.isCorrect == true;
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

  void _choose(String id) {
    if (_exiting ||
        !_session.canChoose ||
        _session.rejectedChoiceIds.contains(id)) {
      return;
    }
    setState(() => _session.choose(id));
    unawaited(_playCurrent());
  }

  void _next() {
    if (_exiting || _session.isComplete) return;
    ++_feedbackRequest;
    setState(_session.advance);
    _returnToTop();
    unawaited(_narrate());
  }

  void _restart() {
    if (_exiting) return;
    ++_feedbackRequest;
    setState(_session.restart);
    _returnToTop();
    unawaited(_narrate());
  }

  void _mapHelp() {
    if (_exiting || !_session.canChoose) return;
    ++_feedbackRequest;
    setState(_session.useMapHelp);
    _returnToTop();
    unawaited(_narrate());
  }

  void _returnToTop() {
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<void> _exit() async {
    if (_exiting) return;
    ++_feedbackRequest;
    setState(() => _exiting = true);
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
    ++_feedbackRequest;
    WidgetsBinding.instance.removeObserver(this);
    _narration.removeListener(_narrationChanged);
    _narration.dispose();
    _scroll.dispose();
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
          tooltip: 'Opuść ćwiczenie',
          onPressed: _exiting ? null : () => unawaited(_exit()),
        ),
        title: const Text(
          'Tylko ćwiczenie · 7+',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 18),
        ),
        actions: [_replayButton(), const SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: IllustratedBackdrop(
          warm: true,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: _session.isComplete ? _completion() : _practice(),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _replayButton() => UnavailableAudioTooltip(
    unavailable: kIsWeb && !_narration.initializing && !_narration.ready,
    child: Semantics(
      label: 'Posłuchaj ponownie',
      button: true,
      enabled: _narration.ready && !_exiting,
      onTap: _narration.ready && !_exiting
          ? () => unawaited(_playCurrent())
          : null,
      child: ExcludeSemantics(
        child: IconButton(
          onPressed: _narration.ready && !_exiting
              ? () => unawaited(_playCurrent())
              : null,
          tooltip: 'Posłuchaj ponownie',
          icon: BaseboundIcon(
            BaseboundIconName.speaker,
            color: _narration.speaking ? BaseboundColors.blue : null,
          ),
        ),
      ),
    ),
  );

  Widget _practice() {
    if (_session.step.id == 'recall') return _recall();
    if (_session.step.isDecision) {
      return MissionDecisionLayout(
        instruction: _header(),
        scene: _decisionScene(),
        feedback: _session.hasFeedback ? _feedback() : const SizedBox.shrink(),
        hasFeedback: _session.hasFeedback,
        scrollController: _scroll,
      );
    }
    return _practiceSteps();
  }

  Widget _header() => PracticeStepHeader(
    title: _session.step.title,
    titleKey: const ValueKey('lost-step-title'),
    narration: _session.step.id == 'stop' ? null : _session.step.narration,
    hint: _session.step.isDecision && _session.step.id != 'map_meeting_point'
        ? 'Dotknij podświetlonego obiektu, aby go wybrać.'
        : null,
    audioControls: _audioControls(),
    notice: _practiceNotice(),
  );

  Widget _decisionScene() {
    if (_session.step.id == 'map_meeting_point') {
      return IgnorePointer(
        ignoring: _exiting || !_session.canChoose,
        child: LostMeetingPointMap(
          map: widget.map,
          target: widget.practiceContext.photoMeetingPoint!,
          photoDirectory: widget.photoDirectory,
          landmarks: widget.mapLandmarks
              .where(
                (place) => _session.step.choices.any(
                  (choice) => choice.id == place.id,
                ),
              )
              .toList(),
          onSelected: _choose,
          onHelp: _mapHelp,
        ),
      );
    }
    return LostMissionScene(
      step: _session.step,
      practiceContext: widget.practiceContext,
      selectedChoice: _session.selectedChoice,
      rejectedChoiceIds: _session.rejectedChoiceIds,
      onChoice: _exiting || !_session.canChoose ? null : _choose,
    );
  }

  Widget _practiceSteps() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: SingleChildScrollView(
          controller: _scroll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              const SizedBox(height: 16),
              LostMissionScene(
                step: _session.step,
                practiceContext: widget.practiceContext,
                selectedChoice: _session.selectedChoice,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      _primaryAction(),
    ],
  );

  Widget _practiceNotice() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Ćwiczenie bez oceny specjalisty · nie do prawdziwych zagrożeń',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: BaseboundColors.muted),
      ),
      if (widget.practiceContext.contacts.any((contact) => contact.isFictional))
        const Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            'Część kontaktów jest fikcyjna.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: BaseboundColors.muted),
          ),
        ),
    ],
  );

  Widget _feedback() => PracticeFeedback(
    message: _session.feedback!,
    positive: _session.selectedChoice!.isCorrect,
  );

  Widget _primaryAction() {
    final expectedStepId = _session.step.id;
    return FilledButton.icon(
      key: const ValueKey('lost-primary-action'),
      onPressed: _exiting
          ? null
          : () {
              if (_exiting ||
                  _session.isComplete ||
                  _session.step.id != expectedStepId) {
                return;
              }
              _next();
            },
      icon: BaseboundIcon(
        _session.step.id == 'confirm_safe'
            ? BaseboundIconName.check
            : BaseboundIconName.next,
      ),
      label: Text(_session.step.actionLabel, textAlign: TextAlign.center),
    );
  }

  Widget _audioControls() {
    if (_narration.initializing) {
      return const Padding(
        padding: EdgeInsets.only(top: 10),
        child: Text('Przygotowywanie głosu…', textAlign: TextAlign.center),
      );
    }
    if (kIsWeb || _narration.ready) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SoftPanel(
        color: BaseboundColors.cream,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              kIsWeb
                  ? 'Głos w przeglądarce jest niedostępny. Spróbuj włączyć głos lub czytaj z dorosłym.'
                  : 'Głos jest niedostępny. Poproś dorosłego o przeczytanie kolejnych kroków.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17),
            ),
            TextButton.icon(
              onPressed: _exiting
                  ? null
                  : () => unawaited(_initializeAudio(retry: true)),
              icon: const BaseboundIcon(BaseboundIconName.replay),
              label: const Text('Spróbuj włączyć głos ponownie'),
              style: TextButton.styleFrom(minimumSize: const Size(64, 52)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryContent(String title) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _practiceNotice(),
      const SizedBox(height: 12),
      PracticeRecap(
        title: title,
        titleKey: const ValueKey('lost-step-title'),
        praise: LostPracticeRecap.praise,
        points: LostPracticeRecap.points,
        pointIcons: const [
          BaseboundIconName.stay,
          BaseboundIconName.phone,
          BaseboundIconName.family,
        ],
      ),
    ],
  );

  Widget get _recapNotice => const Text(
    LostPracticeRecap.notice,
    style: TextStyle(fontSize: 16, color: BaseboundColors.muted),
  );

  Widget _recall() => MissionRecapLayout(
    audioControls: _audioControls(),
    scrollController: _scroll,
    recapContent: _summaryContent(_session.step.title),
    notice: _recapNotice,
    actions: [_primaryAction()],
  );

  Widget _completion() => MissionRecapLayout(
    audioControls: _audioControls(),
    scrollController: _scroll,
    recapContent: _summaryContent('Ćwiczenie ukończone'),
    notice: _recapNotice,
    actions: [
      FilledButton.icon(
        key: const ValueKey('lost-restart'),
        onPressed: _exiting ? null : _restart,
        icon: const BaseboundIcon(BaseboundIconName.replay),
        label: const Text('Ćwicz ponownie'),
      ),
      TextButton.icon(
        onPressed: _exiting ? null : () => unawaited(_exit()),
        icon: const BaseboundIcon(BaseboundIconName.home),
        label: const Text('Wróć do wyboru ćwiczeń'),
      ),
    ],
  );
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import '../../widgets/basebound_mascot.dart';
import '../../game/maps/demo_map.dart';
import '../landmarks/data/landmark.dart';
import 'data/lost_practice_context.dart';
import 'lost_meeting_point_map.dart';
import 'lost_mission.dart';
import 'lost_mission_scene.dart';
import 'mission_audio.dart';
import 'practice_recap.dart';

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
  final MissionAudio? audio;
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
  late MissionAudio _audio = widget.audio ?? MissionAudio();
  final _scroll = ScrollController();
  bool _audioReady = false;
  bool _initializingAudio = true;
  bool _speaking = false;
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
    if (ready) await _narrate();
  }

  String get _spokenText {
    if (_session.isComplete) return LostPracticeRecap.narration;
    if (_session.hasFeedback) return _session.feedback!;
    final step = _session.step;
    if (!step.isDecision) return step.narration;
    final choices = step.choices.map((choice) => choice.label).join('. ');
    return '${step.narration} Your choices are: $choices.';
  }

  Future<void> _narrate() async {
    if (!_audioReady || !_foreground || _exiting) return;
    final request = ++_audioRequest;
    final text = _spokenText;
    setState(() => _speaking = true);
    try {
      await _audio.stop();
      if (!mounted || !_foreground || _exiting || request != _audioRequest) {
        return;
      }
      await _audio.narrate(text);
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
    if (_exiting || _session.hasFeedback || _session.isComplete) return;
    setState(() => _session.choose(id));
    _returnToTop();
    unawaited(_narrate());
  }

  void _next() {
    if (_exiting || _session.isComplete) return;
    setState(() {
      if (_session.selectedChoice?.isCorrect == false) {
        _session.retry();
      } else {
        _session.advance();
      }
    });
    _returnToTop();
    unawaited(_narrate());
  }

  void _restart() {
    if (_exiting) return;
    setState(_session.restart);
    _returnToTop();
    unawaited(_narrate());
  }

  void _mapHelp() {
    if (_exiting) return;
    setState(_session.useMapHelp);
    _returnToTop();
    unawaited(_narrate());
  }

  void _returnToTop() {
    if (_scroll.hasClients) _scroll.jumpTo(0);
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
        leading: BaseboundBackButton(
          enabled: !_exiting,
          tooltip: 'Leave practice',
          onPressed: _exiting ? null : () => unawaited(_exit()),
        ),
        title: const Text(
          'Practice only · 7+',
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
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: _session.isComplete ? _completion() : _practice(),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _replayButton() => Semantics(
    label: 'Replay audio',
    button: true,
    enabled: _audioReady && !_exiting,
    onTap: _audioReady && !_exiting ? () => unawaited(_narrate()) : null,
    child: ExcludeSemantics(
      child: IconButton(
        onPressed: _audioReady && !_exiting
            ? () => unawaited(_narrate())
            : null,
        tooltip: 'Replay audio',
        icon: BaseboundIcon(
          BaseboundIconName.speaker,
          color: _speaking ? BaseboundColors.blue : null,
        ),
      ),
    ),
  );

  Widget _practice() =>
      _session.step.id == 'recall' ? _recall() : _practiceSteps();

  Widget _practiceSteps() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: SingleChildScrollView(
          controller: _scroll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _practiceNotice(),
              _audioControls(),
              const SizedBox(height: 12),
              Text(
                _session.step.title,
                key: const ValueKey('lost-step-title'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              _instruction(),
              const SizedBox(height: 12),
              if (_session.step.id == 'map_meeting_point' &&
                  !_session.hasFeedback)
                LostMeetingPointMap(
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
                )
              else if (_session.step.isDecision && !_session.hasFeedback)
                LostMissionScene(
                  step: _session.step,
                  practiceContext: widget.practiceContext,
                  onChoice: _exiting ? null : _choose,
                )
              else
                SizedBox(
                  height: _sceneHeight,
                  child: LostMissionScene(
                    step: _session.step,
                    practiceContext: widget.practiceContext,
                    selectedChoice: _session.selectedChoice,
                  ),
                ),
              if (_session.hasFeedback) _feedback(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      if (!_session.step.isDecision || _session.hasFeedback) ...[
        const SizedBox(height: 10),
        _primaryAction(),
      ],
    ],
  );

  double get _sceneHeight =>
      (MediaQuery.sizeOf(context).height * .24).clamp(130.0, 220.0);

  Widget _practiceNotice() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Unreviewed training · not for real emergencies',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: BaseboundColors.muted),
      ),
      if (widget.practiceContext.fictionalMeetingPoint)
        const Text(
          'Demo meeting place.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: BaseboundColors.muted),
        ),
      if (widget.practiceContext.contacts.any((contact) => contact.isFictional))
        const Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            'Some contacts are pretend.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: BaseboundColors.muted),
          ),
        ),
    ],
  );

  Widget _instruction() => SoftPanel(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Text(
      _session.step.narration,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
    ),
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

  Widget _primaryAction() {
    final retry = _session.selectedChoice?.isCorrect == false;
    return FilledButton.icon(
      key: const ValueKey('lost-primary-action'),
      onPressed: _exiting ? null : _next,
      icon: BaseboundIcon(
        retry
            ? BaseboundIconName.replay
            : _session.step.id == 'confirm_safe'
            ? BaseboundIconName.check
            : BaseboundIconName.next,
      ),
      label: Text(
        retry
            ? 'Try again'
            : _session.hasFeedback
            ? 'Next step'
            : _session.step.actionLabel,
        textAlign: TextAlign.center,
      ),
      style: FilledButton.styleFrom(minimumSize: const Size(64, 64)),
    );
  }

  Widget _audioControls() {
    if (_initializingAudio) {
      return const Padding(
        padding: EdgeInsets.only(top: 10),
        child: Text('Getting the voice ready…', textAlign: TextAlign.center),
      );
    }
    if (_audioReady) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SoftPanel(
        color: BaseboundColors.cream,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'The voice is unavailable. Ask an adult to read each step with you.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17),
            ),
            TextButton.icon(
              onPressed: _exiting
                  ? null
                  : () => unawaited(_initializeAudio(retry: true)),
              icon: const BaseboundIcon(BaseboundIconName.replay),
              label: const Text('Try the voice again'),
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
      ),
      const Text(
        LostPracticeRecap.notice,
        style: TextStyle(fontSize: 16, color: BaseboundColors.muted),
      ),
      _audioControls(),
    ],
  );

  Widget _recall() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: SingleChildScrollView(
          controller: _scroll,
          child: _summaryContent(_session.step.title),
        ),
      ),
      const SizedBox(height: 16),
      _primaryAction(),
    ],
  );

  Widget _completion() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: SingleChildScrollView(
          controller: _scroll,
          child: _summaryContent('Practice complete'),
        ),
      ),
      const SizedBox(height: 16),
      FilledButton.icon(
        key: const ValueKey('lost-restart'),
        onPressed: _exiting ? null : _restart,
        icon: const BaseboundIcon(BaseboundIconName.replay),
        label: const Text('Play again'),
        style: FilledButton.styleFrom(minimumSize: const Size(64, 64)),
      ),
      TextButton.icon(
        onPressed: _exiting ? null : () => unawaited(_exit()),
        icon: const BaseboundIcon(BaseboundIconName.home),
        label: const Text('Back to practice choices'),
        style: TextButton.styleFrom(minimumSize: const Size(64, 56)),
      ),
    ],
  );
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import '../../widgets/basebound_mascot.dart';
import '../../game/maps/demo_map.dart';
import '../landmarks/data/landmark.dart';
import '../landmarks/data/landmark_repository.dart';
import '../landmarks/widgets/landmark_photo.dart';
import '../parent/data/family_plan.dart';
import '../parent/data/family_plan_repository.dart';
import '../parent/parent_screen.dart';
import 'data/lost_practice_context.dart';
import 'lost_practice_loader.dart';
import 'lost_landmarks.dart';
import 'lost_mission.dart';
import 'lost_mission_screen.dart';
import '../../audio/practice_audio.dart';

/// Loads a fresh display-only family snapshot without changing saved records.
class LostMissionLauncher extends StatefulWidget {
  const LostMissionLauncher({
    super.key,
    this.child = const ChildProfile(),
    this.repository,
    this.landmarkRepository,
    this.audio,
  });

  final ChildProfile child;
  final FamilyPlanRepository? repository;
  final LandmarkRepository? landmarkRepository;
  final PracticeAudio? audio;

  @override
  State<LostMissionLauncher> createState() => _LostMissionLauncherState();
}

class _LostMissionLauncherState extends State<LostMissionLauncher>
    with WidgetsBindingObserver {
  late final _repository = widget.repository ?? FamilyPlanRepository();
  late final _landmarkRepository =
      widget.landmarkRepository ?? LandmarkRepository();
  late final _audio = widget.audio ?? PracticeAudio();
  LostPracticeContext? _practiceContext;
  LostPracticeVariant? _variant;
  bool _loading = true;
  bool _loadFailed = false;
  bool _audioAvailable = true;
  bool _opening = false;
  bool _foreground = true;
  bool _setupOpen = false;
  bool _needsMeetingPoint = false;
  FamilyPlan? _savedPlan;
  DemoMap? _map;
  List<Landmark> _mapLandmarks = [];
  String _photoDirectory = '';
  int _audioRevision = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final snapshot = await LostPracticeLoader(
        familyRepository: _repository,
        landmarkRepository: _landmarkRepository,
        child: widget.child,
      ).load();
      if (!mounted) return;
      setState(() {
        _savedPlan = snapshot.savedPlan;
        _practiceContext = snapshot.context;
        _map = snapshot.map;
        _mapLandmarks = snapshot.mapLandmarks;
        _photoDirectory = snapshot.photoDirectory;
        _needsMeetingPoint = snapshot.needsMeetingPoint;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadFailed = true;
        _loading = false;
      });
    }
    unawaited(_speak());
  }

  String get _instruction {
    if (_loadFailed) {
      return 'Your saved details could not be read. '
          'Try again, or use a pretend family for practice.';
    }
    if (_needsMeetingPoint) {
      return 'Ask an adult to choose your meeting place and photo.';
    }
    final detail = _practiceContext?.usesFictionalDetails == true
        ? 'Some family details are pretend. '
        : '';
    return 'This is pretend practice. No calls or messages are sent. '
        '$detail'
        'Your practice meeting point is ${_practiceContext?.meetingPointLabel}. '
        'Choose a scene. The meeting point is nearby, or out of sight.';
  }

  Future<void> _speak() async {
    if (_loading || _opening || _setupOpen || !_foreground) return;
    final revision = ++_audioRevision;
    try {
      final available = await _audio.initialize();
      if (!mounted ||
          _opening ||
          _setupOpen ||
          !_foreground ||
          revision != _audioRevision) {
        return;
      }
      setState(() => _audioAvailable = available);
      if (available) await _audio.narrate(_instruction);
    } catch (_) {
      if (mounted && revision == _audioRevision) {
        setState(() => _audioAvailable = false);
      }
    }
  }

  void _useFictionalFamily() {
    setState(() {
      _practiceContext = _loadFailed || _savedPlan == null
          ? LostPracticeContext.fictional(child: widget.child)
          : LostPracticeContext.fromFamilyPlan(
              _savedPlan!.copyWith(clearPracticeMeetingPoint: true),
              fallbackChild: widget.child,
            );
      _loadFailed = false;
      _needsMeetingPoint = false;
    });
    unawaited(_speak());
  }

  Future<void> _openParentSetup() async {
    if (_setupOpen) return;
    _setupOpen = true;
    ++_audioRevision;
    await _audio.stop();
    if (!mounted) return;
    await Navigator.of(context)
        .push<void>(MaterialPageRoute(builder: (_) => const ParentScreen()));
    _setupOpen = false;
    if (mounted) await _load();
  }

  Future<void> _openVariant(LostPracticeVariant variant) async {
    if (_opening || _practiceContext == null) return;
    setState(() => _opening = true);
    ++_audioRevision;
    await _audio.dispose();
    if (!mounted) return;
    // Keep one route so leaving practice returns directly to the scenario list.
    setState(() => _variant = variant);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_opening) return;
    if (_foreground) {
      unawaited(_speak());
    } else {
      ++_audioRevision;
      unawaited(_audio.stop());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ++_audioRevision;
    unawaited(_audio.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_variant case final variant?) {
      return LostMissionScreen(
        variant: variant,
        practiceContext: _practiceContext!,
        map: _map,
        mapLandmarks: _mapLandmarks,
        photoDirectory: _photoDirectory,
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context) ? const BaseboundBackButton() : null,
        title: const Text('Lost practice · 7+'),
      ),
      body: IllustratedBackdrop(
        warm: true,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: _content(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content() {
    if (_loading) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BaseboundMascot(size: 100, pose: DinoPose.listen),
          SizedBox(height: 20),
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Loading your practice family'),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Pretend practice. No calls or messages.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        if (_loadFailed)
          ..._errorContent()
        else if (_needsMeetingPoint)
          ..._missingPointContent()
        else
          ..._variantContent(),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _opening ? null : _speak,
          icon: const BaseboundIcon(BaseboundIconName.speaker),
          label: const Text('Replay audio'),
        ),
        if (!_audioAvailable) ...[
          const SizedBox(height: 12),
          const Text(
            'Voice is unavailable. Ask an adult to help. '
            'An offline English voice is needed.',
          ),
          TextButton(
            onPressed: _opening ? null : _speak,
            child: const Text('Try voice again'),
          ),
        ],
      ],
    );
  }

  List<Widget> _errorContent() => [
    const BaseboundMascot(size: 100, pose: DinoPose.calm),
    const SizedBox(height: 12),
    const Text(
      'Could not read saved family details.',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
    ),
    const SizedBox(height: 20),
    FilledButton(onPressed: _load, child: const Text('Try again')),
    const SizedBox(height: 12),
    OutlinedButton(
      onPressed: _useFictionalFamily,
      child: const Text('Use pretend family'),
    ),
  ];

  List<Widget> _variantContent() {
    final practice = _practiceContext!;
    return [
      if (practice.photoMeetingPoint case final place?)
        LandmarkPhoto(
          fit: BoxFit.contain,
          path: place.photoPath,
          label: place.label,
        )
      else
        LostLandmarkIllustration(presetId: practice.meetingPoint.presetId),
      const SizedBox(height: 12),
      Text(
        'Practice meeting point: ${practice.meetingPointLabel}',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
      ),
      if (practice.contacts.any((contact) => contact.isFictional)) ...[
        const SizedBox(height: 8),
        const Text('Some contacts are pretend.', textAlign: TextAlign.center),
      ],
      const SizedBox(height: 24),
      const Text(
        'Choose your practice scene',
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: _opening
            ? null
            : () => _openVariant(LostPracticeVariant.meetingPointNearby),
        icon: const BaseboundIcon(BaseboundIconName.pin),
        label: const Text('Meeting point nearby'),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: _opening
            ? null
            : () => _openVariant(LostPracticeVariant.meetingPointUnavailable),
        icon: const BaseboundIcon(BaseboundIconName.lost),
        label: const Text('Meeting point out of sight'),
      ),
    ];
  }

  List<Widget> _missingPointContent() => [
    const SizedBox(height: 12),
    Text(
      _practiceContext?.meetingPointUnavailable == true
          ? 'Your meeting place or photo is unavailable.'
          : 'Ask an adult to choose your meeting place.',
      textAlign: TextAlign.center,
    ),
    const SizedBox(height: 16),
    FilledButton(
      onPressed: _openParentSetup,
      child: const Text('Parent setup'),
    ),
    const SizedBox(height: 12),
    OutlinedButton(onPressed: _load, child: const Text('Try again')),
  ];
}

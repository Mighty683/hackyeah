import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import '../../widgets/basebound_mascot.dart';
import '../mission/mission_audio.dart';
import 'data/landmark.dart';
import 'landmark_practice.dart';
import 'widgets/landmark_map.dart';
import 'widgets/landmark_photo.dart';

class LandmarkPracticeScreen extends StatefulWidget {
  const LandmarkPracticeScreen({
    required this.landmarks,
    required this.photoDirectory,
    super.key,
  });
  final List<Landmark> landmarks;
  final String photoDirectory;

  @override
  State<LandmarkPracticeScreen> createState() => _LandmarkPracticeScreenState();
}

class _LandmarkPracticeScreenState extends State<LandmarkPracticeScreen>
    with WidgetsBindingObserver {
  final _audio = MissionAudio();
  late LandmarkQuestion _question = LandmarkQuestion.pick(widget.landmarks);
  bool _correct = false;
  bool _tried = false;
  bool _voiceAvailable = true;
  int _voiceRevision = 0;

  String get _instruction => _correct
      ? 'You remembered! ${_question.target.name} is here on the map.'
      : _tried
      ? 'That is a different place. Look at the photo again.'
      : 'Where is ${_question.target.name}? Look at the photo. Choose its pin on the map.';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _speak();
  }

  Future<void> _speak() async {
    final revision = ++_voiceRevision;
    try {
      final available = await _audio.initialize();
      if (!mounted || revision != _voiceRevision) return;
      setState(() => _voiceAvailable = available);
      if (available) await _audio.narrate(_instruction);
    } catch (_) {
      if (mounted && revision == _voiceRevision) {
        setState(() => _voiceAvailable = false);
      }
    }
  }

  void _choose(Landmark landmark) {
    if (_correct) return;
    setState(() {
      _tried = true;
      _correct = _question.isCorrect(landmark);
    });
    _speak();
  }

  void _next() {
    setState(() {
      _question = LandmarkQuestion.pick(
        widget.landmarks,
        previousId: _question.target.id,
      );
      _correct = false;
      _tried = false;
    });
    _speak();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _speak();
    } else {
      _voiceRevision++;
      _audio.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _voiceRevision++;
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Landmark practice'),
      actions: [
        IconButton(
          onPressed: _speak,
          tooltip: 'Replay audio',
          icon: const BaseboundIcon(BaseboundIconName.speaker),
        ),
      ],
    ),
    body: SafeArea(
      child: IllustratedBackdrop(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_tried)
                    Semantics(
                      liveRegion: true,
                      child: BaseboundGuide(
                        message: _correct
                            ? 'You remembered! This place is here.'
                            : 'Another place. Look at the photo again.',
                        positive: _correct,
                        pose: _correct ? DinoPose.celebrate : DinoPose.think,
                      ),
                    )
                  else
                    const BaseboundGuide(
                      message: 'Where is this place?',
                      pose: DinoPose.think,
                    ),
                  SoftPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LandmarkPhoto(
                          path:
                              '${widget.photoDirectory}/${_question.target.photoName}',
                          label: _question.target.name,
                          height: 160,
                        ),
                        const SizedBox(height: 12),
                        if (_question.target.isDemo)
                          const Text('Fictional demo photo'),
                        Text(
                          _question.target.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  LandmarkMap(
                    landmarks: _question.choices,
                    photoDirectory: widget.photoDirectory,
                    selectedId: _correct ? _question.target.id : null,
                    hidePhotos: !_correct,
                    onSelected: _choose,
                  ),
                  const SizedBox(height: 16),
                  if (!_correct)
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (
                          var index = 0;
                          index < _question.choices.length;
                          index++
                        )
                          OutlinedButton(
                            onPressed: () => _choose(_question.choices[index]),
                            child: Text('Pin ${index + 1}'),
                          ),
                      ],
                    ),
                  if (_correct)
                    FilledButton.icon(
                      onPressed: _next,
                      icon: const BaseboundIcon(
                        BaseboundIconName.next,
                        color: Colors.white,
                      ),
                      label: const Text('Try another place'),
                    ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('See our landmarks'),
                  ),
                  if (!_voiceAvailable)
                    const SoftPanel(
                      child: Text(
                        'Voice is unavailable. Ask an adult to help.',
                      ),
                    ),
                  const SizedBox(height: 8),
                  const Text(
                    'Practice at home. These pins are not walking directions.',
                    style: TextStyle(color: BaseboundColors.muted),
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

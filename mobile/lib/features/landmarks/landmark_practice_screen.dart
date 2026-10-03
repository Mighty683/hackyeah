import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: _practiceContent(context),
          ),
        ),
      ),
    ),
  );

  Widget _practiceContent(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Where is this place?',
        style: Theme.of(context).textTheme.headlineMedium
            ?.copyWith(fontSize: 28),
      ),
      const SizedBox(height: 8),
      Text(
        _correct
            ? '${_question.target.name} is here on the map.'
            : 'Look at the photo. Choose its pin on the map.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(height: 24),
      _photo(context),
      const SizedBox(height: 24),
      LandmarkMap(
        landmarks: _question.choices,
        photoDirectory: widget.photoDirectory,
        selectedId: _correct ? _question.target.id : null,
        hidePhotos: !_correct,
        onSelected: _choose,
      ),
      const SizedBox(height: 16),
      if (_tried) ...[_feedback(context), const SizedBox(height: 16)],
      if (!_correct) _pinChoices(context),
      if (_correct)
        FilledButton.icon(
          onPressed: _next,
          icon: const BaseboundIcon(
            BaseboundIconName.next,
            color: Colors.white,
          ),
          label: const Text('Try another place'),
        ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('See our landmarks'),
      ),
      if (!_voiceAvailable) ...[
        const SizedBox(height: 8),
        const Text(
          'Voice is unavailable. Ask an adult to help.',
          style: TextStyle(color: BaseboundColors.muted),
        ),
      ],
      const SizedBox(height: 16),
      const Text(
        'Practice at home. These pins are not walking directions.',
        style: TextStyle(color: BaseboundColors.muted),
      ),
    ],
  );

  Widget _photo(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      LandmarkPhoto(
        path: '${widget.photoDirectory}/${_question.target.photoName}',
        label: _question.target.name,
        height: 192,
      ),
      const SizedBox(height: 12),
      Text(
        _question.target.name,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      if (_question.target.isDemo) ...[
        const SizedBox(height: 8),
        const Text(
          'Fictional demo photo',
          style: TextStyle(color: BaseboundColors.muted),
        ),
      ],
    ],
  );

  Widget _feedback(BuildContext context) => Semantics(
    liveRegion: true,
    child: SoftPanel(
      padding: const EdgeInsets.all(16),
      color: _correct ? BaseboundColors.greenLight : BaseboundColors.sky,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BaseboundIcon(
            _correct ? BaseboundIconName.check : BaseboundIconName.idea,
            color: _correct ? BaseboundColors.green : BaseboundColors.blue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _correct
                  ? 'You remembered! This place is here.'
                  : 'Another place. Look at the photo again.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _pinChoices(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final useOneColumn =
          constraints.maxWidth < 280 ||
          MediaQuery.textScalerOf(context).scale(1) >= 1.6;
      final width = useOneColumn
          ? constraints.maxWidth
          : (constraints.maxWidth - 12) / 2;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (var index = 0; index < _question.choices.length; index++)
            SizedBox(width: width, child: _pinChoice(index)),
        ],
      );
    },
  );

  Widget _pinChoice(int index) => OutlinedButton(
    onPressed: () => _choose(_question.choices[index]),
    child: Row(
      children: [
        const BaseboundIcon(BaseboundIconName.pin),
        const SizedBox(width: 12),
        Expanded(child: Text('Pin ${index + 1}')),
      ],
    ),
  );
}

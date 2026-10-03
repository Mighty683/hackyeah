import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../game/maps/demo_map.dart';
import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import '../help/help_screen.dart';
import '../landmarks/data/landmark.dart';
import '../landmarks/landmark_practice.dart';
import '../landmarks/widgets/landmark_map.dart';
import '../landmarks/widgets/landmark_photo.dart';
import '../mission/mission_audio.dart';
import 'navigation_location.dart';
import 'walking_navigation.dart';

/// Familiar places, recognition and live walking guidance share one map.
class GameScreen extends StatefulWidget {
  const GameScreen({
    required this.map,
    required this.landmarks,
    required this.photoDirectory,
    this.location,
    super.key,
  });
  final DemoMap map;
  final List<Landmark> landmarks;
  final String photoDirectory;
  final NavigationLocation? location;
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late final _location = widget.location ?? NavigationLocation();
  late final _navigation = WalkingNavigation(
    map: widget.map,
    location: _location,
  );
  final _mapController = LandmarkMapController();
  final _audio = MissionAudio();
  Landmark? _selected;
  LandmarkQuestion? _question;
  bool _correct = false;
  bool _tried = false;
  bool _helpOpen = false;
  bool _voiceAvailable = true;
  bool _recognised = false;
  int _audioRevision = 0;
  String? _spokenCue;
  WalkingRoute? _announcedRoute;

  List<Landmark> get _visible => widget.landmarks
      .where((place) => withinMap(widget.map, place.latitude, place.longitude))
      .toList();
  List<Landmark> get _photos =>
      _visible.where((place) => place.photoName.isNotEmpty).toList();
  String get _instruction => _question == null
      ? _navigation.instruction
      : _correct
      ? 'You remembered! This place is here.'
      : _tried
      ? 'Another place. Look at the photo again.'
      : 'Where is ${_question!.target.name}? Choose its pin.';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _navigation.addListener(_routeChanged);
  }

  void _routeChanged() {
    if (!mounted || _helpOpen || _question != null) return;
    final route = _navigation.route;
    if (route != null && route != _announcedRoute) {
      _announcedRoute = route;
      _speak();
    }
    final next = _navigation.route?.turns
        .where((turn) => turn.distance >= _navigation.progress - 8)
        .firstOrNull;
    final cue = _navigation.nearPlace
        ? 'near:${_navigation.destination?.id}'
        : next != null && next.distance - _navigation.progress <= 20
        ? next.action
        : null;
    if (cue != null && cue != _spokenCue) {
      _spokenCue = cue;
      _speak();
    }
    if (!_navigation.nearPlace) _recognised = false;
  }

  Future<void> _speak() async {
    final revision = ++_audioRevision;
    try {
      final available = await _audio.initialize();
      if (!mounted || revision != _audioRevision || _helpOpen) return;
      setState(() => _voiceAvailable = available);
      if (available) await _audio.narrate(_instruction);
    } catch (_) {
      if (mounted && revision == _audioRevision) {
        setState(() => _voiceAvailable = false);
      }
    }
  }

  Future<void> _openHelp() async {
    if (_helpOpen) return;
    _helpOpen = true;
    _location.pause();
    _audioRevision++;
    await _audio.stop();
    if (!mounted) return;
    try {
      await openHelpScreen(context);
    } finally {
      _helpOpen = false;
      if (mounted) await _location.resume();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _location.pause();
      _audioRevision++;
      _audio.stop();
    } else if (!_helpOpen) {
      _location.resume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _navigation.removeListener(_routeChanged);
    _navigation.dispose();
    if (widget.location == null) {
      _location.dispose();
    } else {
      _location.stop();
    }
    _mapController.dispose();
    _audioRevision++;
    _audio.dispose();
    super.dispose();
  }

  void _choose(Landmark landmark) {
    if (_question == null) {
      setState(() => _selected = landmark);
      return;
    }
    if (_correct) return;
    setState(() {
      _tried = true;
      _correct = _question!.isCorrect(landmark);
    });
    _speak();
  }

  void _recall() {
    _navigation.stop();
    setState(() {
      _question = LandmarkQuestion.pick(
        _photos,
        previousId: _question?.target.id,
      );
      _correct = false;
      _tried = false;
      _selected = null;
    });
    _mapController.showWholeMap();
    _speak();
  }

  Future<void> _navigate() async {
    final target = _selected;
    if (target == null || target.isDemo) return;
    _spokenCue = null;
    _announcedRoute = null;
    _recognised = false;
    _navigation.navigateTo(target);
    if (!_location.isTracking) await _location.start();
    _mapController.showMe();
    _speak();
  }

  void _about() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('About our map'),
      scrollable: true,
      content: const Text(
        'Your blue dot comes only from phone GPS. No tap moves it. Location is used while this screen is open; no track is saved.\n\n'
        'Offline coverage: 2 × 2 km around TAURON Arena, Kraków. Walk with an adult. '
        'Routes use bundled OpenStreetMap paths and local roads. Access, barriers, entrances and hazards are not verified. '
        'Follow your adult’s judgment at roads and crossings. The endpoint ring is a mapped path near the pin.\n\n'
        'Turn instructions follow map geometry, not the way the phone is facing. The map is north-up. '
        'Unclear, old or out-of-area GPS pauses guidance. Fictional demo photos are for recognition only. '
        'Saved places are parent-selected, with no safety check.\n\n'
        'Map data © OpenStreetMap contributors · ODbL 1.0.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      leading: Navigator.canPop(context) ? const BaseboundBackButton() : null,
      title: const Text('Our map'),
      actions: [
        IconButton(
          onPressed: _openHelp,
          icon: const BaseboundIcon(BaseboundIconName.help),
          tooltip: 'I need help · prototype',
        ),
        IconButton(
          onPressed: _about,
          icon: const BaseboundIcon(BaseboundIconName.info),
          tooltip: 'About our map',
        ),
      ],
    ),
    body: SafeArea(
      child: IllustratedBackdrop(
        warm: true,
        child: AnimatedBuilder(
          animation: _navigation,
          builder: (context, _) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final landscape =
                    constraints.maxWidth > constraints.maxHeight * 1.25;
                final controls = SingleChildScrollView(child: _controls());
                final map = LayoutBuilder(
                  builder: (context, bounds) {
                    final side = math.min(bounds.maxWidth, bounds.maxHeight);
                    final position = _navigation.outsideMap
                        ? null
                        : _location.position;
                    return Center(
                      child: SizedBox(
                        width: side,
                        height: side,
                        child: LandmarkMap(
                          map: widget.map,
                          landmarks: _question?.choices ?? _visible,
                          photoDirectory: widget.photoDirectory,
                          position: position,
                          route: _question == null
                              ? _navigation.route?.points ?? []
                              : [],
                          selectedId: _question == null
                              ? _selected?.id
                              : _correct
                              ? _question!.target.id
                              : null,
                          hidePhotos: _question != null && !_correct,
                          onSelected: _choose,
                          controller: _mapController,
                          showAttribution: false,
                        ),
                      ),
                    );
                  },
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        _recognised
                            ? 'You recognised this place!'
                            : _instruction,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (_question == null)
                      const Text(
                        'Walk together with an adult · North is up',
                        style: TextStyle(
                          fontSize: 12,
                          color: BaseboundColors.muted,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: landscape
                          ? Row(
                              children: [
                                Expanded(child: map),
                                const SizedBox(width: 12),
                                Expanded(child: controls),
                              ],
                            )
                          : Column(
                              children: [
                                Expanded(child: map),
                                const SizedBox(height: 8),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: constraints.maxHeight * .4,
                                  ),
                                  child: controls,
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '© OpenStreetMap contributors · ODbL',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: BaseboundColors.muted,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
  );

  Widget _controls() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (_question != null)
        _recallPanel()
      else ...[
        if (_navigation.destination != null) _routePanel(),
        if (_selected != null) _placePanel(_selected!),
        if (widget.landmarks.isEmpty)
          const SoftPanel(
            child: Text(
              'No familiar places yet. Ask your adult to add photo landmarks in Walk together.',
            ),
          ),
        if (_selected == null && widget.landmarks.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final place in widget.landmarks)
                ActionChip(
                  label: Text(place.name),
                  onPressed: () => _choose(place),
                ),
            ],
          ),
        if (_photos.length >= 2)
          OutlinedButton.icon(
            onPressed: _recall,
            icon: const BaseboundIcon(BaseboundIconName.pin),
            label: const Text('Find the photo pin'),
          ),
      ],
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: _location.state == LocationState.waiting
                ? null
                : () async {
                    if (_location.isTracking) {
                      _location.stop();
                    } else {
                      await _location.start();
                      _mapController.showMe();
                    }
                  },
            icon: const Icon(Icons.my_location),
            label: Text(_location.isTracking ? 'Stop GPS' : 'Use live GPS'),
          ),
          IconButton(
            onPressed: _location.position != null && !_navigation.outsideMap
                ? _mapController.showMe
                : null,
            tooltip: 'Show me',
            icon: const BaseboundIcon(BaseboundIconName.child),
          ),
          IconButton(
            onPressed: () => _mapController.zoom(1.4),
            tooltip: 'Zoom in',
            icon: const BaseboundIcon(BaseboundIconName.plus),
          ),
          IconButton(
            onPressed: () => _mapController.zoom(1 / 1.4),
            tooltip: 'Zoom out',
            icon: const BaseboundIcon(BaseboundIconName.minus),
          ),
          IconButton(
            onPressed: _mapController.showWholeMap,
            tooltip: 'Show whole map',
            icon: const BaseboundIcon(BaseboundIconName.fitMap),
          ),
          IconButton(
            onPressed: _speak,
            tooltip: 'Replay audio',
            icon: const BaseboundIcon(BaseboundIconName.speaker),
          ),
        ],
      ),
      Text(
        _navigation.outsideMap
            ? 'GPS is outside the TAURON Arena, Kraków map. No position is placed on this map.'
            : _location.message,
        style: const TextStyle(fontSize: 12, color: BaseboundColors.muted),
      ),
      if (!_voiceAvailable)
        const Text(
          'Voice is unavailable. Ask your adult to help.',
          style: TextStyle(fontSize: 12),
        ),
    ],
  );

  Widget _placePanel(Landmark place) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: SoftPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  place.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _selected = null),
                tooltip: 'Close place',
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          if (place.photoName.isNotEmpty)
            LandmarkPhoto(
              path: '${widget.photoDirectory}/${place.photoName}',
              label: place.name,
              height: 120,
            ),
          const SizedBox(height: 8),
          if (place.isDemo)
            const Text('Fictional demo photo and pin · recognition only')
          else if (!withinMap(widget.map, place.latitude, place.longitude))
            const Text(
              'Outside this downloaded map. Walking guidance is unavailable.',
            )
          else
            FilledButton.icon(
              onPressed: _navigate,
              icon: const Icon(Icons.directions_walk),
              label: const Text('Walk here together'),
            ),
        ],
      ),
    ),
  );

  Widget _routePanel() {
    final target = _navigation.destination!;
    final route = _navigation.route;
    return SoftPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'To ${target.name}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          if (route != null) ...[
            Text('${metres(_navigation.remaining)} of mapped path remaining'),
            Text(
              'Photo pin: ${metres(_navigation.destinationDistance)} ${compass(_navigation.destinationBearing)} · direct distance',
              style: const TextStyle(fontSize: 12),
            ),
            const Text(
              'The ring ends on a mapped path near the pin.',
              style: TextStyle(fontSize: 12),
            ),
          ],
          if (_navigation.nearPlace && !_recognised)
            FilledButton(
              onPressed: () {
                setState(() => _recognised = true);
                _navigation.stop();
              },
              child: const Text('I recognise this place'),
            ),
          TextButton(
            onPressed: _navigation.stop,
            child: const Text('Stop directions'),
          ),
        ],
      ),
    );
  }

  Widget _recallPanel() => SoftPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LandmarkPhoto(
          path: '${widget.photoDirectory}/${_question!.target.photoName}',
          label: _question!.target.name,
          height: 120,
        ),
        Text(
          _question!.target.name,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        if (_question!.target.isDemo) const Text('Fictional demo photo'),
        if (!_correct)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var index = 0; index < _question!.choices.length; index++)
                OutlinedButton(
                  onPressed: () => _choose(_question!.choices[index]),
                  child: Text('Pin ${index + 1}'),
                ),
            ],
          )
        else
          FilledButton(
            onPressed: _recall,
            child: const Text('Try another place'),
          ),
        TextButton(
          onPressed: () {
            setState(() => _question = null);
            _audioRevision++;
            _audio.stop();
          },
          child: const Text('Explore our map'),
        ),
      ],
    ),
  );
}

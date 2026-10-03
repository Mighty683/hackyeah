import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../game/maps/demo_map.dart';
import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import '../../widgets/basebound_mascot.dart';
import '../help/help_screen.dart';
import '../landmarks/data/landmark.dart';
import '../landmarks/widgets/landmark_map.dart';
import '../landmarks/widgets/landmark_photo.dart';
import '../../audio/practice_audio.dart';
import 'navigation_location.dart';
import 'walking_navigation.dart';
import 'widgets/game_map_layout.dart';
import 'widgets/place_panels.dart';

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
  final _audio = PracticeAudio();
  Landmark? _selected;
  bool _helpOpen = false;
  bool _foreground = true;
  bool _voiceAvailable = true;
  bool _recognised = false;
  int _audioRevision = 0;
  String? _spokenCue;
  WalkingRoute? _announcedRoute;

  List<Landmark> get _visible => widget.landmarks
      .where((place) => widget.map.contains(place.latitude, place.longitude))
      .toList();
  String get _instruction => _navigation.destination == null
      ? 'Choose a place on the map.'
      : _navigation.instruction;

  /// A nearby photo is recognition help, never a verified destination.
  ({Landmark place, double distance})? get _nearestLandmark {
    final position = _location.position;
    if (!_location.isPrecise || position == null || _navigation.outsideMap) {
      return null;
    }
    Landmark? nearest;
    var nearestDistance = 50.0;
    for (final place in _visible.where((place) => place.photoName.isNotEmpty)) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        place.latitude,
        place.longitude,
      );
      if (distance <= nearestDistance) {
        nearest = place;
        nearestDistance = distance;
      }
    }
    return nearest == null ? null : (place: nearest, distance: nearestDistance);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _navigation.addListener(_routeChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _foreground && !_helpOpen) {
        _location.start(requestPermission: false);
      }
    });
  }

  void _routeChanged() {
    if (!mounted || _helpOpen || _navigation.isCalculating) return;
    final route = _navigation.route;
    if (route == null && _announcedRoute != null) {
      _announcedRoute = null;
      _spokenCue = null;
      _audioRevision++;
      _audio.stop();
    }
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
    if (_navigation.destination != null && !_navigation.nearPlace) {
      _recognised = false;
    }
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
      if (mounted && _foreground) await _location.resume();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground) {
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
    _audioRevision++;
    _audio.dispose();
    super.dispose();
  }

  void _choose(Landmark landmark) => setState(() {
    _selected = landmark;
    _recognised = false;
  });

  Future<void> _navigate() async {
    final target = _selected;
    if (target == null || target.isDemo) return;
    _spokenCue = null;
    _announcedRoute = null;
    _recognised = false;
    _navigation.navigateTo(target);
    setState(() => _selected = null);
    if (_foreground && !_helpOpen && !_location.isTracking) {
      await _location.start(requestPermission: false);
    }
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
          icon: const BaseboundIcon(BaseboundIconName.help, size: 24),
          tooltip: 'I need help · prototype',
        ),
        IconButton(
          onPressed: _about,
          icon: const BaseboundIcon(BaseboundIconName.info, size: 24),
          tooltip: 'About our map',
        ),
      ],
    ),
    body: SafeArea(
      child: IllustratedBackdrop(
        warm: true,
        child: AnimatedBuilder(
          animation: _navigation,
          builder: (context, _) => Stack(
            children: [
              GameMapLayout(
                instruction: _recognised
                    ? 'You recognised this place!'
                    : _instruction,
                onReplay: _speak,
                controls: _controls(),
                map: LandmarkMap(
                  map: widget.map,
                  landmarks: _visible,
                  photoDirectory: widget.photoDirectory,
                  position: _navigation.outsideMap ? null : _location.position,
                  route: _navigation.route?.points ?? [],
                  selectedId: _selected?.id,
                  onSelected: _choose,
                  showAttribution: false,
                ),
              ),
              if (_navigation.isCalculating)
                Positioned.fill(child: _routeLoading()),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _routeLoading() => ColoredBox(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BaseboundMascot(size: 160, pose: DinoPose.search),
            const SizedBox(height: 24),
            Semantics(
              liveRegion: true,
              child: Text(
                'Finding a path…',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _navigation.stop,
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    ),
  );

  void _showPlaces() => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const Text(
            'Our places',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (final place in widget.landmarks)
            ListTile(
              title: Text(place.name),
              subtitle: place.isDemo
                  ? Text(
                      place.photoName.isEmpty
                          ? 'Fictional demo place · not verified safe'
                          : 'Fictional demo photo · recognition only',
                    )
                  : null,
              leading: Text(place.icon, style: const TextStyle(fontSize: 24)),
              onTap: () {
                Navigator.pop(sheetContext);
                _choose(place);
              },
            ),
        ],
      ),
    ),
  );

  String? get _locationStatus {
    if (_navigation.outsideMap) return 'GPS is outside this demo map.';
    return switch (_location.state) {
      LocationState.off => 'Location is off. You can still explore.',
      LocationState.waiting => 'Finding your location…',
      LocationState.live =>
        _location.isPrecise
            ? null
            : 'GPS is approximate. Walking directions are paused.',
      LocationState.denied => 'Location is not allowed. You can still explore.',
      LocationState.settingsRequired =>
        'Your adult can allow location in app settings.',
      LocationState.disabled => 'Your adult can turn on phone location.',
      LocationState.unavailable => 'GPS is unavailable. You can still explore.',
      LocationState.stale => 'GPS is old. Walking directions are paused.',
      LocationState.paused => 'Location is paused.',
    };
  }

  Widget _controls() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (_nearestLandmark case final nearby?) ...[
        SoftPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nearby landmark · about ${metres(nearby.distance)} away',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              LandmarkPhoto(
                path: '${widget.photoDirectory}/${nearby.place.photoName}',
                label: nearby.place.name,
                height: 120,
              ),
              TextButton(
                onPressed: () => _choose(nearby.place),
                child: Text('${nearby.place.icon} ${nearby.place.name}'),
              ),
              if (nearby.place.isDemo)
                const Text('Fictional demo photo · recognition only'),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
      if (_selected != null)
        SelectedPlacePanel(
          place: _selected!,
          map: widget.map,
          photoDirectory: widget.photoDirectory,
          hasDirections: _navigation.destination != null,
          onClose: () => setState(() => _selected = null),
          onNavigate: _navigate,
        )
      else if (_navigation.destination != null)
        WalkingRoutePanel(
          target: _navigation.destination!,
          photoDirectory: widget.photoDirectory,
          hasRoute: _navigation.route != null,
          remaining: _navigation.remaining,
          nearPlace: _navigation.nearPlace,
          recognised: _recognised,
          onRecognise: () {
            setState(() => _recognised = true);
            _navigation.stop();
          },
          onStop: _navigation.stop,
        ),
      if (widget.landmarks.isEmpty)
        const Text('Ask your adult to add familiar places.')
      else if (_selected == null && _navigation.destination == null)
        OutlinedButton.icon(
          onPressed: _showPlaces,
          icon: const BaseboundIcon(BaseboundIconName.pin, size: 24),
          label: const Text('Places'),
        ),
      if (_locationStatus case final status?) ...[
        const SizedBox(height: 8),
        Text(
          status,
          style: const TextStyle(fontSize: 12, color: BaseboundColors.muted),
        ),
      ],
      if (!_voiceAvailable)
        const Text(
          'Voice is unavailable. Ask your adult to help.',
          style: TextStyle(fontSize: 12),
        ),
    ],
  );
}

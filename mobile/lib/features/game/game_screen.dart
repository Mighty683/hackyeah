import 'package:flutter/foundation.dart';
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
      ? 'Wybierz miejsce na mapie.'
      : _navigation.instruction;

  /// A nearby photo is recognition help, never a verified destination.
  ({Landmark place, double distance})? get _nearestLandmark {
    final position = _location.position;
    if (!_location.isPrecise || position == null || _navigation.outsideMap) {
      return null;
    }
    Landmark? nearest;
    var nearestDistance = 50.0;
    for (final place in _visible.where(
      (place) => !place.isDestination && place.hasPhoto,
    )) {
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

  String get _mapLocationExplanation => kIsWeb
      ? 'Demo w przeglądarce: niebieska kropka to fikcyjna, stała pozycja. Nie wykrywamy GPS, ruchu ani rzeczywistego dotarcia.\n\n'
      : 'Niebieska kropka wynika wyłącznie z GPS telefonu. Dotknięcie jej nie przesuwa. Lokalizacja działa na otwartym ekranie; trasa nie jest zapisywana.\n\n';

  void _about() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('O Naszej mapie'),
      scrollable: true,
      content: Text(
        '$_mapLocationExplanation'
        'Mapa offline: 2 × 2 km wokół TAURON Areny w Krakowie. Spaceruj z dorosłym. '
        'Trasy korzystają z zapisanych ścieżek i lokalnych dróg OpenStreetMap. Dostęp, bariery, wejścia i zagrożenia nie są sprawdzane. '
        'Przy drogach i przejściach kieruj się oceną dorosłego. Pierścień końca trasy wskazuje ścieżkę na mapie blisko znacznika.\n\n'
        'Wskazówki skrętów wynikają z mapy, a nie z kierunku telefonu. Północ jest u góry mapy. '
        'Niedokładna, stara lub znajdująca się poza mapą pozycja GPS wstrzymuje wskazówki. '
        'Zapisane miejsca wybiera rodzic. Ich bezpieczeństwo nie jest sprawdzane.\n\n'
        'Dane mapy © autorzy OpenStreetMap · ODbL 1.0.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Zamknij'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      leading: Navigator.canPop(context) ? const BaseboundBackButton() : null,
      title: const Text('Nasza mapa'),
      actions: [
        IconButton(
          onPressed: _openHelp,
          icon: const BaseboundIcon(BaseboundIconName.help, size: 24),
          tooltip: 'Potrzebuję pomocy',
        ),
        IconButton(
          onPressed: _about,
          icon: const BaseboundIcon(BaseboundIconName.info, size: 24),
          tooltip: 'O Naszej mapie',
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
                    ? 'Rozpoznajesz to miejsce!'
                    : _instruction,
                onReplay: _speak,
                audioUnavailable: kIsWeb && !_voiceAvailable,
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
                'Szukanie ścieżki…',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _navigation.stop,
              child: const Text('Anuluj'),
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
            'Nasze miejsca',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (final place in widget.landmarks)
            ListTile(
              title: Text(place.name),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (place.isDestination)
                    Text(place.icon, style: const TextStyle(fontSize: 24)),
                  if (place.isDestination && place.hasPhoto)
                    const SizedBox(width: 8),
                  if (place.hasPhoto)
                    SizedBox(width: 48, child: _photo(place, height: 48)),
                ],
              ),
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
    if (kIsWeb) {
      return 'Pozycja demo · fikcyjna, stała lokalizacja. Bez użycia GPS.';
    }
    if (_navigation.outsideMap) return 'Pozycja GPS jest poza mapą demo.';
    return switch (_location.state) {
      LocationState.off =>
        'Lokalizacja jest wyłączona. Możesz dalej poznawać mapę.',
      LocationState.waiting => 'Szukanie twojej pozycji…',
      LocationState.live =>
        _location.isPrecise
            ? null
            : 'GPS jest niedokładny. Wskazówki spaceru są wstrzymane.',
      LocationState.denied =>
        'Brak zgody na lokalizację. Możesz dalej poznawać mapę.',
      LocationState.settingsRequired =>
        'Dorosły może włączyć dostęp do lokalizacji w ustawieniach aplikacji.',
      LocationState.disabled => 'Dorosły może włączyć lokalizację telefonu.',
      LocationState.unavailable =>
        'GPS jest niedostępny. Możesz dalej poznawać mapę.',
      LocationState.stale =>
        'Pozycja GPS jest nieaktualna. Wskazówki spaceru są wstrzymane.',
      LocationState.paused => 'Lokalizacja jest wstrzymana.',
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
                'Punkt orientacyjny w pobliżu · około ${metres(nearby.distance)} stąd',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              _photo(nearby.place, height: 120),
              TextButton(
                onPressed: () => _choose(nearby.place),
                child: Text(nearby.place.name),
              ),
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
        const Text('Poproś dorosłego o dodanie znanych miejsc.')
      else if (_selected == null && _navigation.destination == null)
        OutlinedButton.icon(
          onPressed: _showPlaces,
          icon: const BaseboundIcon(BaseboundIconName.pin, size: 24),
          label: const Text('Miejsca'),
        ),
      if (_locationStatus case final status?) ...[
        const SizedBox(height: 8),
        Text(
          status,
          style: const TextStyle(fontSize: 12, color: BaseboundColors.muted),
        ),
      ],
      if (!kIsWeb && !_voiceAvailable)
        const Text(
          kIsWeb
              ? 'Głos w przeglądarce jest niedostępny. Czytaj z dorosłym.'
              : 'Głos jest niedostępny. Poproś dorosłego o pomoc.',
          style: TextStyle(fontSize: 12),
        ),
    ],
  );

  Widget _photo(Landmark place, {required double height}) => LandmarkPhoto(
    path: '${widget.photoDirectory}/${place.photoName}',
    assetPath: place.photoAsset,
    label: place.name,
    height: height,
  );
}

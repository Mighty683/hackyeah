import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../game/maps/demo_map.dart';
import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import '../../widgets/basebound_mascot.dart';
import '../parent/widgets/parent_editor_scaffold.dart';
import 'data/landmark.dart';
import 'data/landmark_repository.dart';
import 'data/demo_landmarks.dart';
import 'landmark_editor_screen.dart';
import 'landmark_location.dart';
import 'landmark_practice_screen.dart';
import 'widgets/landmark_map.dart';
import 'widgets/landmark_photo.dart';
import 'widgets/photo_action_icon.dart';

/// Parents capture individual recognition points; children explore the same
/// collection. Sorting is presentation only and never defines a route.
class LandmarkLibraryScreen extends StatefulWidget {
  const LandmarkLibraryScreen({
    this.parentMode = false,
    this.repository,
    super.key,
  });
  final bool parentMode;
  final LandmarkRepository? repository;

  @override
  State<LandmarkLibraryScreen> createState() => _LandmarkLibraryScreenState();
}

class _LandmarkLibraryScreenState extends State<LandmarkLibraryScreen> {
  late final _repository = widget.repository ?? LandmarkRepository();
  final _picker = ImagePicker();
  List<Landmark> _landmarks = [];
  List<Landmark> _mapLandmarks = [];
  String? _photoDirectory;
  Landmark? _selected;
  bool _loading = true;
  bool _busy = false;
  bool _checkedRecovery = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final landmarks = await _repository.load();
      final directory = await _repository.photoDirectory();
      final map = await DemoMapRepository().load();
      if (!mounted) return;
      final visible = landmarks
          .where((entry) => mapContainsPoint(map, entry.point))
          .toList();
      setState(() {
        _landmarks = landmarks;
        _mapLandmarks = visible;
        _photoDirectory = directory.path;
        _selected = visible
            .where((entry) => entry.id == _selected?.id)
            .firstOrNull;
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Could not load landmarks. Your saved details have not been reset.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    if (mounted && _error == null && widget.parentMode && !_checkedRecovery) {
      _checkedRecovery = true;
      await _recoverPhoto();
    }
  }

  void _message(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _recoverPhoto() async {
    try {
      final recovered = await _picker.retrieveLostData();
      if (!mounted || recovered.isEmpty) return;
      final photo = recovered.files?.firstOrNull;
      if (photo == null) {
        _message('Could not recover the previous photo. Try taking it again.');
        return;
      }
      _message('Recovered your photo. Give it a name and a pin.');
      await _edit(photoPath: photo.path);
    } catch (_) {
      _message('Photo recovery is unavailable. You can still add a new photo.');
    }
  }

  Future<void> _loadDemo() async {
    setState(() => _busy = true);
    try {
      final added = await loadDemoLandmarks(_repository);
      _message(
        added == 0
            ? 'Demo landmarks are already saved.'
            : '$added fictional demo landmarks added.',
      );
    } catch (_) {
      _message(
        'Could not finish loading demo landmarks. Try again; saved points are kept.',
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        await _load();
      }
    }
  }

  Future<void> _addPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Save a recognisable place',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const PhotoActionIcon(),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const PhotoActionIcon(gallery: true),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final photo = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (!mounted || photo == null) return;
      await _edit(photoPath: photo.path);
    } catch (_) {
      _message('Could not open the photo. Try the camera or gallery again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit({Landmark? landmark, String? photoPath}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => LandmarkEditorScreen(
          landmark: landmark,
          photoPath: photoPath ?? '$_photoDirectory/${landmark!.photoName}',
          otherPoints: _mapLandmarks
              .where((entry) => entry.id != landmark?.id)
              .map((entry) => entry.point)
              .toList(),
          onSave: (entry) => _repository.save(
            entry,
            sourcePhoto: landmark == null ? photoPath : null,
          ),
        ),
      ),
    );
    if (saved == true && mounted) await _load();
  }

  Future<void> _delete({Landmark? landmark}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          landmark == null ? 'Delete all landmarks?' : 'Delete this landmark?',
        ),
        content: const Text(
          'This removes saved photo copies and pins from this app. Original gallery photos stay on your device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      if (landmark == null) {
        await _repository.deleteAll();
      } else {
        await _repository.delete(landmark);
      }
    } catch (_) {
      _message(
        'Could not fully delete. Try again, or use Delete all landmarks.',
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        await _load();
      }
    }
  }

  Future<void> _practice() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => LandmarkPracticeScreen(
          landmarks: _mapLandmarks,
          photoDirectory: _photoDirectory!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: widget.parentMode ? parentSetupTheme() : BaseboundTheme.training(),
    child: PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.parentMode ? 'Walk together' : 'Our landmarks'),
          actions: [
            if (widget.parentMode)
              PopupMenuButton<String>(
                enabled: !_loading && !_busy,
                tooltip: 'Landmark options',
                onSelected: (_) => _delete(),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete all landmarks'),
                  ),
                ],
              ),
          ],
        ),
        body: SafeArea(
          child: widget.parentMode
              ? _body()
              : IllustratedBackdrop(child: _body()),
        ),
        bottomNavigationBar: _error == null && !_loading ? _footer() : null,
      ),
    ),
  );

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _load,
                child: const Text('Retry loading'),
              ),
            ],
          ),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.parentMode) ...[
                const Text(
                  'Save places you recognise',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text('Stop together. Add a photo and a map pin.'),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _loadDemo,
                  icon: const BaseboundIcon(BaseboundIconName.play),
                  label: const Text('Load demo landmarks'),
                ),
              ] else ...[
                const BaseboundGuide(
                  message: 'Tap a photo pin. Remember this place?',
                  pose: DinoPose.point,
                ),
              ],
              const SizedBox(height: 16),
              LandmarkMap(
                landmarks: _mapLandmarks,
                photoDirectory: _photoDirectory!,
                selectedId: _selected?.id,
                onSelected: (entry) => setState(() => _selected = entry),
              ),
              const SizedBox(height: 16),
              if (_selected != null) _selectedCard(_selected!),
              if (_landmarks.isEmpty)
                SoftPanel(
                  child: Text(
                    widget.parentMode
                        ? 'No landmarks yet. Photograph a familiar place, then choose its pin.'
                        : 'No photo landmarks yet. Ask an adult to add places together.',
                  ),
                ),
              if (_landmarks.isNotEmpty) ...[
                Text(
                  '${_landmarks.length} landmarks saved',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                for (final entry in _landmarks) _listEntry(entry),
              ],
              const SizedBox(height: 16),
              if (widget.parentMode)
                const ParentEditorNote(
                  message: 'Demo map: TAURON Arena, Kraków. Pins are independent landmarks, not a path or checked safe places. Photos stay in app-private storage; names and pins are encrypted. No cloud sync or parent lock.',
                  icon: BaseboundIconName.info,
                )
              else
                const Text(
                  'Learn familiar places. These pins are not walking directions.',
                  style: TextStyle(color: BaseboundColors.muted),
                ),
              if (!widget.parentMode &&
                  _mapLandmarks.length < 2 &&
                  _landmarks.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Add two landmarks to practise finding their pins.',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectedCard(Landmark entry) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: SoftPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LandmarkPhoto(
            path: '$_photoDirectory/${entry.photoName}',
            label: entry.name,
          ),
          const SizedBox(height: 12),
          Text(
            entry.name,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
          ),
          if (entry.isDemo)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Fictional demo photo and pin',
                style: TextStyle(color: BaseboundColors.muted),
              ),
            ),
          if (widget.parentMode)
            TextButton.icon(
              onPressed: _busy ? null : () => _edit(landmark: entry),
              icon: const BaseboundIcon(BaseboundIconName.edit),
              label: const Text('Edit landmark'),
            ),
        ],
      ),
    ),
  );

  Widget _listEntry(Landmark entry) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: SizedBox(
          width: 64,
          child: LandmarkPhoto(
            path: '$_photoDirectory/${entry.photoName}',
            label: entry.name,
            height: 56,
          ),
        ),
        title: Text(
          entry.name,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: !_mapLandmarks.any((point) => point.id == entry.id)
            ? const Text('Outside this demo map')
            : entry.isDemo
            ? const Text('Fictional demo landmark')
            : null,
        onTap: _busy
            ? null
            : () => widget.parentMode
                  ? _edit(landmark: entry)
                  : setState(() => _selected = entry),
        trailing: widget.parentMode
            ? IconButton(
                onPressed: _busy ? null : () => _delete(landmark: entry),
                tooltip: 'Delete ${entry.name}',
                icon: const BaseboundIcon(BaseboundIconName.delete),
              )
            : const BaseboundIcon(BaseboundIconName.pin),
      ),
    ),
  );

  Widget _footer() => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.parentMode)
            FilledButton.icon(
              onPressed: _busy ? null : _addPhoto,
              icon: const PhotoActionIcon(color: Colors.white),
              label: Text(_busy ? 'Opening photo…' : 'Take a photo'),
            ),
          if (!widget.parentMode && _mapLandmarks.length >= 2)
            FilledButton.icon(
              onPressed: _practice,
              icon: const BaseboundIcon(
                BaseboundIconName.play,
                color: Colors.white,
              ),
              label: const Text('Find the photo pin'),
            ),
        ],
      ),
    ),
  );
}

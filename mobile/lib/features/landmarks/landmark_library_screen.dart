import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../game/maps/demo_map.dart';
import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import '../../ui/parent_setup_ui.dart';
import 'data/landmark.dart';
import 'data/landmark_repository.dart';
import 'data/demo_landmarks.dart';
import 'landmark_editor_screen.dart';
import 'landmark_location.dart';
import 'widgets/landmark_map.dart';
import 'widgets/landmark_library_cards.dart';
import 'widgets/landmark_photo_source.dart';
import 'widgets/photo_action_icon.dart';

/// Adult photo capture for the same familiar-place map children use.
class LandmarkLibraryScreen extends StatefulWidget {
  const LandmarkLibraryScreen({this.repository, super.key});
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
    if (mounted && _error == null && !_checkedRecovery) {
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
    final source = await chooseLandmarkPhotoSource(context);
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

  @override
  Widget build(BuildContext context) => Theme(
    data: parentSetupTheme(),
    child: PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Walk together'),
          actions: [
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
        body: SafeArea(child: _body()),
        bottomNavigationBar: _error == null && !_loading
            ? SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _addPhoto,
                    icon: const PhotoActionIcon(color: Colors.white),
                    label: Text(_busy ? 'Opening photo…' : 'Take a photo'),
                  ),
                ),
              )
            : null,
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
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Save places you recognise',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Stop together. Add a photo and a map pin. Your child can recognise it and choose it on Our map.',
              ),
              const SizedBox(height: 24),
              LandmarkMap(
                landmarks: _mapLandmarks,
                photoDirectory: _photoDirectory!,
                selectedId: _selected?.id,
                onSelected: (entry) => setState(() => _selected = entry),
              ),
              const SizedBox(height: 16),
              if (_selected case final selected?)
                SelectedLandmarkCard(
                  entry: selected,
                  photoDirectory: _photoDirectory!,
                  onEdit: _busy ? null : () => _edit(landmark: selected),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _busy ? null : _loadDemo,
                  icon: const BaseboundIcon(BaseboundIconName.play),
                  label: const Text('Load demo landmarks'),
                ),
              ),
              const SizedBox(height: 16),
              if (_landmarks.isEmpty)
                const SoftPanel(
                  child: Text(
                    'No landmarks yet. Photograph a familiar place, then choose its pin.',
                  ),
                ),
              if (_landmarks.isNotEmpty) ...[
                Text(
                  '${_landmarks.length} landmarks saved',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                for (final entry in _landmarks)
                  LandmarkLibraryEntry(
                    entry: entry,
                    photoDirectory: _photoDirectory!,
                    onMap: _mapLandmarks.any((point) => point.id == entry.id),
                    onEdit: _busy ? null : () => _edit(landmark: entry),
                    onDelete: _busy ? null : () => _delete(landmark: entry),
                  ),
              ],
              const SizedBox(height: 24),
              const ParentEditorNote(
                message:
                    'Demo map: TAURON Arena, Kraków. Landmarks are independent points, with no fixed visiting order. '
                    'Walking routes use GPS and offline paths; access, entrances and hazards are not verified. Walk with your child. '
                    'Fictional demo pins are for recognition only. Photos stay in app-private storage; names and pins are encrypted. No cloud sync or parent lock.',
                icon: BaseboundIconName.info,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

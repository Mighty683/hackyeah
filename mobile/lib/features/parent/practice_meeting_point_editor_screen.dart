/// Selects a photo landmark for lost recognition and map practice.
library;

import '../../platform/photo_access.dart';

import 'package:flutter/material.dart';

import '../../game/maps/demo_map.dart';
import '../../ui/basebound_icons.dart';
import '../landmarks/data/landmark.dart';
import '../landmarks/data/landmark_repository.dart';
import '../landmarks/landmark_library_screen.dart';
import '../landmarks/landmark_location.dart';
import '../landmarks/widgets/landmark_photo.dart';
import '../mission/lost_landmarks.dart';
import 'data/family_plan.dart';
import 'widgets/parent_editor_scaffold.dart';

class PracticeMeetingPointEditorScreen extends StatefulWidget {
  const PracticeMeetingPointEditorScreen({
    required this.onSave,
    this.point,
    this.repository,
    super.key,
  });
  final PracticeMeetingPoint? point;
  final LandmarkRepository? repository;
  final Future<void> Function(PracticeMeetingPoint) onSave;
  @override
  State<PracticeMeetingPointEditorScreen> createState() =>
      _PracticeMeetingPointEditorScreenState();
}

class _PracticeMeetingPointEditorScreenState
    extends State<PracticeMeetingPointEditorScreen> {
  late final _repository = widget.repository ?? LandmarkRepository();
  late String? _landmarkId = widget.point?.landmarkId;
  late bool _demoMode = widget.point != null && _landmarkId == null;
  late String _presetId = resolveLostLandmark(
    widget.point?.presetId ?? 'fountain',
  ).id;
  late final _label = TextEditingController(
    text: widget.point?.label ?? resolveLostLandmark(_presetId).label,
  );
  List<Landmark> _landmarks = [];
  String _photoDirectory = '';
  bool _loading = true;
  bool _loadFailed = false;
  Landmark? get _selected =>
      _landmarks.where((place) => place.id == _landmarkId).firstOrNull;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final landmarks = await _repository.load();
      if (landmarks.isEmpty) {
        if (mounted) setState(() => _landmarks = []);
        return;
      }
      final directory = await _repository.photoDirectory();
      final map = await DemoMapRepository().load();
      final available = <Landmark>[];
      for (final place in landmarks) {
        if (mapContainsPoint(map, place.point) &&
            await photoExists('${directory.path}/${place.photoName}')) {
          available.add(place);
        }
      }
      if (!mounted) return;
      setState(() {
        _landmarks = available;
        _photoDirectory = directory.path;
      });
    } catch (_) {
      if (mounted) setState(() => _loadFailed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openLibrary() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => LandmarkLibraryScreen(repository: _repository),
      ),
    );
    if (mounted) await _load();
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  void _choosePreset(LostLandmarkPreset preset) {
    if (_label.text.trim().isEmpty ||
        _label.text == resolveLostLandmark(_presetId).label) {
      _label.text = preset.label;
    }
    setState(() => _presetId = preset.id);
  }

  Future<void> _save() async {
    if (!_demoMode) {
      final selected = _selected;
      if (selected == null) return;
      await widget.onSave(
        PracticeMeetingPoint(landmarkId: selected.id, label: selected.name),
      );
      return;
    }
    await widget.onSave(
      PracticeMeetingPoint(
        presetId: _presetId,
        label: _label.text.trim().isEmpty
            ? resolveLostLandmark(_presetId).label
            : _label.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ParentEditorScaffold(
    title: 'Punkt spotkania do ćwiczeń',
    onSave: _save,
    saveEnabled: _demoMode || (!_loading && !_loadFailed && _selected != null),
    saveLabel: 'Zapisz punkt spotkania do ćwiczeń',
    children: [
      const ParentEditorNote(
        message: 'Wybierzcie dokładnie to miejsce, które wspólnie ustaliliście. Dziecko rozpozna jego zdjęcie i znajdzie znacznik na Naszej mapie. To tylko ćwiczenie; bezpieczeństwo zapisanych miejsc nie jest sprawdzane.',
        icon: BaseboundIconName.info,
      ),
      const SizedBox(height: 16),
      if (_demoMode) ..._demoChoices() else ..._photoChoices(),
      const SizedBox(height: 16),
      TextButton(
        onPressed: () => setState(() => _demoMode = !_demoMode),
        child: Text(
          _demoMode
              ? 'Wybierz miejsce z zapisanym zdjęciem'
              : 'Użyj przykładowego obrazka',
        ),
      ),
    ],
  );

  List<Widget> _photoChoices() => [
    if (_loading)
      const Center(child: CircularProgressIndicator())
    else if (_loadFailed) ...[
      const Text(
        'Nie udało się odczytać miejsc ze zdjęciami. Zapisane dane zostały zachowane.',
      ),
      TextButton(onPressed: _load, child: const Text('Spróbuj ponownie')),
    ] else ...[
      if (_landmarkId != null && _selected == null)
        const Text(
          'Wybrane miejsce lub jego zdjęcie jest niedostępne. Wybierz inne miejsce.',
        ),
      if (_landmarks.isEmpty)
        const Text(
          'Najpierw dodaj zdjęcie i znacznik w sekcji Wspólny spacer.',
        ),
      for (final place in _landmarks) ...[
        const SizedBox(height: 12),
        Semantics(
          selected: place.id == _landmarkId,
          child: OutlinedButton(
            key: ValueKey('meeting-place-${place.id}'),
            onPressed: () => setState(() => _landmarkId = place.id),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  LandmarkPhoto(
                    fit: BoxFit.contain,
                    path: '$_photoDirectory/${place.photoName}',
                    label: place.name,
                    height: 140,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${place.name}${place.id == _landmarkId ? ' · Wybrane' : ''}',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ],
    const SizedBox(height: 12),
    OutlinedButton.icon(
      onPressed: _openLibrary,
      icon: const BaseboundIcon(BaseboundIconName.addPlace),
      label: const Text('Dodaj lub edytuj zdjęcia w sekcji Wspólny spacer'),
    ),
  ];

  List<Widget> _demoChoices() => [
    const Text(
      'Przykładowy obrazek. Nie przedstawia waszego miejsca ani znacznika na mapie.',
    ),
    if (widget.point != null &&
        resolveLostLandmark(widget.point!.presetId).id !=
            widget.point!.presetId)
      const Text(
        'Zapisany obrazek jest niedostępny. Wybierz nowy przykładowy obrazek.',
      ),
    for (final preset in lostLandmarkPresets) ...[
      const SizedBox(height: 12),
      Semantics(
        selected: _presetId == preset.id,
        child: OutlinedButton(
          onPressed: () => _choosePreset(preset),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                LostLandmarkIllustration(presetId: preset.id, size: 80),
                Text(preset.label),
              ],
            ),
          ),
        ),
      ),
    ],
    const SizedBox(height: 16),
    TextField(
      controller: _label,
      decoration: const InputDecoration(
        labelText: 'Nazwa przykładowego punktu spotkania (opcjonalnie)',
      ),
      textCapitalization: TextCapitalization.words,
      maxLength: 60,
    ),
  ];
}

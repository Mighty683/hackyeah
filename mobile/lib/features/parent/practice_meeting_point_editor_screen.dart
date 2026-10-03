/// Selects a photo landmark for lost recognition and map practice.
library;

import 'dart:io';

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
            await File('${directory.path}/${place.photoName}').exists()) {
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
    title: 'Practice meeting point',
    onSave: _save,
    saveEnabled: _demoMode || (!_loading && !_loadFailed && _selected != null),
    saveLabel: 'Save practice meeting point',
    children: [
      const ParentEditorNote(
        message: 'Choose the exact place you have agreed on together. Your child will recognize its photo, then find its pin on Our map. Training only; saved places are not checked for safety.',
        icon: BaseboundIconName.info,
      ),
      const SizedBox(height: 16),
      if (_demoMode) ..._demoChoices() else ..._photoChoices(),
      const SizedBox(height: 16),
      TextButton(
        onPressed: () => setState(() => _demoMode = !_demoMode),
        child: Text(
          _demoMode ? 'Choose a saved photo place' : 'Use a pretend picture',
        ),
      ),
    ],
  );

  List<Widget> _photoChoices() => [
    if (_loading)
      const Center(child: CircularProgressIndicator())
    else if (_loadFailed) ...[
      const Text(
        'Could not read saved photo places. Saved details are unchanged.',
      ),
      TextButton(onPressed: _load, child: const Text('Try again')),
    ] else ...[
      if (_landmarkId != null && _selected == null)
        const Text(
          'The selected place or its photo is unavailable. Choose another place.',
        ),
      if (_landmarks.isEmpty)
        const Text('Add a photo and pin in Walk together first.'),
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
                    '${place.name}${place.id == _landmarkId ? ' · Selected' : ''}',
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
      label: const Text('Add or edit photos in Walk together'),
    ),
  ];

  List<Widget> _demoChoices() => [
    const Text(
      'Pretend picture. This does not teach your actual place or map pin.',
    ),
    if (widget.point != null &&
        resolveLostLandmark(widget.point!.presetId).id !=
            widget.point!.presetId)
      const Text(
        'The saved picture is unavailable. Choose a new pretend picture.',
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
        labelText: 'Demo meeting point name (optional)',
      ),
      textCapitalization: TextCapitalization.words,
      maxLength: 60,
    ),
  ];
}

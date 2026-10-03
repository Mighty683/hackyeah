/// Family-chosen safe places, shown only as unverified demo targets.
library;

import 'package:flutter/material.dart';

import 'data/family_plan.dart';
import 'widgets/offline_point_picker.dart';
import 'widgets/parent_editor_scaffold.dart';

class SafePointEditorScreen extends StatefulWidget {
  const SafePointEditorScreen({
    required this.otherPoints,
    required this.onSave,
    this.point,
    super.key,
  });

  final SafePoint? point;
  final List<SafePoint> otherPoints;
  final Future<void> Function(SafePoint) onSave;

  @override
  State<SafePointEditorScreen> createState() => _SafePointEditorScreenState();
}

class _SafePointEditorScreenState extends State<SafePointEditorScreen> {
  late final _name = TextEditingController(text: widget.point?.name ?? '');
  late SafePoint? _selected = widget.point;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() => widget.onSave(
    SafePoint(
      name: _name.text.trim(),
      latitude: _selected!.latitude,
      longitude: _selected!.longitude,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return ParentEditorScaffold(
      title: widget.point == null ? 'Add a safe place' : 'Edit a safe place',
      onSave: _save,
      saveLabel: 'Save safe place',
      saveEnabled: selected != null,
      steps: [
        ParentEditorStep(
          title: 'What is your safe place called?',
          nextLabel: 'Choose map location',
          children: [
            const ParentEditorNote(
              message:
                  'A safe place is a destination your family chooses for its '
                  'emergency plan. This demo cannot verify its safety.',
              icon: Icons.info_outline_rounded,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Safe place name (optional)',
                hintText: 'Family meeting place…',
                prefixIcon: Icon(Icons.place_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: 60,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
        ParentEditorStep(
          title: 'Where is your safe place?',
          children: [
            const ParentEditorNote(
              message:
                  'Choose a demo pin near TAURON Arena in Kraków. '
                  'The demo cannot verify safety or real routes.',
              icon: Icons.map_outlined,
            ),
            const SizedBox(height: 24),
            const Text('Tap the map to place or move the pin.'),
            const SizedBox(height: 8),
            OfflinePointPicker(
              initialPoint: selected,
              otherPoints: widget.otherPoints,
              onSelected: (point) {
                if (mounted) setState(() => _selected = point);
              },
            ),
            const SizedBox(height: 8),
            Semantics(
              liveRegion: true,
              label: 'Safe place location',
              value: selected == null
                  ? 'No location selected'
                  : 'Latitude ${selected.latitude.toStringAsFixed(5)}, '
                        'longitude ${selected.longitude.toStringAsFixed(5)}',
              child: ExcludeSemantics(
                child: Text(
                  selected == null
                      ? 'Choose a location before saving.'
                      : 'Location selected. You can move the pin.',
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Each demo game chooses one saved safe place for training.',
            ),
          ],
        ),
      ],
    );
  }
}

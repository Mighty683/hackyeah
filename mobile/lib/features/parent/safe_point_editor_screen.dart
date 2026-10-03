/// Named parent-selected practice places, restricted to the offline demo area.
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
      title: widget.point == null ? 'Add a place' : 'Edit a place',
      onSave: _save,
      saveEnabled: selected != null,
      children: [
        const ParentEditorNote(
          message:
              'Name a place, then choose its position. '
              'This demo covers only the TAURON Arena area in Kraków. '
              'Places are not checked for safety or opening hours.',
          icon: Icons.info_outline_rounded,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _name,
          decoration: const InputDecoration(
            labelText: 'Place name (optional)',
            hintText: 'Home, police station, family friend…',
            prefixIcon: Icon(Icons.place_outlined),
          ),
          textCapitalization: TextCapitalization.words,
          maxLength: 60,
        ),
        const SizedBox(height: 16),
        const Text('Tap the map to place or move the pin.'),
        const SizedBox(height: 8),
        OfflinePointPicker(
          initialPoint: widget.point,
          otherPoints: widget.otherPoints,
          onSelected: (point) {
            if (mounted) setState(() => _selected = point);
          },
        ),
        const SizedBox(height: 8),
        Semantics(
          liveRegion: true,
          child: Text(
            selected == null
                ? 'Choose a position before saving.'
                : 'Selected: ${selected.latitude.toStringAsFixed(5)}, '
                      '${selected.longitude.toStringAsFixed(5)}',
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Each new game randomly picks one saved place as a practice target.',
        ),
      ],
    );
  }
}

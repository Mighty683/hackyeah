/// Family-chosen safe places, shown only as unverified demo targets.
library;

import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';

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
      illustration: ParentEditorArt.place,
      saveLabel: 'Save safe place',
      saveEnabled: selected != null,
      steps: [
        ParentEditorStep(
          title: 'What is your safe place called?',
          nextLabel: 'Choose map location',
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Safe place name (optional)',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: 'Family meeting place…',
                prefixIcon: BaseboundIcon(
                  BaseboundIconName.pin,
                  size: 24,
                  color: BaseboundColors.muted,
                ),
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: 60,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),
            const ParentEditorNote(
              message:
                  'A safe place is a destination your family chooses for its '
                  'emergency plan. This demo cannot verify its safety.',
              icon: BaseboundIconName.info,
            ),
          ],
        ),
        ParentEditorStep(
          title: 'Where is your safe place?',
          children: [
            const Text(
              'Tap the map to place or move the pin.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            OfflinePointPicker(
              initialPoint: selected,
              otherPoints: widget.otherPoints,
              onSelected: (point) {
                if (mounted) setState(() => _selected = point);
              },
            ),
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              label: 'Safe place location',
              value: selected == null
                  ? 'No location selected'
                  : 'Latitude ${selected.latitude.toStringAsFixed(5)}, '
                        'longitude ${selected.longitude.toStringAsFixed(5)}',
              child: ExcludeSemantics(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BaseboundIcon(
                      selected == null
                          ? BaseboundIconName.pin
                          : BaseboundIconName.check,
                      size: 24,
                      color: BaseboundColors.muted,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selected == null
                            ? 'Choose a location before saving.'
                            : 'Location selected. You can move the pin.',
                        style: const TextStyle(
                          color: BaseboundColors.muted,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const ParentEditorNote(
              message:
                  'Choose a demo pin near TAURON Arena in Kraków. '
                  'The demo cannot verify safety or real routes.',
              icon: BaseboundIconName.info,
            ),
            const SizedBox(height: 12),
            const Text(
              'Each demo game chooses one saved safe place for training.',
              style: TextStyle(
                color: BaseboundColors.muted,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

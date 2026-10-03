/// Chooses the same bundled landmark picture used in lost practice.
library;

import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';
import '../mission/lost_landmarks.dart';
import 'data/family_plan.dart';
import 'widgets/parent_editor_scaffold.dart';

class PracticeMeetingPointEditorScreen extends StatefulWidget {
  const PracticeMeetingPointEditorScreen({
    required this.onSave,
    this.point,
    super.key,
  });

  final PracticeMeetingPoint? point;
  final Future<void> Function(PracticeMeetingPoint) onSave;

  @override
  State<PracticeMeetingPointEditorScreen> createState() =>
      _PracticeMeetingPointEditorScreenState();
}

class _PracticeMeetingPointEditorScreenState
    extends State<PracticeMeetingPointEditorScreen> {
  late String _presetId = resolveLostLandmark(
    widget.point?.presetId ?? 'fountain',
  ).id;
  late final _label = TextEditingController(
    text: widget.point?.label ?? resolveLostLandmark(_presetId).label,
  );

  bool get _hasUnknownPreset =>
      widget.point != null &&
      resolveLostLandmark(widget.point!.presetId).id != widget.point!.presetId;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  void _choosePreset(LostLandmarkPreset preset) {
    final oldPreset = resolveLostLandmark(_presetId);
    if (_label.text.trim().isEmpty || _label.text == oldPreset.label) {
      _label.text = preset.label;
    }
    setState(() => _presetId = preset.id);
  }

  Future<void> _save() => widget.onSave(
    PracticeMeetingPoint(
      presetId: _presetId,
      label: _label.text.trim().isEmpty
          ? resolveLostLandmark(_presetId).label
          : _label.text.trim(),
    ),
  );

  @override
  Widget build(BuildContext context) => ParentEditorScaffold(
    title: 'Practice meeting point',
    illustration: ParentEditorArt.place,
    onSave: _save,
    saveLabel: 'Save practice meeting point',
    steps: [
      ParentEditorStep(
        title: 'Choose a landmark for practice',
        nextLabel: 'Name this meeting point',
        children: [
          const ParentEditorNote(
            message:
                'Choose a bundled practice picture. It is not a photo of your '
                'place, a safety check, or a real route.',
            icon: BaseboundIconName.info,
          ),
          if (_hasUnknownPreset) ...[
            const SizedBox(height: 16),
            const ParentEditorNote(
              message:
                  'The saved picture is unavailable. Fountain is shown as a '
                  'pretend fallback. Saved details change only when you save.',
              icon: BaseboundIconName.alert,
            ),
          ],
          const SizedBox(height: 20),
          for (final preset in lostLandmarkPresets) ...[
            Semantics(
              selected: _presetId == preset.id,
              child: OutlinedButton(
                onPressed: () => _choosePreset(preset),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 64),
                  backgroundColor: _presetId == preset.id
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      LostLandmarkIllustration(presetId: preset.id, size: 80),
                      const SizedBox(height: 8),
                      Text(preset.label),
                      const SizedBox(height: 4),
                      Text(preset.description),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
      ParentEditorStep(
        title: 'What do you call this meeting point?',
        children: [
          Center(
            child: LostLandmarkIllustration(presetId: _presetId, size: 96),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _label,
            decoration: const InputDecoration(
              labelText: 'Practice meeting point name (optional)',
              prefixIcon: BaseboundIcon(BaseboundIconName.pin),
            ),
            textCapitalization: TextCapitalization.words,
            maxLength: 60,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your child will see this same picture and name in lost practice. '
            'Calls and safety messages are pretend; nothing is sent.',
          ),
        ],
      ),
    ],
  );
}

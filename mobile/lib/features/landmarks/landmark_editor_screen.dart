import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';
import '../parent/data/family_plan.dart';
import '../parent/widgets/offline_point_picker.dart';
import '../parent/widgets/parent_editor_scaffold.dart';
import 'data/landmark.dart';
import 'landmark_location.dart';
import 'widgets/landmark_photo.dart';

/// One name, then one confirmed pin. Capturing never marks a place as safe.
class LandmarkEditorScreen extends StatefulWidget {
  const LandmarkEditorScreen({
    required this.photoPath,
    required this.otherPoints,
    required this.onSave,
    this.landmark,
    super.key,
  });
  final String photoPath;
  final List<SafePoint> otherPoints;
  final Landmark? landmark;
  final Future<void> Function(Landmark) onSave;

  @override
  State<LandmarkEditorScreen> createState() => _LandmarkEditorScreenState();
}

class _LandmarkEditorScreenState extends State<LandmarkEditorScreen> {
  late final _name = TextEditingController(text: widget.landmark?.name ?? '');
  late final _id = widget.landmark?.id ?? Landmark.newId();
  late SafePoint? _selected = widget.landmark?.point;
  bool _locating = false;
  int _pinRevision = 0;
  String? _locationMessage;

  @override
  void initState() {
    super.initState();
    _name.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _useLocation() async {
    setState(() {
      _locating = true;
      _locationMessage = null;
    });
    try {
      final point = await currentLandmarkLocation();
      if (!mounted) return;
      setState(() {
        _selected = point;
        _pinRevision++;
        _locationMessage = 'Location found. Check and adjust the pin.';
      });
    } on LandmarkLocationException catch (error) {
      if (mounted) setState(() => _locationMessage = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _locationMessage =
              'Could not find your location. Choose a pin manually.',
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _save() => widget.onSave(
    Landmark(
      id: _id,
      name: _name.text.trim(),
      photoName: '$_id.photo',
      latitude: _selected!.latitude,
      longitude: _selected!.longitude,
      isDemo: widget.landmark?.isDemo ?? false,
    ),
  );

  @override
  Widget build(BuildContext context) => ParentEditorScaffold(
    title: widget.landmark == null ? 'Add landmark' : 'Edit landmark',
    illustration: ParentEditorArt.place,
    saveLabel: 'Save landmark',
    saveEnabled:
        _selected != null && _name.text.trim().isNotEmpty && !_locating,
    onSave: _save,
    steps: [
      ParentEditorStep(
        title: 'Name this place',
        nextLabel: 'Choose map position',
        children: [
          LandmarkPhoto(path: widget.photoPath, label: 'Landmark photo'),
          const SizedBox(height: 20),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 60,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Landmark name',
              hintText: 'Red corner shop',
            ),
          ),
          const SizedBox(height: 16),
          const ParentEditorNote(
            message: 'Use a name your child knows.',
            icon: BaseboundIconName.idea,
          ),
        ],
      ),
      ParentEditorStep(
        title: 'Place it on the map',
        children: [
          const ParentEditorNote(
            message: 'Choose a point on the TAURON Arena demo map. Landmarks help recognition; they are not checked safe places or routes.',
            icon: BaseboundIconName.map,
          ),
          const SizedBox(height: 16),
          Text(
            _name.text.trim().isEmpty
                ? 'Add a landmark name before saving.'
                : _name.text.trim(),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          const Text('Tap the map to place or move the pin.'),
          const SizedBox(height: 8),
          OfflinePointPicker(
            key: ValueKey(_pinRevision),
            initialPoint: _selected,
            selectionLabel: 'landmark',
            otherPoints: widget.otherPoints,
            onSelected: (point) {
              if (mounted) setState(() => _selected = point);
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _locating ? null : _useLocation,
            icon: _locating
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const BaseboundIcon(BaseboundIconName.pin),
            label: Text(_locating ? 'Finding location…' : 'Use my location'),
          ),
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Text(
              _locationMessage ??
                  (_selected == null
                      ? 'Choose a pin before saving.'
                      : 'Pin selected. Check it before saving.'),
            ),
          ),
        ],
      ),
    ],
  );
}

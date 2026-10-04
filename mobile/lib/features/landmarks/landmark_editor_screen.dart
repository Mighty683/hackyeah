import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
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
        _locationMessage = kIsWeb
            ? 'Wybrano przykładową pozycję. Sprawdź i popraw znacznik.'
            : 'Znaleziono pozycję. Sprawdź i popraw znacznik.';
      });
    } on LandmarkLocationException catch (error) {
      if (mounted) setState(() => _locationMessage = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _locationMessage =
              'Nie udało się znaleźć pozycji. Wybierz znacznik ręcznie.',
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
      isDemo: kIsWeb || (widget.landmark?.isDemo ?? false),
    ),
  );

  @override
  Widget build(BuildContext context) => ParentEditorScaffold(
    title: widget.landmark == null
        ? 'Dodaj punkt orientacyjny'
        : 'Edytuj punkt orientacyjny',
    saveLabel: 'Zapisz punkt orientacyjny',
    saveEnabled:
        _selected != null && _name.text.trim().isNotEmpty && !_locating,
    onSave: _save,
    steps: [
      ParentEditorStep(
        title: 'Nazwij to miejsce',
        nextLabel: 'Wybierz pozycję na mapie',
        children: [
          LandmarkPhoto(
            path: widget.photoPath,
            label: 'Zdjęcie punktu orientacyjnego',
            height: 216,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 60,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Nazwa punktu orientacyjnego',
              hintText: 'Czerwony sklep na rogu',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: BaseboundIcon(BaseboundIconName.pin, size: 24),
            ),
          ),
          const SizedBox(height: 16),
          const ParentEditorNote(
            message: 'Użyj nazwy znanej dziecku.',
            icon: BaseboundIconName.idea,
          ),
        ],
      ),
      ParentEditorStep(
        title: 'Zaznacz miejsce na mapie',
        children: [
          Text(
            _name.text.trim().isEmpty
                ? 'Dodaj nazwę punktu przed zapisaniem.'
                : _name.text.trim(),
            style: const TextStyle(
              color: BaseboundColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Dotknij mapy, aby dodać lub przesunąć znacznik.'),
          const SizedBox(height: 16),
          OfflinePointPicker(
            key: ValueKey(_pinRevision),
            initialPoint: _selected,
            selectionPhotoPath: widget.photoPath,
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
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const BaseboundIcon(BaseboundIconName.pin, size: 24),
            label: Text(
              _locating
                  ? (kIsWeb
                        ? 'Wybieranie przykładowej pozycji…'
                        : 'Szukanie pozycji…')
                  : (kIsWeb
                        ? 'Użyj przykładowej pozycji'
                        : 'Użyj mojej pozycji'),
            ),
          ),
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ExcludeSemantics(
                  child: BaseboundIcon(BaseboundIconName.pin, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _locationMessage ??
                        (_selected == null
                            ? 'Wybierz znacznik przed zapisaniem.'
                            : 'Znacznik wybrany. Sprawdź go przed zapisaniem.'),
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
          const SizedBox(height: 24),
          const ParentEditorNote(
            message: 'Wybierz punkt na mapie TAURON Areny. Użyj zdjęcia, które dziecko rozpoznaje.',
            icon: BaseboundIconName.map,
          ),
        ],
      ),
    ],
  );
}

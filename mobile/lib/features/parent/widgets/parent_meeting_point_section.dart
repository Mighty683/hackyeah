import 'package:flutter/material.dart';

import '../../../ui/basebound_icons.dart';
import '../../../ui/parent_setup_ui.dart';

import '../../landmarks/data/landmark.dart';
import '../../landmarks/data/landmark_repository.dart';
import '../../landmarks/widgets/landmark_photo.dart';
import '../../mission/lost_landmarks.dart';
import '../data/family_plan.dart';
import 'parent_setup_layout.dart';

class ParentMeetingPointSection extends StatelessWidget {
  const ParentMeetingPointSection({
    required this.point,
    required this.refreshRevision,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final PracticeMeetingPoint? point;
  final int refreshRevision;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final point = this.point;
    final preset = resolveLostLandmark(point?.presetId ?? 'fountain');
    final unknownPreset = point != null && point.presetId != preset.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ParentSetupHeading(
          'A meeting point for lost practice',
          BaseboundIconName.pin,
        ),
        const Text(
          'Choose a saved photo place. Your child will recognize the same '
          'photo and find its pin on Our map.',
          style: parentSetupSubtitleStyle,
        ),
        const SizedBox(height: 16),
        if (point == null)
          const ParentEditorNote(
            message: 'No meeting point chosen. Choose a saved photo place, or explicitly use a demo picture.',
            icon: BaseboundIconName.info,
          )
        else if (point.landmarkId != null)
          _SavedPhotoMeetingPoint(
            point: point,
            refreshRevision: refreshRevision,
            onEdit: onEdit,
            onDelete: onDelete,
          )
        else ...[
          Center(
            child: LostLandmarkIllustration(presetId: point.presetId, size: 80),
          ),
          const SizedBox(height: 8),
          ParentSetupEntry(
            title: unknownPreset
                ? 'Pretend fountain'
                : point.label.trim().isEmpty
                ? preset.label
                : point.label,
            subtitle: 'Pretend practice picture. Tap to choose a photo place.',
            onEdit: onEdit,
            onDelete: onDelete,
            icon: BaseboundIconName.pin,
          ),
          if (unknownPreset)
            const ParentEditorNote(
              message: 'The saved picture is unavailable. A pretend Fountain is shown. Edit to choose a new picture.',
              icon: BaseboundIconName.info,
            ),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: const BaseboundIcon(BaseboundIconName.edit),
          label: Text(
            point == null
                ? 'Add a practice meeting point'
                : 'Edit practice meeting point',
          ),
        ),
      ],
    );
  }
}

class _SavedPhotoMeetingPoint extends StatefulWidget {
  const _SavedPhotoMeetingPoint({
    required this.point,
    required this.refreshRevision,
    required this.onEdit,
    required this.onDelete,
  });

  final PracticeMeetingPoint point;
  final int refreshRevision;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_SavedPhotoMeetingPoint> createState() =>
      _SavedPhotoMeetingPointState();
}

class _SavedPhotoMeetingPointState extends State<_SavedPhotoMeetingPoint> {
  late Future<({Landmark? place, String directory})> _photo =
      _readMeetingPointPhoto();

  @override
  void didUpdateWidget(covariant _SavedPhotoMeetingPoint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.point.landmarkId != widget.point.landmarkId ||
        oldWidget.refreshRevision != widget.refreshRevision) {
      _photo = _readMeetingPointPhoto();
    }
  }

  Future<({Landmark? place, String directory})> _readMeetingPointPhoto() async {
    final id = widget.point.landmarkId;
    final repository = LandmarkRepository();
    final places = await repository.load();
    final directory = await repository.photoDirectory();
    return (
      place: places.where((place) => place.id == id).firstOrNull,
      directory: directory.path,
    );
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<({Landmark? place, String directory})>(
        future: _photo,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final place = snapshot.data?.place;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (place != null)
                LandmarkPhoto(
                  fit: BoxFit.contain,
                  path: '${snapshot.data!.directory}/${place.photoName}',
                  label: place.name,
                  height: 140,
                ),
              ParentSetupEntry(
                title: place?.name ?? 'Meeting photo unavailable',
                subtitle: place == null
                    ? 'Choose a saved photo place again.'
                    : 'Saved photo and pin for lost practice.',
                onEdit: widget.onEdit,
                onDelete: widget.onDelete,
                icon: BaseboundIconName.pin,
              ),
            ],
          );
        },
      );
}

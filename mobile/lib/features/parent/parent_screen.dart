/// Guided adult setup for a device-local demo family plan.
library;

import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';

import '../../ui/basebound_ui.dart';
import '../game/location_permission_setup.dart';
import '../mission/practice_launcher.dart';
import '../landmarks/landmark_library_screen.dart';
import '../landmarks/data/landmark_repository.dart';
import 'child_editor_screen.dart';
import 'contact_editor_screen.dart';
import 'data/family_plan.dart';
import 'data/family_plan_repository.dart';
import 'practice_meeting_point_editor_screen.dart';
import 'safe_point_editor_screen.dart';
import '../../ui/parent_setup_ui.dart';
import 'widgets/parent_setup_layout.dart';
import 'widgets/parent_setup_dialogs.dart';
import 'widgets/parent_setup_stages.dart';
import 'widgets/parent_meeting_point_section.dart';

enum _SetupStage { introduction, contacts, safePlaces, ready }

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key, this.locationPermission, this.repository});

  final LocationPermissionSetup? locationPermission;
  final FamilyPlanRepository? repository;

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  late final _repository = widget.repository ?? FamilyPlanRepository();
  late final _locationPermission =
      widget.locationPermission ?? LocationPermissionSetup();
  FamilyPlan? _plan;
  _SetupStage _stage = _SetupStage.introduction;
  int _landmarkRevision = 0;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final plan = await _repository.load();
      if (mounted) setState(() => _plan = plan);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not read saved details. Try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save(FamilyPlan plan) async {
    await _repository.save(plan);
    if (mounted) setState(() => _plan = plan);
  }

  Future<bool?> _openEditor(Widget screen) =>
      Navigator.of(context)
          .push<bool>(MaterialPageRoute<bool>(builder: (_) => screen));

  Future<void> _editChild() async {
    final saved = await _openEditor(
      ChildEditorScreen(
        child: _plan!.child,
        onSave: (child) => _save(_plan!.copyWith(child: child)),
      ),
    );
    if (saved == true && mounted) _goTo(_SetupStage.contacts);
  }

  Future<void> _editContact([int? index]) => _openEditor(
    ContactEditorScreen(
      contact: index == null ? const TrustedContact() : _plan!.contacts[index],
      onSave: (contact) {
        final contacts = [..._plan!.contacts];
        if (index == null) {
          contacts.add(contact);
        } else {
          contacts[index] = contact;
        }
        return _save(_plan!.copyWith(contacts: contacts));
      },
    ),
  );

  Future<void> _editPlace([int? index]) {
    final points = _plan!.safePoints;
    return _openEditor(
      SafePointEditorScreen(
        point: index == null ? null : points[index],
        otherPoints: [
          for (var i = 0; i < points.length; i++)
            if (i != index) points[i],
        ],
        onSave: (point) {
          final updated = [..._plan!.safePoints];
          if (index == null) {
            updated.add(point);
          } else {
            updated[index] = point;
          }
          return _save(_plan!.copyWith(safePoints: updated));
        },
      ),
    );
  }

  Future<void> _editPracticeMeetingPoint() async {
    await _openEditor(
      PracticeMeetingPointEditorScreen(
        point: _plan!.practiceMeetingPoint,
        onSave: (point) => _save(_plan!.copyWith(practiceMeetingPoint: point)),
      ),
    );
    if (mounted) setState(() => _landmarkRevision++);
  }

  Future<void> _openLandmarks() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const LandmarkLibraryScreen()),
    );
    if (mounted) setState(() => _landmarkRevision++);
  }

  void _goTo(_SetupStage stage) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _stage = stage);
  }

  void _back() {
    if (_busy) return;
    if (_stage == _SetupStage.introduction) {
      Navigator.of(context).maybePop();
      return;
    }
    _goTo(_SetupStage.values[_stage.index - 1]);
  }

  Future<void> _delete({
    int? contact,
    int? place,
    bool practiceMeetingPoint = false,
    bool all = false,
  }) async {
    final confirmed = await confirmParentDeletion(
      context,
      all ? 'Delete all saved details?' : 'Delete this entry?',
      all
          ? 'This removes the child details, trusted contacts, safe places, practice meeting point, landmarks, and saved photo copies from this device. It cannot be undone.'
          : 'This removes the entry from this device.',
    );
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    try {
      if (all) {
        await LandmarkRepository().deleteAll();
        await _repository.deleteAll();
        if (mounted) {
          setState(() {
            _plan = const FamilyPlan();
            _stage = _SetupStage.introduction;
            _error = null;
          });
        }
      } else {
        final contacts = [..._plan!.contacts];
        final points = [..._plan!.safePoints];
        if (contact != null) contacts.removeAt(contact);
        if (place != null) points.removeAt(place);
        await _save(
          _plan!.copyWith(
            contacts: contacts,
            safePoints: points,
            clearPracticeMeetingPoint: practiceMeetingPoint,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: parentSetupTheme(),
    child: PopScope(
      canPop: !_busy && _stage == _SetupStage.introduction,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: _appBar(),
        body: SafeArea(child: _body()),
        bottomNavigationBar: _plan != null && _error == null && !_busy
            ? _footer()
            : null,
      ),
    ),
  );

  AppBar _appBar() => AppBar(
    title: const Text('Family setup'),
    leading: IconButton(
      onPressed: _busy ? null : _back,
      icon: const BaseboundIcon(BaseboundIconName.back),
      tooltip: 'Back',
    ),
    actions: [
      PopupMenuButton<String>(
        enabled: !_busy,
        tooltip: 'Setup options',
        onSelected: (value) {
          if (value == 'location') {
            configureParentLocation(context, _locationPermission);
          } else if (value == 'delete') {
            _delete(all: true);
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: 'location',
            child: Text('Map location permission'),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Text('Delete all saved details'),
          ),
        ],
      ),
    ],
  );

  Widget _body() {
    if (_busy) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _loadError();
    if (_plan == null) return const SizedBox.shrink();
    return SingleChildScrollView(
      key: ValueKey(_stage),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Family setup · ${_stage.index + 1} of 4',
                style: parentSetupSubtitleStyle,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_stage.index + 1) / 4,
                minHeight: 4,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: BaseboundColors.border,
                semanticsLabel: 'Family setup, step ${_stage.index + 1} of 4',
              ),
              const SizedBox(height: 24),
              _stageContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loadError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            liveRegion: true,
            child: ParentEditorNote(
              message: _error!,
              icon: BaseboundIconName.alert,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _load,
            icon: const BaseboundIcon(BaseboundIconName.replay, size: 24),
            label: const Text('Retry loading'),
          ),
          const SizedBox(height: 8),
          const Text(
            'You can delete saved details from Setup options.',
            textAlign: TextAlign.center,
            style: parentSetupSubtitleStyle,
          ),
        ],
      ),
    ),
  );

  Widget _stageContent() => switch (_stage) {
    _SetupStage.introduction => ParentIntroductionStage(
      onOpenLandmarks: _openLandmarks,
    ),
    _SetupStage.contacts => ParentContactsStage(
      contacts: _plan!.contacts,
      onAdd: _editContact,
      onEdit: _editContact,
      onDelete: (index) => _delete(contact: index),
    ),
    _SetupStage.safePlaces => ParentPlacesStage(
      points: _plan!.safePoints,
      onAdd: _editPlace,
      onEdit: _editPlace,
      onDelete: (index) => _delete(place: index),
      meetingPoint: ParentMeetingPointSection(
        point: _plan!.practiceMeetingPoint,
        refreshRevision: _landmarkRevision,
        onEdit: _editPracticeMeetingPoint,
        onDelete: () => _delete(practiceMeetingPoint: true),
      ),
    ),
    _SetupStage.ready => ParentReadyStage(
      plan: _plan!,
      onOpenLandmarks: _openLandmarks,
      onReview: () => _goTo(_SetupStage.introduction),
    ),
  };

  Widget _footer() {
    final (label, action) = switch (_stage) {
      _SetupStage.introduction => ('Add child details', _editChild),
      _SetupStage.contacts => (
        _plan!.contacts.isEmpty ? 'Skip contacts' : 'Choose safe places',
        () => _goTo(_SetupStage.safePlaces),
      ),
      _SetupStage.safePlaces => (
        _plan!.safePoints.isEmpty ? 'Skip safe places' : 'Finish setup',
        () => _goTo(_SetupStage.ready),
      ),
      _SetupStage.ready => (
        'Play together',
        () => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => PracticeLauncher(child: _plan!.child),
          ),
        ),
      ),
    };
    return ParentSetupFooter(
      label: label,
      onContinue: action,
      ready: _stage == _SetupStage.ready,
      onSkip: _stage == _SetupStage.introduction
          ? () => _goTo(_SetupStage.contacts)
          : null,
    );
  }
}

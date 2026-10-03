/// Guided adult setup for a device-local demo family plan.
library;

import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';

import '../../ui/basebound_ui.dart';
import '../mission/practice_launcher.dart';
import '../landmarks/landmark_library_screen.dart';
import '../landmarks/data/landmark_repository.dart';
import '../mission/lost_landmarks.dart';
import 'child_editor_screen.dart';
import 'contact_editor_screen.dart';
import 'data/family_plan.dart';
import 'data/family_plan_repository.dart';
import 'practice_meeting_point_editor_screen.dart';
import 'safe_point_editor_screen.dart';
import 'widgets/parent_editor_scaffold.dart';

enum _SetupStage { introduction, contacts, safePlaces, ready }

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  final _repository = FamilyPlanRepository();
  FamilyPlan? _plan;
  _SetupStage _stage = _SetupStage.introduction;
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

  Future<void> _editPracticeMeetingPoint() => _openEditor(
    PracticeMeetingPointEditorScreen(
      point: _plan!.practiceMeetingPoint,
      onSave: (point) => _save(_plan!.copyWith(practiceMeetingPoint: point)),
    ),
  );

  Future<void> _openLandmarks() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const LandmarkLibraryScreen()),
    );
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

  Future<bool> _confirm(String title, String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => Theme(
          data: parentSetupTheme(),
          child: AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: BaseboundColors.coral,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      ) ??
      false;

  Future<void> _delete({
    int? contact,
    int? place,
    bool practiceMeetingPoint = false,
    bool all = false,
  }) async {
    final confirmed = await _confirm(
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
        onSelected: (_) => _delete(all: true),
        itemBuilder: (_) => const [
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
                style: _subtitleStyle,
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
              ..._stageContent(),
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
            style: _subtitleStyle,
          ),
        ],
      ),
    ),
  );

  List<Widget> _stageContent() => switch (_stage) {
    _SetupStage.introduction => _introduction(),
    _SetupStage.contacts => _contacts(),
    _SetupStage.safePlaces => _safePlaces(),
    _SetupStage.ready => _ready(),
  };

  List<Widget> _introduction() => [
    _heading('Set up your family plan', BaseboundIconName.family),
    const Text(
      'Add your child’s details, then contacts and safe places. One step at a time.',
      style: _subtitleStyle,
    ),
    const SizedBox(height: 24),
    const ParentEditorNote(
      message: 'Use fictional personal details for this demo. All details are optional.',
      icon: BaseboundIconName.info,
    ),
    const SizedBox(height: 16),
    const Text(
      'Saved details are encrypted on this device. Anyone using this app can open them. No parent lock or cloud sync.',
      style: _subtitleStyle,
    ),
    const SizedBox(height: 24),
    BaseboundActionTile(
      label: 'Walk together',
      icon: BaseboundIconName.map,
      onPressed: _openLandmarks,
    ),
  ];

  List<Widget> _contacts() {
    final contacts = _plan!.contacts;
    return [
      _heading('Who can your child contact?', BaseboundIconName.family),
      Text(
        'Add up to three trusted adults. ${contacts.length}/3 saved.',
        style: _subtitleStyle,
      ),
      const SizedBox(height: 24),
      for (var index = 0; index < contacts.length; index++)
        _entry(
          title: contacts[index].name.isEmpty
              ? 'Contact ${index + 1}'
              : contacts[index].name,
          subtitle: [
            contacts[index].relationship,
            contacts[index].phone,
          ].where((value) => value.isNotEmpty).join(' · '),
          onEdit: () => _editContact(index),
          onDelete: () => _delete(contact: index),
          icon: BaseboundIconName.adult,
        ),
      if (contacts.length < FamilyPlan.maxContacts)
        BaseboundActionTile(
          label: 'Add a trusted contact',
          icon: BaseboundIconName.addAdult,
          onPressed: _editContact,
        ),
      const SizedBox(height: 24),
      const Text(
        'Saving a contact does not call or verify the number.',
        style: _subtitleStyle,
      ),
    ];
  }

  List<Widget> _safePlaces() {
    final points = _plan!.safePoints;
    return [
      _heading('Choose your child’s safe places', BaseboundIconName.pin),
      const Text(
        'Choose destinations for your family’s emergency plan.',
        style: _subtitleStyle,
      ),
      const SizedBox(height: 16),
      const ParentEditorNote(
        message: 'This demo stores map pins only. It does not check safety or provide real emergency routes.',
        icon: BaseboundIconName.info,
      ),
      const SizedBox(height: 24),
      for (var index = 0; index < points.length; index++)
        _entry(
          title: points[index].displayName,
          subtitle: 'Tap to edit this safe place.',
          onEdit: () => _editPlace(index),
          onDelete: () => _delete(place: index),
          icon: BaseboundIconName.pin,
        ),
      BaseboundActionTile(
        label: 'Add a safe place',
        icon: BaseboundIconName.addPlace,
        onPressed: _editPlace,
      ),
      const SizedBox(height: 28),
      ..._practiceMeetingPoint(),
    ];
  }

  List<Widget> _practiceMeetingPoint() {
    final point = _plan!.practiceMeetingPoint;
    final preset = resolveLostLandmark(point?.presetId ?? 'fountain');
    final unknownPreset = point != null && point.presetId != preset.id;
    return [
      _heading('A meeting point for lost practice', BaseboundIconName.pin),
      const Text(
        'Choose an illustration and a name your child can recognize. '
        'This is separate from map pins.',
        style: _subtitleStyle,
      ),
      const SizedBox(height: 16),
      if (point == null)
        const ParentEditorNote(
          message: 'No practice meeting point saved. Lost practice uses a pretend Fountain.',
          icon: BaseboundIconName.info,
        )
      else ...[
        Center(
          child: LostLandmarkIllustration(presetId: point.presetId, size: 80),
        ),
        const SizedBox(height: 8),
        _entry(
          title: unknownPreset
              ? 'Pretend fountain'
              : point.label.trim().isEmpty
              ? preset.label
              : point.label,
          subtitle: 'Bundled practice picture. Tap to edit.',
          onEdit: _editPracticeMeetingPoint,
          onDelete: () => _delete(practiceMeetingPoint: true),
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
        onPressed: _editPracticeMeetingPoint,
        icon: const BaseboundIcon(BaseboundIconName.edit),
        label: Text(
          point == null
              ? 'Add a practice meeting point'
              : 'Edit practice meeting point',
        ),
      ),
    ];
  }

  List<Widget> _ready() => [
    _heading('Ready to practice together', BaseboundIconName.check),
    Text(
      '${_plan!.contacts.length} trusted contacts · ${_plan!.safePoints.length} safe places saved',
      style: _subtitleStyle,
    ),
    const SizedBox(height: 24),
    ParentEditorNote(
      message: _plan!.safePoints.isEmpty
          ? 'No safe place chosen. Add a place or explore Our map.'
          : 'Your saved places are available on Our map.',
      icon: BaseboundIconName.play,
    ),
    const SizedBox(height: 16),
    const Text(
      'Training only. Saved safe places are not verified. No real emergency navigation or assistance.',
      style: _subtitleStyle,
    ),
    const SizedBox(height: 16),
    const Text(
      'Lost practice uses a saved landmark or a pretend Fountain. '
      'Calls, replies and safety confirmation are simulated. No message is sent.',
      style: _subtitleStyle,
    ),
    const SizedBox(height: 24),
    BaseboundActionTile(
      label: 'Walk together',
      icon: BaseboundIconName.map,
      onPressed: _openLandmarks,
    ),
    const SizedBox(height: 12),
    BaseboundActionTile(
      label: 'Review setup',
      icon: BaseboundIconName.edit,
      onPressed: () => _goTo(_SetupStage.introduction),
    ),
  ];

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
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: BaseboundColors.border)),
      ),
      child: SafeArea(top: false, child: _footerLayout(label, action)),
    );
  }

  Widget _footerLayout(String label, VoidCallback action) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
    child: Align(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: _footerActions(label, action),
      ),
    ),
  );

  Widget _footerActions(String label, VoidCallback action) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FilledButton.icon(
        onPressed: action,
        icon: BaseboundIcon(
          _stage == _SetupStage.ready
              ? BaseboundIconName.play
              : BaseboundIconName.next,
          color: Colors.white,
          size: 24,
        ),
        label: Text(label, textAlign: TextAlign.center),
      ),
      if (_stage == _SetupStage.introduction)
        TextButton(
          onPressed: () => _goTo(_SetupStage.contacts),
          child: const Text('Skip child details'),
        ),
    ],
  );

  Widget _heading(String title, BaseboundIconName icon) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: BaseboundIcon(icon, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                height: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  static const _subtitleStyle = TextStyle(
    fontFamily: 'Nunito',
    color: BaseboundColors.muted,
    fontSize: 16,
    height: 1.4,
  );

  Widget _entry({
    required String title,
    required String subtitle,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required BaseboundIconName icon,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Expanded(
          child: BaseboundActionTile(
            label: title,
            description: subtitle.isEmpty ? null : subtitle,
            icon: icon,
            onPressed: onEdit,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onDelete,
          icon: const BaseboundIcon(BaseboundIconName.delete, size: 24),
          tooltip: 'Delete $title',
        ),
      ],
    ),
  );
}

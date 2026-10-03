/// Guided adult setup for a device-local demo family plan.
library;

import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';

import '../../ui/basebound_ui.dart';
import '../mission/practice_launcher.dart';
import 'child_editor_screen.dart';
import 'contact_editor_screen.dart';
import 'data/family_plan.dart';
import 'data/family_plan_repository.dart';
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

  Future<void> _delete({int? contact, int? place, bool all = false}) async {
    final confirmed = await _confirm(
      all ? 'Delete all saved details?' : 'Delete this entry?',
      all
          ? 'This removes the child details, trusted contacts, and safe places from this device. It cannot be undone.'
          : 'This removes the entry from this device.',
    );
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    try {
      if (all) {
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
        await _save(_plan!.copyWith(contacts: contacts, safePoints: points));
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
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
            icon: const BaseboundIcon(BaseboundIconName.replay),
            label: const Text('Retry loading'),
          ),
          const SizedBox(height: 8),
          const Text('You can delete saved details from Setup options.'),
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
  ];

  List<Widget> _contacts() {
    final contacts = _plan!.contacts;
    return [
      _heading('Who can your child contact?', BaseboundIconName.family),
      Text(
        'Add up to three trusted adults. ${contacts.length}/3 saved.',
        style: _subtitleStyle,
      ),
      const SizedBox(height: 20),
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
        OutlinedButton.icon(
          onPressed: _editContact,
          icon: const BaseboundIcon(BaseboundIconName.addAdult),
          label: const Text('Add a trusted contact'),
        ),
      const SizedBox(height: 20),
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
      const SizedBox(height: 20),
      for (var index = 0; index < points.length; index++)
        _entry(
          title: points[index].displayName,
          subtitle: 'Tap to edit this safe place.',
          onEdit: () => _editPlace(index),
          onDelete: () => _delete(place: index),
          icon: BaseboundIconName.pin,
        ),
      OutlinedButton.icon(
        onPressed: _editPlace,
        icon: const BaseboundIcon(BaseboundIconName.addPlace),
        label: const Text('Add a safe place'),
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
          ? 'No safe place chosen. The map game uses a pretend base.'
          : 'The map game picks one saved safe place at random for training.',
      icon: BaseboundIconName.play,
    ),
    const SizedBox(height: 16),
    const Text(
      'Training only. Saved safe places are not verified. No real emergency navigation or assistance.',
      style: _subtitleStyle,
    ),
    const SizedBox(height: 24),
    OutlinedButton.icon(
      onPressed: () => _goTo(_SetupStage.introduction),
      icon: const BaseboundIcon(BaseboundIconName.edit),
      label: const Text('Review setup'),
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
          MaterialPageRoute<void>(builder: (_) => const PracticeLauncher()),
        ),
      ),
    };
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: action,
              style: FilledButton.styleFrom(minimumSize: const Size(48, 58)),
              icon: BaseboundIcon(
                _stage == _SetupStage.ready
                    ? BaseboundIconName.play
                    : BaseboundIconName.next,
                color: Colors.white,
              ),
              label: Text(label),
            ),
            if (_stage == _SetupStage.introduction)
              TextButton(
                onPressed: () => _goTo(_SetupStage.contacts),
                child: const Text('Skip child details'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _heading(String title, BaseboundIconName icon) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BaseboundIcon(icon, size: 32, color: BaseboundColors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                height: 1.2,
                fontWeight: FontWeight.w800,
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
  }) => Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: BaseboundIcon(icon, color: BaseboundColors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      onTap: onEdit,
      trailing: IconButton(
        onPressed: onDelete,
        icon: const BaseboundIcon(BaseboundIconName.delete),
        tooltip: 'Delete $title',
      ),
    ),
  );
}

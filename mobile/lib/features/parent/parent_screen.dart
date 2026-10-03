/// Adult-only setup navigation for a device-local demo family plan.
library;

import 'package:flutter/material.dart';

import '../../ui/basebound_ui.dart';
import '../mission/practice_launcher.dart';
import 'child_editor_screen.dart';
import 'contact_editor_screen.dart';
import 'data/family_plan.dart';
import 'data/family_plan_repository.dart';
import 'safe_point_editor_screen.dart';
import 'widgets/parent_editor_scaffold.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  final _repository = FamilyPlanRepository();
  FamilyPlan? _plan;
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
        setState(
          () => _error = 'Could not read saved details. Retry, or delete them to start fresh.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save(FamilyPlan plan) async {
    await _repository.save(plan);
    if (mounted) setState(() => _plan = plan);
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  void _editChild() {
    _open(
      ChildEditorScreen(
        child: _plan!.child,
        onSave: (child) => _save(_plan!.copyWith(child: child)),
      ),
    );
  }

  void _editContact([int? index]) {
    _open(
      ContactEditorScreen(
        contact: index == null
            ? const TrustedContact()
            : _plan!.contacts[index],
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
  }

  void _editPlace([int? index]) {
    final points = _plan!.safePoints;
    _open(
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

  Future<bool> _confirm(String title, String message) async {
    return await showDialog<bool>(
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
  }

  Future<void> _delete({int? contact, int? place, bool all = false}) async {
    final confirmed = await _confirm(
      all ? 'Delete all saved details?' : 'Delete this entry?',
      all
          ? 'This removes the child details, trusted contacts, and places from this device. It cannot be undone.'
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
  Widget build(BuildContext context) {
    return Theme(
      data: parentSetupTheme(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Parent setup')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SoftPanel(
                      borderColor: BaseboundColors.border,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Set up practice together',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              color: BaseboundColors.ink,
                              fontSize: 28,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 18),
                          ParentEditorNote(
                            message:
                                'Use fictional personal details for this demo. Saved details are encrypted on this device, '
                                'but anyone using the app can open them. There is no parent lock or cloud sync.',
                            icon: Icons.lock_outline_rounded,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_busy)
                      const ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          color: BaseboundColors.blue,
                          backgroundColor: BaseboundColors.sky,
                        ),
                      ),
                    if (_error != null) ...[
                      Semantics(
                        liveRegion: true,
                        child: ParentEditorNote(
                          message: _error!,
                          icon: Icons.error_outline_rounded,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _load,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry loading'),
                      ),
                    ],
                    if (_plan != null) ..._setupSections(),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : () => _delete(all: true),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: BaseboundColors.coral,
                        side: const BorderSide(color: BaseboundColors.coral),
                        minimumSize: const Size(48, 56),
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete all saved details'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Practice only. No real routes, verified safe places, or emergency assistance.',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: BaseboundColors.muted,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _setupSections() {
    final plan = _plan!;
    return [
      _sectionTitle('Child', Icons.face_outlined),
      _setupCard(
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: _entryIcon(Icons.face_outlined),
          title: Text(
            plan.child.fullName.isEmpty ? 'Child details' : plan.child.fullName,
          ),
          subtitle: const Text(
            'Name, age, address, and support needs — optional',
          ),
          trailing: const Icon(Icons.edit_outlined),
          titleTextStyle: _entryTitleStyle,
          subtitleTextStyle: _entrySubtitleStyle,
          onTap: _busy ? null : _editChild,
        ),
      ),
      _sectionTitle(
        'Trusted contacts (${plan.contacts.length}/3)',
        Icons.people_outline_rounded,
      ),
      for (var index = 0; index < plan.contacts.length; index++)
        _entry(
          title: plan.contacts[index].name.isEmpty
              ? 'Contact ${index + 1}'
              : plan.contacts[index].name,
          subtitle: [
            plan.contacts[index].relationship,
            plan.contacts[index].phone,
          ].where((value) => value.isNotEmpty).join(' · '),
          onEdit: () => _editContact(index),
          onDelete: () => _delete(contact: index),
          icon: Icons.person_outline_rounded,
        ),
      if (plan.contacts.length < FamilyPlan.maxContacts)
        OutlinedButton.icon(
          onPressed: _busy ? null : _editContact,
          icon: const Icon(Icons.person_add_outlined),
          label: const Text('Add trusted contact'),
        ),
      _sectionTitle('Practice places', Icons.place_outlined),
      const Text(
        'Choose named pins in the offline Kraków demo area. Each new game randomly picks one.',
        style: TextStyle(
          fontFamily: 'Nunito',
          color: BaseboundColors.muted,
          fontSize: 16,
          height: 1.4,
        ),
      ),
      const SizedBox(height: 10),
      for (var index = 0; index < plan.safePoints.length; index++)
        _entry(
          title: plan.safePoints[index].displayName,
          subtitle:
              '${plan.safePoints[index].latitude.toStringAsFixed(5)}, '
              '${plan.safePoints[index].longitude.toStringAsFixed(5)}',
          onEdit: () => _editPlace(index),
          onDelete: () => _delete(place: index),
          icon: Icons.place_outlined,
        ),
      OutlinedButton.icon(
        onPressed: _busy ? null : _editPlace,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add a practice place'),
      ),
      const SizedBox(height: 24),
      FilledButton.icon(
        onPressed: _busy ? null : () => _open(const PracticeLauncher()),
        style: FilledButton.styleFrom(
          backgroundColor: BaseboundColors.blue,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 58),
          padding: const EdgeInsets.all(18),
        ),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Play together'),
      ),
    ];
  }

  Widget _sectionTitle(String title, IconData icon) => Padding(
    padding: const EdgeInsets.only(top: 26, bottom: 12),
    child: Row(
      children: [
        Icon(icon, size: 24, color: BaseboundColors.ink),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Nunito',
              color: BaseboundColors.ink,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );

  static const _entryTitleStyle = TextStyle(
    fontFamily: 'Nunito',
    color: BaseboundColors.ink,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static const _entrySubtitleStyle = TextStyle(
    fontFamily: 'Nunito',
    color: BaseboundColors.muted,
    fontSize: 14,
    height: 1.4,
  );

  Widget _entryIcon(IconData icon) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: BaseboundColors.sky,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Icon(icon, color: BaseboundColors.ink, size: 24),
  );

  Widget _setupCard({required Widget child}) => Card(
    color: Colors.white,
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 12),
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: const BorderSide(color: BaseboundColors.border),
    ),
    child: child,
  );

  Widget _entry({
    required String title,
    required String subtitle,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required IconData icon,
  }) => _setupCard(
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: _entryIcon(icon),
      title: Text(title),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      titleTextStyle: _entryTitleStyle,
      subtitleTextStyle: _entrySubtitleStyle,
      onTap: _busy ? null : onEdit,
      trailing: IconButton(
        onPressed: _busy ? null : onDelete,
        color: BaseboundColors.muted,
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Delete $title',
      ),
    ),
  );
}

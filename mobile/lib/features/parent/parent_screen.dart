/// Adult-only setup navigation for a device-local demo family plan.
library;

import 'package:flutter/material.dart';

import '../mission/practice_launcher.dart';
import 'child_editor_screen.dart';
import 'contact_editor_screen.dart';
import 'data/family_plan.dart';
import 'data/family_plan_repository.dart';
import 'safe_point_editor_screen.dart';

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
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
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
    return Scaffold(
      appBar: AppBar(title: const Text('Parent setup')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Set up practice together',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Text(
                'Use fictional personal details for this demo. Saved details are encrypted on this device, '
                'but anyone using the app can open them. There is no parent lock or cloud sync.',
              ),
              const SizedBox(height: 20),
              if (_busy) const LinearProgressIndicator(),
              if (_error != null) ...[
                Semantics(liveRegion: true, child: Text(_error!)),
                TextButton(
                  onPressed: _busy ? null : _load,
                  child: const Text('Retry loading'),
                ),
              ],
              if (_plan != null) ..._setupSections(),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _delete(all: true),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete all saved details'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Practice only. No real routes, verified safe places, or emergency assistance.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _setupSections() {
    final plan = _plan!;
    return [
      _sectionTitle('Child'),
      Card(
        child: ListTile(
          leading: const Icon(Icons.face_outlined),
          title: Text(
            plan.child.fullName.isEmpty ? 'Child details' : plan.child.fullName,
          ),
          subtitle: const Text(
            'Name, age, address, and support needs — optional',
          ),
          trailing: const Icon(Icons.edit_outlined),
          onTap: _busy ? null : _editChild,
        ),
      ),
      _sectionTitle('Trusted contacts (${plan.contacts.length}/3)'),
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
        ),
      if (plan.contacts.length < FamilyPlan.maxContacts)
        OutlinedButton.icon(
          onPressed: _busy ? null : _editContact,
          icon: const Icon(Icons.person_add_outlined),
          label: const Text('Add trusted contact'),
        ),
      _sectionTitle('Practice places'),
      const Text(
        'Choose named pins in the offline Kraków demo area. Each new game randomly picks one.',
      ),
      for (var index = 0; index < plan.safePoints.length; index++)
        _entry(
          title: plan.safePoints[index].displayName,
          subtitle:
              '${plan.safePoints[index].latitude.toStringAsFixed(5)}, '
              '${plan.safePoints[index].longitude.toStringAsFixed(5)}',
          onEdit: () => _editPlace(index),
          onDelete: () => _delete(place: index),
        ),
      OutlinedButton.icon(
        onPressed: _busy ? null : _editPlace,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add a practice place'),
      ),
      const SizedBox(height: 24),
      FilledButton.icon(
        onPressed: _busy ? null : () => _open(const PracticeLauncher()),
        style: FilledButton.styleFrom(padding: const EdgeInsets.all(18)),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Play together'),
      ),
    ];
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(
      title,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
    ),
  );

  Widget _entry({
    required String title,
    required String subtitle,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) => Card(
    child: ListTile(
      title: Text(title),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      onTap: _busy ? null : onEdit,
      trailing: IconButton(
        onPressed: _busy ? null : onDelete,
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Delete $title',
      ),
    ),
  );
}

/// Parent-entered contact details; storage alone does not establish a working call.
library;

import 'package:flutter/material.dart';

import 'data/family_plan.dart';
import 'widgets/parent_editor_scaffold.dart';

class ContactEditorScreen extends StatefulWidget {
  const ContactEditorScreen({
    required this.contact,
    required this.onSave,
    super.key,
  });

  final TrustedContact contact;
  final Future<void> Function(TrustedContact) onSave;

  @override
  State<ContactEditorScreen> createState() => _ContactEditorScreenState();
}

class _ContactEditorScreenState extends State<ContactEditorScreen> {
  late final _name = TextEditingController(text: widget.contact.name);
  late final _phone = TextEditingController(text: widget.contact.phone);
  late final _relationship = TextEditingController(
    text: widget.contact.relationship,
  );

  @override
  void dispose() {
    for (final controller in [_name, _phone, _relationship]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() => widget.onSave(
    TrustedContact(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      relationship: _relationship.text.trim(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ParentEditorScaffold(
      title: 'Trusted contact',
      onSave: _save,
      children: [
        const Text('All fields are optional. This screen does not make calls.'),
        const SizedBox(height: 24),
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Name (optional)'),
          textCapitalization: TextCapitalization.words,
          maxLength: 100,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phone,
          decoration: const InputDecoration(
            labelText: 'Phone number (optional)',
          ),
          keyboardType: TextInputType.phone,
          maxLength: 30,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _relationship,
          decoration: const InputDecoration(
            labelText: 'Relationship to child (optional)',
            hintText: 'Parent, grandparent, family friend…',
          ),
          textCapitalization: TextCapitalization.words,
          maxLength: 80,
        ),
      ],
    );
  }
}

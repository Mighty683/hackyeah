/// Parent-entered contact details; storage alone does not establish a working call.
library;

import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';

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
      illustration: ParentEditorArt.contact,
      saveLabel: 'Save trusted contact',
      steps: [
        ParentEditorStep(
          title: 'Who can your child contact?',
          nextLabel: 'Add phone number',
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Name (optional)',
                prefixIcon: BaseboundIcon(BaseboundIconName.adult, size: 24),
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: 100,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            const ParentEditorNote(
              message: 'All details are optional. Use fictional details for the demo.',
              icon: BaseboundIconName.info,
            ),
          ],
        ),
        ParentEditorStep(
          title: 'What is their phone number?',
          nextLabel: 'Add relationship',
          children: [
            TextField(
              controller: _phone,
              decoration: const InputDecoration(
                labelText: 'Phone number (optional)',
                prefixIcon: BaseboundIcon(BaseboundIconName.phone, size: 24),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 30,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            const ParentEditorNote(
              message: 'Saving a contact does not check or call this number.',
              icon: BaseboundIconName.phone,
            ),
          ],
        ),
        ParentEditorStep(
          title: 'How do they know your child?',
          children: [
            TextField(
              controller: _relationship,
              decoration: const InputDecoration(
                labelText: 'Relationship to child (optional)',
                hintText: 'Parent, grandparent, family friend…',
                prefixIcon: BaseboundIcon(BaseboundIconName.family, size: 24),
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: 80,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ],
    );
  }
}

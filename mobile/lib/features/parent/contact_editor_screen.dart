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
      title: 'Zaufany kontakt',
      onSave: _save,
      saveLabel: 'Zapisz zaufany kontakt',
      steps: [
        ParentEditorStep(
          title: 'Z kim dziecko może się skontaktować?',
          nextLabel: 'Dodaj numer telefonu',
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Imię (opcjonalnie)',
                prefixIcon: BaseboundIcon(BaseboundIconName.adult, size: 24),
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: 100,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            const ParentEditorNote(
              message: 'Wszystkie dane są opcjonalne. W demo używaj fikcyjnych danych.',
              icon: BaseboundIconName.info,
            ),
          ],
        ),
        ParentEditorStep(
          title: 'Jaki jest numer telefonu tej osoby?',
          nextLabel: 'Dodaj relację',
          children: [
            TextField(
              controller: _phone,
              decoration: const InputDecoration(
                labelText: 'Numer telefonu (opcjonalnie)',
                prefixIcon: BaseboundIcon(BaseboundIconName.phone, size: 24),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 30,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            const ParentEditorNote(
              message: 'Zapisanie kontaktu nie sprawdza numeru ani nie wykonuje połączenia.',
              icon: BaseboundIconName.phone,
            ),
          ],
        ),
        ParentEditorStep(
          title: 'Kim ta osoba jest dla dziecka?',
          children: [
            TextField(
              controller: _relationship,
              decoration: const InputDecoration(
                labelText: 'Relacja z dzieckiem (opcjonalnie)',
                hintText: 'Rodzic, dziadek, przyjaciel rodziny…',
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

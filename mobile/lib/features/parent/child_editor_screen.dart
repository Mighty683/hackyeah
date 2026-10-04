/// Optional child details for parent setup; no photo capture in this demo.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';

import 'data/family_plan.dart';
import 'widgets/parent_editor_scaffold.dart';

class ChildEditorScreen extends StatefulWidget {
  const ChildEditorScreen({
    required this.child,
    required this.onSave,
    super.key,
  });

  final ChildProfile child;
  final Future<void> Function(ChildProfile) onSave;

  @override
  State<ChildEditorScreen> createState() => _ChildEditorScreenState();
}

class _ChildEditorScreenState extends State<ChildEditorScreen> {
  late final _name = TextEditingController(text: widget.child.fullName);
  late final _age = TextEditingController(
    text: widget.child.age?.toString() ?? '',
  );
  late final _address = TextEditingController(text: widget.child.address);
  late final _notes = TextEditingController(text: widget.child.supportNotes);

  @override
  void dispose() {
    for (final controller in [_name, _age, _address, _notes]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() => widget.onSave(
    ChildProfile(
      fullName: _name.text.trim(),
      age: int.tryParse(_age.text),
      address: _address.text.trim(),
      supportNotes: _notes.text.trim(),
      gender: widget.child.gender,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ParentEditorScaffold(
      title: 'Dane dziecka',
      onSave: _save,
      saveLabel: 'Zapisz dane dziecka',
      steps: [
        ParentEditorStep(
          title: "Jak nazywa się dziecko?",
          nextLabel: "Dodaj wiek dziecka",
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Imię i nazwisko (opcjonalnie)',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                prefixIcon: BaseboundIcon(BaseboundIconName.child, size: 24),
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: 100,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            const Text(
              'Wszystkie dane są opcjonalne. W demo używaj fikcyjnych danych.',
              style: TextStyle(
                color: BaseboundColors.muted,
                fontSize: 16,
                height: 1.45,
              ),
            ),
          ],
        ),
        ParentEditorStep(
          title: 'Ile lat ma dziecko?',
          nextLabel: 'Dodaj adres domu',
          children: [
            TextField(
              controller: _age,
              decoration: const InputDecoration(
                labelText: 'Wiek (opcjonalnie)',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                prefixIcon: BaseboundIcon(BaseboundIconName.birthday, size: 24),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 2,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
        ParentEditorStep(
          title: "Jaki jest adres domu dziecka?",
          nextLabel: 'Dodaj potrzeby wsparcia',
          children: [
            TextField(
              controller: _address,
              decoration: const InputDecoration(
                labelText: 'Adres (opcjonalnie)',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                alignLabelWithHint: true,
                prefixIcon: BaseboundIcon(BaseboundIconName.home, size: 24),
              ),
              textCapitalization: TextCapitalization.words,
              minLines: 1,
              maxLines: 3,
              maxLength: 250,
            ),
          ],
        ),
        ParentEditorStep(
          title: 'Jakiego wsparcia potrzebuje dziecko?',
          children: [
            TextField(
              controller: _notes,
              decoration: const InputDecoration(
                labelText: 'Potrzeby wsparcia (opcjonalnie)',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                alignLabelWithHint: true,
                prefixIcon: BaseboundIcon(BaseboundIconName.heart, size: 24),
              ),
              textCapitalization: TextCapitalization.sentences,
              minLines: 3,
              maxLines: 5,
              maxLength: 500,
            ),
          ],
        ),
      ],
    );
  }
}

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
      title: 'Child details',
      onSave: _save,
      illustration: ParentEditorArt.child,
      saveLabel: 'Save child details',
      steps: [
        ParentEditorStep(
          title: "What is your child's name?",
          nextLabel: "Add child's age",
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Full name (optional)',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                prefixIcon: BaseboundIcon(
                  BaseboundIconName.child,
                  size: 24,
                  color: BaseboundColors.muted,
                  calm: true,
                ),
              ),
              textCapitalization: TextCapitalization.words,
              maxLength: 100,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            const Text(
              'All details are optional. Use fictional details for the demo.',
              style: TextStyle(
                color: BaseboundColors.muted,
                fontSize: 16,
                height: 1.45,
              ),
            ),
          ],
        ),
        ParentEditorStep(
          title: 'How old is your child?',
          nextLabel: 'Add home address',
          children: [
            TextField(
              controller: _age,
              decoration: const InputDecoration(
                labelText: 'Age (optional)',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                prefixIcon: BaseboundIcon(
                  BaseboundIconName.birthday,
                  size: 24,
                  color: BaseboundColors.muted,
                  calm: true,
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 2,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
        ParentEditorStep(
          title: "What is your child's home address?",
          nextLabel: 'Add support needs',
          children: [
            TextField(
              controller: _address,
              decoration: const InputDecoration(
                labelText: 'Address (optional)',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                alignLabelWithHint: true,
                prefixIcon: BaseboundIcon(
                  BaseboundIconName.home,
                  size: 24,
                  color: BaseboundColors.muted,
                  calm: true,
                ),
              ),
              textCapitalization: TextCapitalization.words,
              minLines: 1,
              maxLines: 3,
              maxLength: 250,
            ),
          ],
        ),
        ParentEditorStep(
          title: 'What support does your child need?',
          children: [
            TextField(
              controller: _notes,
              decoration: const InputDecoration(
                labelText: 'Support needs (optional)',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                alignLabelWithHint: true,
                prefixIcon: BaseboundIcon(
                  BaseboundIconName.heart,
                  size: 24,
                  color: BaseboundColors.muted,
                  calm: true,
                ),
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

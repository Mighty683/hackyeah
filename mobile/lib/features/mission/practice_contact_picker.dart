import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import 'scene_object_target.dart';

/// Display-only contact choice shared by the offline training stories.
class PracticeContactChoice {
  const PracticeContactChoice({
    required this.id,
    required this.label,
    required this.avatar,
    this.key,
  });

  final String id;
  final String label;
  final BaseboundIconName avatar;
  final Key? key;
}

/// A pretend phone contact list. Selection only updates the training story.
class PracticeContactPicker extends StatelessWidget {
  const PracticeContactPicker({
    super.key,
    required this.contacts,
    this.selectedId,
    this.onChoose,
  });

  final List<PracticeContactChoice> contacts;
  final String? selectedId;
  final ValueChanged<String>? onChoose;

  @override
  Widget build(BuildContext context) =>
      SingleChildScrollView(child: Center(child: _phone()));

  Widget _phone() => Container(
    constraints: const BoxConstraints(maxWidth: 400),
    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: BaseboundColors.border),
    ),
    child: FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ExcludeSemantics(
            child: BaseboundIcon(BaseboundIconName.family, size: 32),
          ),
          const SizedBox(height: 12),
          const Divider(),
          for (var index = 0; index < contacts.length; index++)
            _contact(contacts[index], index),
          const SizedBox(height: 20),
          Container(width: 64, height: 3, color: BaseboundColors.muted),
        ],
      ),
    ),
  );

  Widget _contact(PracticeContactChoice contact, int index) =>
      FocusTraversalOrder(
        order: NumericFocusOrder(index.toDouble()),
        child: SceneObjectTarget(
          key: contact.key,
          label: contact.label,
          selected: selectedId == contact.id,
          onTap: onChoose == null ? null : () => onChoose!(contact.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                CustomPaint(
                  foregroundPainter: const SceneObjectHalo(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: BaseboundIcon(contact.avatar, size: 40),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    contact.label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

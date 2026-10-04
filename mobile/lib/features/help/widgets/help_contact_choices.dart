import 'package:flutter/material.dart';

import '../../../ui/basebound_icons.dart';
import '../../../ui/basebound_ui.dart';
import '../../parent/data/family_plan.dart';

class HelpContactChoices extends StatelessWidget {
  const HelpContactChoices({required this.contacts, super.key});

  final List<TrustedContact> contacts;

  @override
  Widget build(BuildContext context) => SimpleDialog(
    title: const Text('Otwórz telefon, aby zadzwonić do…'),
    children: [
      for (final (index, contact) in contacts.indexed)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: BaseboundActionTile(
            icon: BaseboundIconName.adult,
            onPressed: () => Navigator.of(context).pop(contact),
            label: contact.name.trim().isNotEmpty
                ? contact.name.trim()
                : contact.relationship.trim().isNotEmpty
                ? contact.relationship.trim()
                : 'Zaufana osoba dorosła ${index + 1}',
          ),
        ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Wróć do pomocy'),
      ),
    ],
  );
}

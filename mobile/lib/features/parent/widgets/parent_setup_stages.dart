import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../ui/basebound_icons.dart';
import '../../../ui/basebound_ui.dart';
import '../../../ui/parent_setup_ui.dart';

import '../data/family_plan.dart';
import 'parent_setup_layout.dart';

class ParentIntroductionStage extends StatelessWidget {
  const ParentIntroductionStage({required this.onOpenLandmarks, super.key});

  final VoidCallback onOpenLandmarks;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ParentSetupHeading('Set up your family plan', BaseboundIconName.family),
      const Text(
        'Add your child’s details, then contacts and safe places. One step at a time.',
        style: parentSetupSubtitleStyle,
      ),
      const SizedBox(height: 24),
      const ParentEditorNote(
        message: 'Use fictional personal details for this demo. All details are optional.',
        icon: BaseboundIconName.info,
      ),
      const SizedBox(height: 16),
      const Text(
        kIsWeb
            ? 'Details stay in this browser tab for this demo. Refresh or reset discards edits. Use fictional details. No encryption, parent lock or cloud sync.'
            : 'Saved details are encrypted on this device. Anyone using this app can open them. No parent lock or cloud sync.',
        style: parentSetupSubtitleStyle,
      ),
      const SizedBox(height: 24),
      BaseboundActionTile(
        label: 'Walk together',
        icon: BaseboundIconName.map,
        onPressed: onOpenLandmarks,
      ),
    ],
  );
}

class ParentContactsStage extends StatelessWidget {
  const ParentContactsStage({
    required this.contacts,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final List<TrustedContact> contacts;
  final VoidCallback onAdd;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ParentSetupHeading(
        'Who can your child contact?',
        BaseboundIconName.family,
      ),
      Text(
        'Add up to three trusted adults. ${contacts.length}/3 saved.',
        style: parentSetupSubtitleStyle,
      ),
      const SizedBox(height: 24),
      for (var index = 0; index < contacts.length; index++)
        ParentSetupEntry(
          title: contacts[index].name.isEmpty
              ? 'Contact ${index + 1}'
              : contacts[index].name,
          subtitle: [
            contacts[index].relationship,
            contacts[index].phone,
          ].where((value) => value.isNotEmpty).join(' · '),
          onEdit: () => onEdit(index),
          onDelete: () => onDelete(index),
          icon: BaseboundIconName.adult,
        ),
      if (contacts.length < FamilyPlan.maxContacts)
        BaseboundActionTile(
          label: 'Add a trusted contact',
          icon: BaseboundIconName.addAdult,
          onPressed: onAdd,
        ),
      const SizedBox(height: 24),
      const Text(
        'Saving a contact does not call or verify the number.',
        style: parentSetupSubtitleStyle,
      ),
    ],
  );
}

class ParentPlacesStage extends StatelessWidget {
  const ParentPlacesStage({
    required this.points,
    required this.meetingPoint,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final List<SafePoint> points;
  final Widget meetingPoint;
  final VoidCallback onAdd;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ParentSetupHeading(
        'Choose your child’s safe places',
        BaseboundIconName.pin,
      ),
      const Text(
        'Choose destinations for your family’s emergency plan.',
        style: parentSetupSubtitleStyle,
      ),
      const SizedBox(height: 16),
      const ParentEditorNote(
        message: 'This demo stores map pins only. It does not check safety or provide real emergency routes.',
        icon: BaseboundIconName.info,
      ),
      const SizedBox(height: 24),
      for (var index = 0; index < points.length; index++)
        ParentSetupEntry(
          title: points[index].displayName,
          subtitle: 'Tap to edit this safe place.',
          onEdit: () => onEdit(index),
          onDelete: () => onDelete(index),
          icon: BaseboundIconName.pin,
        ),
      BaseboundActionTile(
        label: 'Add a safe place',
        icon: BaseboundIconName.addPlace,
        onPressed: onAdd,
      ),
      const SizedBox(height: 28),
      meetingPoint,
    ],
  );
}

class ParentReadyStage extends StatelessWidget {
  const ParentReadyStage({
    required this.plan,
    required this.onOpenLandmarks,
    required this.onReview,
    super.key,
  });

  final FamilyPlan plan;
  final VoidCallback onOpenLandmarks;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ParentSetupHeading('Ready to practice together', BaseboundIconName.check),
      Text(
        '${plan.contacts.length} trusted contacts · ${plan.safePoints.length} safe places saved',
        style: parentSetupSubtitleStyle,
      ),
      const SizedBox(height: 24),
      ParentEditorNote(
        message: plan.safePoints.isEmpty
            ? 'No safe place chosen. Add a place or explore Our map.'
            : 'Your saved places are available on Our map.',
        icon: BaseboundIconName.play,
      ),
      const SizedBox(height: 16),
      const Text(
        'Training only. Saved safe places are not verified. No real emergency navigation or assistance.',
        style: parentSetupSubtitleStyle,
      ),
      const SizedBox(height: 16),
      const Text(
        'Lost practice teaches your selected photo place and its pin on Our map. '
        'Calls, replies and safety confirmation are simulated. No message is sent.',
        style: parentSetupSubtitleStyle,
      ),
      const SizedBox(height: 24),
      BaseboundActionTile(
        label: 'Walk together',
        icon: BaseboundIconName.map,
        onPressed: onOpenLandmarks,
      ),
      const SizedBox(height: 12),
      BaseboundActionTile(
        label: 'Review setup',
        icon: BaseboundIconName.edit,
        onPressed: onReview,
      ),
    ],
  );
}

import 'package:flutter/material.dart';

import '../../../ui/basebound_icons.dart';
import '../../../ui/basebound_ui.dart';
import '../help_flow.dart';

class HelpStepContent extends StatelessWidget {
  const HelpStepContent({
    required this.step,
    required this.page,
    required this.nearbyPlaceName,
    required this.withoutHelper,
    required this.serviceConfirmed,
    required this.showContact,
    required this.showEmergency,
    required this.loadingContacts,
    required this.openingDialler,
    required this.contactsUnavailable,
    required this.phoneStatus,
    required this.onChoose,
    required this.onContactAdult,
    required this.onEmergency,
    super.key,
  });

  final HelpStep step;
  final HelpPage page;
  final String? nearbyPlaceName;
  final bool withoutHelper;
  final bool serviceConfirmed;
  final bool showContact;
  final bool showEmergency;
  final bool loadingContacts;
  final bool openingDialler;
  final bool contactsUnavailable;
  final String? phoneStatus;
  final ValueChanged<HelpPage> onChoose;
  final VoidCallback onContactAdult;
  final VoidCallback onEmergency;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _PrototypeNotice(),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: _buildInstruction(),
        ),
      ),
      if (showEmergency) _buildPhoneActions(),
    ],
  );

  Widget _buildInstruction() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(
        header: true,
        liveRegion: true,
        child: Text(
          step.title,
          style: const TextStyle(
            color: BaseboundColors.ink,
            fontSize: 28,
            height: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      if (step.note != null) ...[
        const SizedBox(height: 12),
        Text(
          step.note!,
          style: const TextStyle(
            color: BaseboundColors.muted,
            fontSize: 18,
            height: 1.4,
          ),
        ),
      ],
      if (nearbyPlaceName case final String place) ...[
        const SizedBox(height: 12),
        Text(
          'You may be near $place. This is a saved place.',
          style: const TextStyle(color: BaseboundColors.muted, fontSize: 16),
        ),
      ],
      const SizedBox(height: 24),
      for (final choice in step.choices) ...[
        _buildChoice(choice),
        const SizedBox(height: 12),
      ],
      if (showContact) ...[
        FilledButton.icon(
          onPressed: loadingContacts || openingDialler ? null : onContactAdult,
          icon: const BaseboundIcon(
            BaseboundIconName.phone,
            color: Colors.white,
            calm: true,
          ),
          label: Text(
            loadingContacts ? 'Reading saved contacts…' : 'Call trusted adult',
          ),
        ),
      ],
      if (step.offerContact && contactsUnavailable) ...[
        const SizedBox(height: 12),
        const Text('Saved contacts could not be read. These steps still work.'),
      ],
      if (phoneStatus != null) ...[
        const SizedBox(height: 12),
        Semantics(
          liveRegion: true,
          child: _HelpInformation(message: phoneStatus!),
        ),
      ],
      if (withoutHelper &&
          !serviceConfirmed &&
          (step.offerContact || step.urgent)) ...[
        const SizedBox(height: 12),
        const _HelpInformation(
          message: 'Phone service is not confirmed. These steps work offline.',
        ),
      ],
      if (withoutHelper && step.choices.length < 3)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () => onChoose(HelpPage.withHelper),
            icon: const BaseboundIcon(BaseboundIconName.adult, calm: true),
            label: const Text('Someone can help now'),
          ),
        ),
    ],
  );

  Widget _buildChoice(HelpChoice choice) {
    if (page == HelpPage.situations) {
      return BaseboundActionTile(
        label: choice.label,
        icon: _situationIcon(choice.next),
        onPressed: () => onChoose(choice.next),
      );
    }
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(16),
      ),
      onPressed: () => onChoose(choice.next),
      child: Row(
        children: [
          Expanded(child: Text(choice.label)),
          const SizedBox(width: 12),
          const BaseboundIcon(
            BaseboundIconName.next,
            color: BaseboundColors.muted,
            calm: true,
          ),
        ],
      ),
    );
  }

  BaseboundIconName _situationIcon(HelpPage page) => switch (page) {
    HelpPage.unresponsive => BaseboundIconName.unresponsive,
    HelpPage.airLocation => BaseboundIconName.alarm,
    HelpPage.lostNoAdult => BaseboundIconName.lost,
    _ => BaseboundIconName.unsure,
  };

  Widget _buildPhoneActions() => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: BaseboundColors.border)),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showContact)
          OutlinedButton.icon(
            onPressed: openingDialler ? null : onEmergency,
            icon: const BaseboundIcon(BaseboundIconName.phone, calm: true),
            label: const Text('Call 112'),
          )
        else
          FilledButton.icon(
            onPressed: openingDialler ? null : onEmergency,
            icon: const BaseboundIcon(
              BaseboundIconName.phone,
              color: Colors.white,
              calm: true,
            ),
            label: Text(step.urgent ? 'Call 112 now' : 'Call 112'),
          ),
        const SizedBox(height: 8),
        const Text(
          'Demo only. Opens a popup. No real call.',
          style: TextStyle(color: BaseboundColors.muted, fontSize: 14),
        ),
      ],
    ),
  );
}

class _PrototypeNotice extends StatelessWidget {
  const _PrototypeNotice();

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(24, 8, 24, 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: BaseboundColors.sky,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: BaseboundColors.border),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BaseboundIcon(
          BaseboundIconName.info,
          color: BaseboundColors.ink,
          size: 24,
          calm: true,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Unreviewed prototype. Not for real emergencies. '
            'Do not make test calls to 112.',
            style: TextStyle(
              color: BaseboundColors.ink,
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _HelpInformation extends StatelessWidget {
  const _HelpInformation({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => SoftPanel(
    padding: const EdgeInsets.all(16),
    color: BaseboundColors.sky,
    child: Text(
      message,
      style: const TextStyle(
        color: BaseboundColors.ink,
        fontSize: 16,
        height: 1.4,
      ),
    ),
  );
}

import 'package:flutter/material.dart';

import '../../../ui/basebound_icons.dart';
import '../../../ui/basebound_ui.dart';

const parentSetupSubtitleStyle = TextStyle(
  fontFamily: 'Nunito',
  color: BaseboundColors.muted,
  fontSize: 16,
  height: 1.4,
);

class ParentSetupHeading extends StatelessWidget {
  const ParentSetupHeading(this.title, this.icon, {super.key});

  final String title;
  final BaseboundIconName icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: BaseboundIcon(icon, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                height: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class ParentSetupEntry extends StatelessWidget {
  const ParentSetupEntry({
    required this.title,
    required this.subtitle,
    required this.onEdit,
    required this.onDelete,
    required this.icon,
    super.key,
  });

  final String title;
  final String subtitle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final BaseboundIconName icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Expanded(
          child: BaseboundActionTile(
            label: title,
            description: subtitle.isEmpty ? null : subtitle,
            icon: icon,
            onPressed: onEdit,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onDelete,
          icon: const BaseboundIcon(BaseboundIconName.delete, size: 24),
          tooltip: 'Delete $title',
        ),
      ],
    ),
  );
}

class ParentSetupFooter extends StatelessWidget {
  const ParentSetupFooter({
    required this.label,
    required this.onContinue,
    required this.ready,
    this.onSkip,
    super.key,
  });

  final String label;
  final VoidCallback onContinue;
  final bool ready;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: BaseboundColors.border)),
    ),
    child: SafeArea(top: false, child: _footerLayout()),
  );

  Widget _footerLayout() => Padding(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
    child: Align(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: _footerActions(),
      ),
    ),
  );

  Widget _footerActions() => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FilledButton.icon(
        onPressed: onContinue,
        icon: BaseboundIcon(
          ready ? BaseboundIconName.play : BaseboundIconName.next,
          color: Colors.white,
          size: 24,
        ),
        label: Text(label, textAlign: TextAlign.center),
      ),
      if (onSkip != null)
        TextButton(onPressed: onSkip, child: const Text('Skip child details')),
    ],
  );
}

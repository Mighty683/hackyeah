/// Separate, offline-first help prototype. No game rewards, hazard detection,
/// verified routing, or claims that a call/message connected or was delivered.
library;

import 'package:flutter/material.dart';

import '../../ui/basebound_ui.dart';
import '../parent/data/family_plan.dart';
import 'help_flow.dart';
import 'help_phone.dart';

class HelpEntryButton extends StatelessWidget {
  const HelpEntryButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    style: OutlinedButton.styleFrom(
      foregroundColor: BaseboundColors.ink,
      backgroundColor: const Color(0xFFF3F6FA),
      side: const BorderSide(color: BaseboundColors.border, width: 1.5),
      minimumSize: const Size(48, 56),
      padding: const EdgeInsets.all(16),
      textStyle: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    onPressed: onPressed ?? () => openHelpScreen(context),
    icon: const Icon(Icons.support_outlined),
    label: const Text('I need help · prototype'),
  );
}

Future<void> openHelpScreen(BuildContext context) =>
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const HelpScreen()));

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key, this.phone});

  final HelpPhone? phone;

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _history = <HelpPage>[HelpPage.situations];
  late final HelpPhone _phone = widget.phone ?? HelpPhone();
  bool _loadingContacts = false;
  int _contactRequest = 0;
  bool _openingDialler = false;
  bool _noSignal = false;
  String? _phoneStatus;

  HelpStep get _step => helpSteps[_history.last]!;

  void _choose(HelpPage page) {
    setState(() {
      _history.add(page);
      _contactRequest++;
      _loadingContacts = false;
      if (page == HelpPage.unresponsiveOffline) _noSignal = true;
      _phoneStatus = null;
    });
  }

  void _back() {
    if (_history.length == 1) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _history.removeLast();
      _contactRequest++;
      _loadingContacts = false;
      _phoneStatus = null;
    });
  }

  Future<void> _dial(String phone) async {
    if (_openingDialler) return;
    setState(() {
      if (phone == '112') {
        _contactRequest++;
        _loadingContacts = false;
      }
      _openingDialler = true;
      _phoneStatus = null;
    });
    try {
      final opened = await _phone.openDialler(phone);
      if (!mounted) return;
      setState(() {
        _phoneStatus = opened
            ? 'Phone app opened. This does not mean a call connected.'
            : 'The phone app could not open. Keep using the offline steps.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _phoneStatus =
            'The phone app could not open. '
            'Keep using the offline steps.';
      });
    } finally {
      if (mounted) setState(() => _openingDialler = false);
    }
  }

  Future<void> _contactAdult() async {
    if (_loadingContacts) return;
    final request = ++_contactRequest;
    setState(() => _loadingContacts = true);
    try {
      final contacts = await _phone.loadContacts();
      if (!mounted || request != _contactRequest) return;
      if (contacts.isEmpty) {
        setState(() {
          _phoneStatus =
              'No usable trusted-adult number is saved. '
              'Ask a grown-up to set one up.';
        });
        return;
      }
      if (contacts.length == 1) {
        await _dial(normalizeTrustedPhone(contacts.single.phone)!);
        return;
      }
      final contact = await showDialog<TrustedContact>(
        context: context,
        builder: (context) => Theme(
          data: BaseboundTheme.help(),
          child: _ContactChoices(contacts: contacts),
        ),
      );
      if (!mounted || request != _contactRequest || contact == null) return;
      await _dial(normalizeTrustedPhone(contact.phone)!);
    } catch (_) {
      if (!mounted || request != _contactRequest) return;
      setState(() {
        _phoneStatus =
            'Saved contacts could not be read. '
            'The offline steps and 112 button are still available.';
      });
    } finally {
      if (mounted && request == _contactRequest) {
        setState(() => _loadingContacts = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: BaseboundTheme.help(),
      child: PopScope<Object?>(
        canPop: _history.length == 1,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _back();
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: _back,
              icon: const Icon(Icons.arrow_back),
              tooltip: _history.length == 1 ? 'Close help' : 'Previous step',
            ),
            title: const Text('Help · prototype'),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: _buildSteps(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSteps() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _PrototypeNotice(),
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: _buildInstruction(),
              ),
            ],
          ),
        ),
      ),
      _buildPhoneActions(),
    ],
  );

  Widget _buildInstruction() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: BaseboundColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              liveRegion: true,
              child: Text(
                _step.title,
                style: const TextStyle(
                  color: BaseboundColors.ink,
                  fontSize: 30,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (_step.note != null) ...[
              const SizedBox(height: 14),
              Text(
                _step.note!,
                style: const TextStyle(
                  color: BaseboundColors.muted,
                  fontSize: 18,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 20),
      for (final choice in _step.choices) ...[
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: BaseboundColors.ink,
            backgroundColor: Colors.white,
            side: const BorderSide(color: BaseboundColors.border, width: 1.5),
            minimumSize: const Size(48, 64),
            padding: const EdgeInsets.all(18),
            textStyle: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            alignment: Alignment.centerLeft,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () => _choose(choice.next),
          child: Row(
            children: [
              if (_history.last == HelpPage.situations) ...[
                Icon(_situationIcon(choice.next), size: 24),
                const SizedBox(width: 14),
              ],
              Expanded(child: Text(choice.label)),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, size: 24),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
      if (_step.offerContact) ...[
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: BaseboundColors.ink,
            backgroundColor: Colors.white,
            side: const BorderSide(color: BaseboundColors.ink),
            minimumSize: const Size(48, 56),
            padding: const EdgeInsets.all(16),
            textStyle: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: _loadingContacts || _openingDialler ? null : _contactAdult,
          icon: const Icon(Icons.phone_outlined),
          label: Text(
            _loadingContacts ? 'Reading saved contacts…' : 'Call trusted adult',
          ),
        ),
      ],
      const SizedBox(height: 12),
      const Text(
        '112 is for urgent help. The button opens your phone app. '
        'No automatic call or SMS.',
        style: TextStyle(
          color: BaseboundColors.muted,
          fontSize: 16,
          height: 1.4,
        ),
      ),
      if (_phoneStatus != null) ...[
        const SizedBox(height: 12),
        Semantics(
          liveRegion: true,
          child: _HelpInformation(message: _phoneStatus!),
        ),
      ],
      if (_noSignal) ...[
        const SizedBox(height: 12),
        const _HelpInformation(
          message:
              'Without phone service, calls and messages cannot connect. '
              'The steps stay available.',
        ),
      ],
      if (!_noSignal && _history.last != HelpPage.unresponsive)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () => setState(() => _noSignal = true),
            icon: const Icon(Icons.signal_cellular_off),
            label: const Text('No phone signal'),
          ),
        ),
    ],
  );

  IconData _situationIcon(HelpPage page) => switch (page) {
    HelpPage.unresponsive => Icons.personal_injury_outlined,
    HelpPage.airLocation => Icons.campaign_outlined,
    HelpPage.lostAdult => Icons.location_searching_rounded,
    _ => Icons.help_outline_rounded,
  };

  Widget _buildPhoneActions() => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: BaseboundColors.border)),
    ),
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: BaseboundColors.ink,
            foregroundColor: Colors.white,
            minimumSize: const Size(48, 56),
            padding: const EdgeInsets.all(16),
            textStyle: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: _openingDialler ? null : () => _dial('112'),
          icon: const Icon(Icons.phone_outlined),
          label: Text(_step.urgent ? 'Call 112 now' : 'Call 112'),
        ),
        const SizedBox(height: 6),
        const Text(
          'Opens phone app.',
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
    width: double.infinity,
    color: const Color(0xFFE4EBF4),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, color: BaseboundColors.ink, size: 20),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Unreviewed prototype. Not for real emergencies. '
            'Do not make test calls to 112.',
            style: TextStyle(
              color: BaseboundColors.ink,
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w700,
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
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF0F7),
      borderRadius: BorderRadius.circular(12),
    ),
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

class _ContactChoices extends StatelessWidget {
  const _ContactChoices({required this.contacts});

  final List<TrustedContact> contacts;

  @override
  Widget build(BuildContext context) => SimpleDialog(
    title: const Text('Choose a trusted adult'),
    children: [
      for (final (index, contact) in contacts.indexed)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(48, 56),
              padding: const EdgeInsets.all(16),
            ),
            onPressed: () => Navigator.of(context).pop(contact),
            child: Text(
              contact.name.trim().isNotEmpty
                  ? contact.name.trim()
                  : contact.relationship.trim().isNotEmpty
                  ? contact.relationship.trim()
                  : 'Trusted adult ${index + 1}',
            ),
          ),
        ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Back to help'),
      ),
    ],
  );
}

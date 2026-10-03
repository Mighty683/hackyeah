/// Separate, offline-first help prototype. No game rewards, hazard detection,
/// verified routing, or claims that a call/message connected or was delivered.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../ui/basebound_ui.dart';
import '../../ui/basebound_icons.dart';
import '../parent/data/family_plan.dart';
import 'help_flow.dart';
import 'help_phone.dart';
import 'help_context.dart';

class HelpEntryButton extends StatelessWidget {
  const HelpEntryButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed ?? () => openHelpScreen(context),
    icon: const BaseboundIcon(BaseboundIconName.help, calm: true),
    label: const Text('I need help · prototype', textAlign: TextAlign.center),
  );
}

Future<void> openHelpScreen(BuildContext context) =>
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const HelpScreen()));

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key, this.phone, this.helpContext});

  final HelpPhone? phone;
  final HelpContext? helpContext;

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> with WidgetsBindingObserver {
  final _history = <HelpPage>[HelpPage.helpers];
  late final HelpPhone _phone = widget.phone ?? HelpPhone();
  late final HelpContext _helpContext = widget.helpContext ?? HelpContext();
  StreamSubscription<HelpPhoneService>? _serviceSubscription;
  int _serviceRevision = 0;
  bool _foreground = true;
  HelpPhoneService _service = HelpPhoneService.unknown;
  List<TrustedContact> _contacts = const [];
  bool _contactsUnavailable = false;
  bool _loadingContacts = false;
  int _contactRequest = 0;
  bool _openingDialler = false;
  String? _phoneStatus;

  HelpStep get _step {
    if (_history.last == HelpPage.unresponsive && !_service.canOfferEmergency) {
      return helpSteps[HelpPage.unresponsiveOffline]!;
    }
    return helpSteps[_history.last]!;
  }

  bool get _withoutHelper => _history.contains(HelpPage.situations);
  bool get _showEmergency =>
      _withoutHelper && _step.offerEmergency && _service.canOfferEmergency;
  bool get _showContact =>
      _withoutHelper &&
      _step.offerContact &&
      _service.canOfferContact &&
      _contacts.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _helpContext.addListener(_contextChanged);
    unawaited(_helpContext.start());
    _watchService();
    unawaited(_readContacts());
  }

  void _contextChanged() {
    if (mounted) setState(() {});
  }

  void _watchService() {
    if (_serviceSubscription != null) return;
    final revision = ++_serviceRevision;
    _serviceSubscription = _phone.serviceStates().listen(
      (service) {
        if (mounted && revision == _serviceRevision) {
          setState(() => _service = service);
        }
      },
      onError: (Object _) {
        if (mounted && revision == _serviceRevision) {
          setState(() => _service = HelpPhoneService.unknown);
        }
      },
      onDone: () {
        if (mounted && revision == _serviceRevision) {
          setState(() => _service = HelpPhoneService.unknown);
        }
      },
    );
  }

  Future<void> _readContacts() async {
    try {
      final contacts = await _phone.loadContacts();
      if (mounted) setState(() => _contacts = contacts);
    } catch (_) {
      if (mounted) setState(() => _contactsUnavailable = true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final foreground = state == AppLifecycleState.resumed;
    if (_foreground == foreground) return;
    _foreground = foreground;
    if (foreground) {
      unawaited(_helpContext.resume());
      _watchService();
      return;
    }
    _helpContext.pause();
    _serviceRevision++;
    unawaited(_serviceSubscription?.cancel());
    _serviceSubscription = null;
    if (mounted) setState(() => _service = HelpPhoneService.unknown);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _serviceRevision++;
    unawaited(_serviceSubscription?.cancel());
    _helpContext.removeListener(_contextChanged);
    _helpContext.dispose();
    super.dispose();
  }

  void _choose(HelpPage page) {
    setState(() {
      _history.add(page);
      _contactRequest++;
      _loadingContacts = false;
      if (page == HelpPage.withHelper) {
        _history
          ..clear()
          ..addAll([HelpPage.helpers, HelpPage.withHelper]);
      }
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
    if (phone == '112' ? !_showEmergency : !_showContact) return;
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
        _phoneStatus = phone == '112'
            ? opened
                  ? 'Demo popup opened. No real call is made.'
                  : 'The demo popup could not open. No call was made.'
            : opened
            ? 'Phone app opened. This does not mean a call connected.'
            : 'The phone app could not open. Keep using the offline steps.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _phoneStatus = phone == '112'
            ? 'The demo popup could not open. No call was made.'
            : 'The phone app could not open. Keep using the offline steps.';
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
      final contacts = _contacts;
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
            'You can still use the offline steps.';
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
              icon: const BaseboundIcon(BaseboundIconName.back, calm: true),
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
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: _buildInstruction(),
        ),
      ),
      if (_showEmergency) _buildPhoneActions(),
    ],
  );

  Widget _buildInstruction() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Semantics(
        header: true,
        liveRegion: true,
        child: Text(
          _step.title,
          style: const TextStyle(
            color: BaseboundColors.ink,
            fontSize: 28,
            height: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      if (_step.note != null) ...[
        const SizedBox(height: 12),
        Text(
          _step.note!,
          style: const TextStyle(
            color: BaseboundColors.muted,
            fontSize: 18,
            height: 1.4,
          ),
        ),
      ],
      if (_helpContext.nearbyPlaceName case final String place) ...[
        const SizedBox(height: 12),
        Text(
          'You may be near $place. This is a saved place.',
          style: const TextStyle(color: BaseboundColors.muted, fontSize: 16),
        ),
      ],
      const SizedBox(height: 24),
      for (final choice in _step.choices) ...[
        _buildChoice(choice),
        const SizedBox(height: 12),
      ],
      if (_showContact) ...[
        FilledButton.icon(
          onPressed: _loadingContacts || _openingDialler ? null : _contactAdult,
          icon: const BaseboundIcon(
            BaseboundIconName.phone,
            color: Colors.white,
            calm: true,
          ),
          label: Text(
            _loadingContacts ? 'Reading saved contacts…' : 'Call trusted adult',
          ),
        ),
      ],
      if (_step.offerContact && _contactsUnavailable) ...[
        const SizedBox(height: 12),
        const Text('Saved contacts could not be read. These steps still work.'),
      ],
      if (_phoneStatus != null) ...[
        const SizedBox(height: 12),
        Semantics(
          liveRegion: true,
          child: _HelpInformation(message: _phoneStatus!),
        ),
      ],
      if (_withoutHelper &&
          !_service.canOfferEmergency &&
          (_step.offerContact || _step.urgent)) ...[
        const SizedBox(height: 12),
        const _HelpInformation(
          message: 'Phone service is not confirmed. These steps work offline.',
        ),
      ],
      if (_withoutHelper && _step.choices.length < 3)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () => _choose(HelpPage.withHelper),
            icon: const BaseboundIcon(BaseboundIconName.adult, calm: true),
            label: const Text('Someone can help now'),
          ),
        ),
    ],
  );

  Widget _buildChoice(HelpChoice choice) {
    if (_history.last == HelpPage.situations) {
      return BaseboundActionTile(
        label: choice.label,
        icon: _situationIcon(choice.next),
        onPressed: () => _choose(choice.next),
      );
    }
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(16),
      ),
      onPressed: () => _choose(choice.next),
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
        if (_showContact)
          OutlinedButton.icon(
            onPressed: _openingDialler ? null : () => _dial('112'),
            icon: const BaseboundIcon(BaseboundIconName.phone, calm: true),
            label: const Text('Call 112'),
          )
        else
          FilledButton.icon(
            onPressed: _openingDialler ? null : () => _dial('112'),
            icon: const BaseboundIcon(
              BaseboundIconName.phone,
              color: Colors.white,
              calm: true,
            ),
            label: Text(_step.urgent ? 'Call 112 now' : 'Call 112'),
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

class _ContactChoices extends StatelessWidget {
  const _ContactChoices({required this.contacts});

  final List<TrustedContact> contacts;

  @override
  Widget build(BuildContext context) => SimpleDialog(
    title: const Text('Choose a trusted adult'),
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
                : 'Trusted adult ${index + 1}',
          ),
        ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Back to help'),
      ),
    ],
  );
}

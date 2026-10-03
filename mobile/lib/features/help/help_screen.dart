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
import 'widgets/help_step_content.dart';
import 'widgets/help_contact_choices.dart';

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
          child: HelpContactChoices(contacts: contacts),
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
                child: HelpStepContent(
                  step: _step,
                  page: _history.last,
                  nearbyPlaceName: _helpContext.nearbyPlaceName,
                  withoutHelper: _withoutHelper,
                  serviceConfirmed: _service.canOfferEmergency,
                  showContact: _showContact,
                  showEmergency: _showEmergency,
                  loadingContacts: _loadingContacts,
                  openingDialler: _openingDialler,
                  contactsUnavailable: _contactsUnavailable,
                  phoneStatus: _phoneStatus,
                  onChoose: _choose,
                  onContactAdult: _contactAdult,
                  onEmergency: () => _dial('112'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

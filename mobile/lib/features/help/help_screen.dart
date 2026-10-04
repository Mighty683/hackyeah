/// Separate, offline-first help prototype. No game rewards, hazard detection,
/// verified routing, or claims that a call/message connected or was delivered.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
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
    label: const Text(
      'Potrzebuję pomocy · prototyp',
      textAlign: TextAlign.center,
    ),
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
  final _history = <HelpPage>[HelpPage.situations];
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

  HelpStep get _step => helpSteps[_history.last]!;
  bool get _showHelper =>
      _history.last != HelpPage.situations &&
      _history.last != HelpPage.airLocation &&
      _history.last != HelpPage.withHelper;
  bool get _showEmergency => _step.offerEmergency;
  bool get _showContact =>
      _step.offerContact && _service.canOfferContact && _contacts.isNotEmpty;

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
      final bool opened;
      if (kIsWeb) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('$phone · Połączenie demo'),
            content: const Text(
              'To połączenie na niby do ćwiczeń. Nie wykonujemy prawdziwego połączenia.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Zamknij'),
              ),
            ],
          ),
        );
        opened = true;
      } else {
        opened = await _phone.openDialler(phone);
      }
      if (!mounted) return;
      setState(() {
        _phoneStatus = kIsWeb
            ? 'Otwarto okno demo. Bez prawdziwego połączenia.'
            : phone == '112'
            ? opened
                  ? 'Otwarto okno demo. Bez prawdziwego połączenia.'
                  : 'Nie udało się otworzyć okna demo. Nie wykonano połączenia.'
            : opened
            ? 'Otwarto aplikację telefonu. Nie oznacza to nawiązania połączenia.'
            : 'Nie udało się otworzyć aplikacji telefonu. Korzystaj dalej z kroków offline.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _phoneStatus = phone == '112'
            ? 'Nie udało się otworzyć okna demo. Nie wykonano połączenia.'
            : 'Nie udało się otworzyć aplikacji telefonu. Korzystaj dalej z kroków offline.';
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
              'Nie zapisano poprawnego numeru zaufanej osoby dorosłej. '
              'Poproś dorosłego o dodanie numeru.';
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
            'Nie udało się odczytać zapisanych kontaktów. '
            'Możesz nadal korzystać z kroków offline.';
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
              tooltip: _history.length == 1
                  ? 'Zamknij pomoc'
                  : 'Poprzedni krok',
            ),
            title: const Text('Pomoc · prototyp'),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: HelpStepContent(
                  step: _step,
                  page: _history.last,
                  nearbyPlaceName: _helpContext.nearbyPlaceName,
                  showHelper: _showHelper,
                  onReturnFromHelper: _back,
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

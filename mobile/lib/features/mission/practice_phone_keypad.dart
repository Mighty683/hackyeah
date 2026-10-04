import 'package:flutter/material.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import '../parent/data/family_plan.dart';

/// Local number-recall practice. Completing it never sends a message or calls.
class PracticePhoneKeypad extends StatefulWidget {
  const PracticePhoneKeypad({
    super.key,
    required this.contacts,
    required this.onComplete,
    required this.onInstructionChanged,
  });

  final List<TrustedContact> contacts;
  final VoidCallback onComplete;
  final ValueChanged<String> onInstructionChanged;

  @override
  State<PracticePhoneKeypad> createState() => _PracticePhoneKeypadState();
}

class _PracticePhoneKeypadState extends State<PracticePhoneKeypad> {
  static const _instruction =
      'Wpisz numer telefonu zaufanej osoby dorosłej. '
      'To tylko ćwiczenie. Nie wykonujemy połączeń ani nie wysyłamy wiadomości.';
  static const _mismatch =
      'Numer jeszcze się nie zgadza. Wpisz pokazany numer.';
  static const _matched = 'Numer zgadza się z zapisanym kontaktem.';

  String _digits = '';
  String? _feedback;
  bool _showHint = false;
  bool _matches = false;

  static String _phoneDigits(String phone) =>
      phone.replaceAll(RegExp(r'[^0-9]'), '');

  List<TrustedContact> get _contacts => widget.contacts
      .where((contact) => _phoneDigits(contact.phone).isNotEmpty)
      .toList();

  // Keep typing bounded while allowing every number already saved in setup.
  int get _digitLimit => _contacts.fold(
    20,
    (limit, contact) => _phoneDigits(contact.phone).length > limit
        ? _phoneDigits(contact.phone).length
        : limit,
  );

  String get _hintInstruction =>
      'Wpisz pokazane cyfry. Nie wpisuj spacji ani myślników.';

  void _editNumber(String digits) {
    final hadFeedback = _feedback != null;
    setState(() {
      _digits = digits;
      _feedback = null;
      _matches = false;
    });
    if (hadFeedback) {
      widget.onInstructionChanged(_showHint ? _hintInstruction : _instruction);
    }
  }

  void _appendDigit(String digit) {
    if (_digits.length >= _digitLimit) {
      const message = 'Sprawdź cyfry lub wyczyść numer i spróbuj ponownie.';
      setState(() => _feedback = message);
      widget.onInstructionChanged(message);
      return;
    }
    _editNumber('$_digits$digit');
  }

  void _checkNumber() {
    final matches = _contacts.any(
      (contact) => _phoneDigits(contact.phone) == _digits,
    );
    setState(() {
      _matches = matches;
      _feedback = matches ? _matched : _mismatch;
      if (!matches) _showHint = true;
    });
    widget.onInstructionChanged(
      matches ? '$_matched Dotknij Zadzwoń na niby.' : _mismatch,
    );
  }

  void _toggleHint() {
    setState(() => _showHint = !_showHint);
    widget.onInstructionChanged(
      _showHint ? _hintInstruction : (_feedback ?? _instruction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contacts = _contacts;
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Wpisz numer telefonu',
            style: theme.textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Wpisz numer telefonu zaufanej osoby dorosłej.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Tylko ćwiczenie. Bez połączeń i wiadomości.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: BaseboundColors.muted,
          ),
        ),
        const SizedBox(height: 24),
        if (contacts.isEmpty) ...[
          Semantics(
            liveRegion: true,
            child: const Text(
              'Nie zapisano jeszcze numeru telefonu. '
              'Poproś dorosłego o dodanie numeru w ustawieniach rodziny.',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: widget.onComplete,
            child: const Text('Ćwicz dalej bez numeru'),
          ),
        ] else ...[
          if (_showHint) ...[
            _buildHint([contacts.first]),
            const SizedBox(height: 16),
          ],
          SoftPanel(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ExcludeSemantics(
                  child: BaseboundIcon(BaseboundIconName.phone, size: 32),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'Numer telefonu',
                  value: _digits.isEmpty
                      ? 'Nie wpisano cyfr'
                      : _digits.split('').join(' '),
                  liveRegion: true,
                  child: ExcludeSemantics(
                    child: Text(
                      _digits.isEmpty
                          ? 'Wpisz numer'
                          : _digits.split('').join(' '),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: _digits.isEmpty ? BaseboundColors.muted : null,
                      ),
                    ),
                  ),
                ),
                if (!_matches) ...[
                  const SizedBox(height: 16),
                  _buildKeypad(),
                  TextButton(
                    onPressed: _digits.isEmpty ? null : () => _editNumber(''),
                    child: const Text('Wyczyść numer'),
                  ),
                ],
              ],
            ),
          ),
          if (_feedback != null) ...[
            const SizedBox(height: 16),
            _buildFeedback(),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _matches
                ? widget.onComplete
                : (_digits.isEmpty ? null : _checkNumber),
            child: Text(_matches ? 'Zadzwoń na niby' : 'Sprawdź numer'),
          ),
          if (!_matches) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: _toggleHint,
              child: Text(
                _showHint ? 'Ukryj podpowiedź' : 'Potrzebujesz podpowiedzi?',
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildKeypad() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var row = 0; row < 3; row++) ...[
        Row(
          children: [
            for (var column = 0; column < 3; column++) ...[
              if (column > 0) const SizedBox(width: 8),
              Expanded(child: _digitKey('${row * 3 + column + 1}')),
            ],
          ],
        ),
        const SizedBox(height: 8),
      ],
      Row(
        children: [
          const Expanded(child: SizedBox()),
          const SizedBox(width: 8),
          Expanded(child: _digitKey('0')),
          const SizedBox(width: 8),
          Expanded(
            child: Tooltip(
              message: 'Usuń ostatnią cyfrę',
              child: OutlinedButton(
                onPressed: _digits.isEmpty
                    ? null
                    : () =>
                          _editNumber(_digits.substring(0, _digits.length - 1)),
                child: const Icon(Icons.backspace_outlined, size: 24),
              ),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _digitKey(String digit) =>
      OutlinedButton(onPressed: () => _appendDigit(digit), child: Text(digit));

  Widget _buildFeedback() => Semantics(
    liveRegion: true,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: BaseboundIcon(
            _matches ? BaseboundIconName.check : BaseboundIconName.idea,
            color: _matches ? BaseboundColors.green : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(_feedback!)),
      ],
    ),
  );

  Widget _buildHint(List<TrustedContact> contacts) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 8),
      Text(_hintInstruction),
      for (final contact in contacts) ...[
        const SizedBox(height: 12),
        SoftPanel(
          color: BaseboundColors.sky,
          borderColor: BaseboundColors.blue,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                [
                  contact.name.trim(),
                  contact.relationship.trim(),
                ].where((part) => part.isNotEmpty).join(' · '),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: 'Zapisany numer',
                value: _phoneDigits(contact.phone).split('').join(' '),
                child: ExcludeSemantics(
                  child: Text(
                    contact.phone,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: BaseboundColors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}

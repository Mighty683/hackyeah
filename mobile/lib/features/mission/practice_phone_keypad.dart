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
      'Type your trusted adult’s phone number. '
      'This is practice only. No calls or messages are sent.';
  static const _mismatch =
      'That number does not match yet. Try again or use a hint.';
  static const _matched = 'That matches a saved number.';

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
      'Type all the digits shown, including the country code. '
      'You do not need the plus sign, spaces or dashes.';

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
      const message = 'Check the digits, or clear the number to try again.';
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
    });
    widget.onInstructionChanged(
      matches ? '$_matched Tap Send pretend message.' : _mismatch,
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
            'Type their phone number',
            style: theme.textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Type your trusted adult’s phone number.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Practice only. No calls or messages.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: BaseboundColors.muted,
          ),
        ),
        const SizedBox(height: 24),
        if (contacts.isEmpty) ...[
          Semantics(
            liveRegion: true,
            child: const Text(
              'No phone number is saved yet. '
              'Ask an adult to add one in parent setup.',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: widget.onComplete,
            child: const Text('Continue without a number'),
          ),
        ] else ...[
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
                  label: 'Phone number',
                  value: _digits.isEmpty
                      ? 'No digits entered'
                      : _digits.split('').join(' '),
                  liveRegion: true,
                  child: ExcludeSemantics(
                    child: Text(
                      _digits.isEmpty
                          ? 'Enter number'
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
                    child: const Text('Clear number'),
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
            child: Text(_matches ? 'Send pretend message' : 'Check number'),
          ),
          if (!_matches) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: _toggleHint,
              child: Text(_showHint ? 'Hide hint' : 'Need a hint?'),
            ),
            if (_showHint) _buildHint(contacts),
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
              message: 'Delete last digit',
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
        Text(
          [
            contact.name.trim(),
            contact.relationship.trim(),
          ].where((part) => part.isNotEmpty).join(' · '),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        Semantics(
          label: 'Saved number',
          value: _phoneDigits(contact.phone).split('').join(' '),
          child: ExcludeSemantics(child: Text(contact.phone)),
        ),
      ],
    ],
  );
}

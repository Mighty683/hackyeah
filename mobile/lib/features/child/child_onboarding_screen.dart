import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui/basebound_icons.dart';
import '../../ui/basebound_ui.dart';
import '../../widgets/child_character.dart';
import '../mission/practice_launcher.dart';
import '../parent/data/family_plan.dart';
import '../parent/data/family_plan_repository.dart';

/// Three small steps reuse encrypted local storage and preserve adult details.
class ChildOnboardingScreen extends StatefulWidget {
  const ChildOnboardingScreen({super.key, this.repository});

  final FamilyPlanRepository? repository;

  @override
  State<ChildOnboardingScreen> createState() => _ChildOnboardingScreenState();
}

class _ChildOnboardingScreenState extends State<ChildOnboardingScreen> {
  late final _repository = widget.repository ?? FamilyPlanRepository();
  final _name = TextEditingController();
  final _age = TextEditingController();
  FamilyPlan? _plan;
  ChildGender? _gender;
  int _step = 0;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final plan = await _repository.load();
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _name.text = plan.child.fullName;
        _age.text = plan.child.age?.toString() ?? '';
        _gender = plan.child.gender;
      });
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = 'Nie udało się wczytać twoich danych. Spróbuj ponownie.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _back() {
    if (_busy) return;
    if (_step == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _step--;
      _error = null;
    });
  }

  Future<void> _next() async {
    if (_busy) return;
    final age = int.tryParse(_age.text);
    final error = switch (_step) {
      0 when age == null || age < 1 || age > 99 =>
        'Podaj swój wiek, aby przejść dalej.',
      1 when _name.text.trim().isEmpty => 'Podaj imię lub pseudonim.',
      2 when _gender == null => 'Wybierz dziewczynkę lub chłopca.',
      _ => null,
    };
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    FocusScope.of(context).unfocus();
    if (_step < 2) {
      setState(() {
        _step++;
        _error = null;
      });
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final existing = _plan!.child;
    final child = ChildProfile(
      fullName: _name.text.trim(),
      age: age,
      gender: _gender,
      address: existing.address,
      supportNotes: existing.supportNotes,
    );
    try {
      // Reload before writing so contacts and practice places stay intact.
      final latest = await _repository.load();
      await _repository.save(latest.copyWith(child: child));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => PracticeLauncher(child: child)),
      );
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = 'Nie udało się zapisać twoich danych. Spróbuj ponownie.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy && _step == 0,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _back();
    },
    child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BaseboundBackButton(enabled: !_busy, onPressed: _back),
        title: const Text('Poznaj swoją postać'),
      ),
      body: SafeArea(
        child: IllustratedBackdrop(
          warm: true,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: _content(context),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _content(BuildContext context) {
    if (_plan == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_busy) const CircularProgressIndicator(),
          if (_error != null) ...[
            Semantics(liveRegion: true, child: Text(_error!)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _load,
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Krok ${_step + 1} z 3',
          style: const TextStyle(
            color: BaseboundColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          [
            'Ile masz lat?',
            'Jak masz na imię?',
            'Jaka jest twoja płeć?',
          ][_step],
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        if (_step == 0) ...[
          TextField(
            key: const ValueKey('child-age'),
            controller: _age,
            enabled: !_busy,
            maxLength: 2,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: 'Twój wiek'),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _next(),
          ),
        ],
        if (_step == 1) ...[
          const Text('Możesz podać pseudonim.'),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('child-name'),
            controller: _name,
            enabled: !_busy,
            maxLength: 40,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Twoje imię'),
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _next(),
          ),
        ],
        if (_step == 2) ...[
          const Text('Wybierz postać do ćwiczeń.'),
          const SizedBox(height: 24),
          const SizedBox(
            height: 140,
            child: Row(
              children: [
                Expanded(
                  child: ChildCharacter(
                    pose: ChildPoseName.stand,
                    gender: ChildGender.girl,
                  ),
                ),
                Expanded(
                  child: ChildCharacter(
                    pose: ChildPoseName.stand,
                    gender: ChildGender.boy,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _genderChoice(ChildGender.girl, 'Dziewczynka'),
          const SizedBox(height: 12),
          _genderChoice(ChildGender.boy, 'Chłopiec'),
        ],
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Semantics(
              liveRegion: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BaseboundIcon(
                    BaseboundIconName.info,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _busy ? null : _next,
          child: Text(
            _busy
                ? 'Zapisywanie…'
                : [
                    'Podaj imię',
                    'Wybierz postać',
                    'Rozpocznij ćwiczenie',
                  ][_step],
          ),
        ),
      ],
    );
  }

  Widget _genderChoice(ChildGender gender, String label) => BaseboundActionTile(
    label: label,
    icon: _gender == gender ? BaseboundIconName.check : BaseboundIconName.child,
    selected: _gender == gender,
    onPressed: _busy
        ? null
        : () => setState(() {
            _gender = gender;
            _error = null;
          }),
  );
}

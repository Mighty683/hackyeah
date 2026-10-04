/// Shared adult form layout with explicit saving and non-destructive failure feedback.
library;

import 'package:flutter/material.dart';

import '../../../ui/basebound_icons.dart';

import '../../../ui/basebound_ui.dart';
import '../../../ui/parent_setup_ui.dart';

export '../../../ui/parent_setup_ui.dart';

/// One field or choice in an adult setup flow.
class ParentEditorStep {
  const ParentEditorStep({
    required this.title,
    required this.children,
    this.nextLabel = 'Następny krok',
  });

  final String title;
  final List<Widget> children;
  final String nextLabel;
}

/// Keeps edits in the owning screen until the final step is saved.
class ParentEditorScaffold extends StatefulWidget {
  const ParentEditorScaffold({
    required this.title,
    required this.onSave,
    this.children = const [],
    this.steps = const [],
    this.saveLabel = 'Zapisz zmiany',
    this.saveEnabled = true,
    super.key,
  }) : assert(children.length > 0 || steps.length > 0);

  final String title;
  final List<Widget> children;
  final List<ParentEditorStep> steps;
  final Future<void> Function() onSave;
  final String saveLabel;
  final bool saveEnabled;

  @override
  State<ParentEditorScaffold> createState() => _ParentEditorScaffoldState();
}

class _ParentEditorScaffoldState extends State<ParentEditorScaffold> {
  int _stepIndex = 0;
  bool _saving = false;
  bool _saved = false;
  String? _error;

  int get _stepCount => widget.steps.isEmpty ? 1 : widget.steps.length;
  bool get _isLastStep => _stepIndex == _stepCount - 1;
  ParentEditorStep get _currentStep => widget.steps.isEmpty
      ? ParentEditorStep(title: widget.title, children: widget.children)
      : widget.steps[_stepIndex];

  void _goBack() {
    if (_saving || _saved) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (_stepIndex == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _stepIndex--;
      _error = null;
    });
  }

  void _advance() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _stepIndex++;
      _error = null;
    });
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave();
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saved = true;
      });
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Nie udało się zapisać. Twoje zmiany zostały zachowane. Spróbuj ponownie.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: parentSetupTheme(),
    child: PopScope<bool>(
      canPop: !_saving && (_stepIndex == 0 || _saved),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: _buildScaffold(),
    ),
  );

  Widget _buildScaffold() {
    final step = _currentStep;
    final actionEnabled =
        !_saving && !_saved && (!_isLastStep || widget.saveEnabled);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          onPressed: _saving || _saved ? null : _goBack,
          icon: const BaseboundIcon(BaseboundIconName.back),
          tooltip: 'Wstecz',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          key: ValueKey(_stepIndex),
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Krok ${_stepIndex + 1} z $_stepCount',
                    style: const TextStyle(
                      color: BaseboundColors.muted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    minHeight: 3,
                    borderRadius: BorderRadius.circular(4),
                    value: (_stepIndex + 1) / _stepCount,
                    color: BaseboundColors.blue,
                    backgroundColor: BaseboundColors.sky,
                    semanticsLabel:
                        'Postęp konfiguracji: krok ${_stepIndex + 1} z $_stepCount',
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    header: true,
                    child: Text(
                      step.title,
                      style: const TextStyle(
                        color: BaseboundColors.ink,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...step.children,
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[
                Semantics(
                  liveRegion: true,
                  child: ParentEditorNote(
                    message: _error!,
                    icon: BaseboundIconName.alert,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              FilledButton.icon(
                onPressed: actionEnabled
                    ? (_isLastStep ? _save : _advance)
                    : null,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : BaseboundIcon(
                        _isLastStep
                            ? BaseboundIconName.check
                            : BaseboundIconName.next,
                        color: Colors.white,
                      ),
                label: Text(
                  _saving
                      ? 'Zapisywanie…'
                      : _isLastStep
                      ? widget.saveLabel
                      : step.nextLabel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

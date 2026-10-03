/// Shared adult form layout with explicit saving and non-destructive failure feedback.
library;

import 'package:flutter/material.dart';

import '../../../ui/basebound_ui.dart';

/// A calmer variant of the game palette for editing device-local records.
ThemeData parentSetupTheme() {
  final theme = BaseboundTheme.training();
  const fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(18)),
    borderSide: BorderSide(color: BaseboundColors.border),
  );
  return theme.copyWith(
    scaffoldBackgroundColor: const Color(0xFFF3F7FC),
    appBarTheme: theme.appBarTheme.copyWith(
      backgroundColor: Colors.white,
      foregroundColor: BaseboundColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        fontFamily: 'Nunito',
        color: BaseboundColors.ink,
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF8FAFE),
      contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(color: BaseboundColors.blue, width: 2),
      ),
      labelStyle: TextStyle(
        fontFamily: 'Nunito',
        color: BaseboundColors.muted,
        fontSize: 16,
      ),
      floatingLabelStyle: TextStyle(
        fontFamily: 'Nunito',
        color: BaseboundColors.ink,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      hintStyle: TextStyle(fontFamily: 'Nunito', color: BaseboundColors.muted),
      prefixIconColor: BaseboundColors.muted,
      counterStyle: TextStyle(
        fontFamily: 'Nunito',
        color: BaseboundColors.muted,
      ),
    ),
  );
}

class ParentEditorNote extends StatelessWidget {
  const ParentEditorNote({
    required this.message,
    required this.icon,
    super.key,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: BaseboundColors.sky,
      borderRadius: BorderRadius.circular(18),
    ),
    padding: const EdgeInsets.all(16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: BaseboundColors.ink, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              fontFamily: 'Nunito',
              color: BaseboundColors.ink,
              fontSize: 16,
              height: 1.45,
            ),
          ),
        ),
      ],
    ),
  );
}

/// One field or choice in an adult setup flow.
class ParentEditorStep {
  const ParentEditorStep({
    required this.title,
    required this.children,
    this.nextLabel = 'Next step',
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
    this.saveLabel = 'Save changes',
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
          () =>
              _error = 'Could not save. Your edits are still here. Try again.',
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
          icon: const BackButtonIcon(),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          key: ValueKey(_stepIndex),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: SoftPanel(
                borderColor: BaseboundColors.border,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Step ${_stepIndex + 1} of $_stepCount',
                      style: const TextStyle(
                        color: BaseboundColors.muted,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (_stepIndex + 1) / _stepCount,
                      color: BaseboundColors.blue,
                      backgroundColor: BaseboundColors.sky,
                      semanticsLabel:
                          'Setup progress: step ${_stepIndex + 1} of $_stepCount',
                    ),
                    const SizedBox(height: 24),
                    Semantics(
                      header: true,
                      child: Text(
                        step.title,
                        style: const TextStyle(
                          color: BaseboundColors.ink,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
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
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[
                Semantics(
                  liveRegion: true,
                  child: ParentEditorNote(
                    message: _error!,
                    icon: Icons.error_outline,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              FilledButton.icon(
                onPressed: actionEnabled
                    ? (_isLastStep ? _save : _advance)
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: BaseboundColors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(48, 58),
                  padding: const EdgeInsets.all(18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        _isLastStep
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                label: Text(
                  _saving
                      ? 'Saving…'
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

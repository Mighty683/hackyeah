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

class ParentEditorScaffold extends StatefulWidget {
  const ParentEditorScaffold({
    required this.title,
    required this.children,
    required this.onSave,
    this.saveEnabled = true,
    super.key,
  });

  final String title;
  final List<Widget> children;
  final Future<void> Function() onSave;
  final bool saveEnabled;

  @override
  State<ParentEditorScaffold> createState() => _ParentEditorScaffoldState();
}

class _ParentEditorScaffoldState extends State<ParentEditorScaffold> {
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave();
      if (!mounted) return;
      setState(() => _saving = false);
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) Navigator.of(context).pop();
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
    child: PopScope(canPop: !_saving, child: _buildScaffold()),
  );

  Widget _buildScaffold() {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: SoftPanel(
                borderColor: BaseboundColors.border,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: widget.children,
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
                onPressed: widget.saveEnabled && !_saving ? _save : null,
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
                    : const Icon(Icons.check_rounded),
                label: Text(_saving ? 'Saving…' : 'Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

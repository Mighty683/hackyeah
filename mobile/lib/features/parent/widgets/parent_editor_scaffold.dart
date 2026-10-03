/// Shared adult form layout with explicit saving and non-destructive failure feedback.
library;

import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) =>
      PopScope(canPop: !_saving, child: _buildScaffold());

  Widget _buildScaffold() {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...widget.children,
              if (_error != null) ...[
                const SizedBox(height: 16),
                Semantics(liveRegion: true, child: Text(_error!)),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: widget.saveEnabled && !_saving ? _save : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(18),
                ),
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(_saving ? 'Saving…' : 'Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

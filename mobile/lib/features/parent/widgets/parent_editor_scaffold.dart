/// Shared adult form layout with explicit saving and non-destructive failure feedback.
library;

import 'package:flutter/material.dart';

import '../../../ui/basebound_ui.dart';
import '../../../ui/basebound_icons.dart';

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
  final BaseboundIconName icon;

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
        BaseboundIcon(icon, size: 24),
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
    required this.illustration,
    this.saveEnabled = true,
    super.key,
  });

  final String title;
  final List<Widget> children;
  final Future<void> Function() onSave;
  final bool saveEnabled;
  final ParentEditorArt illustration;

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
      appBar: AppBar(
        leading: const BaseboundBackButton(),
        title: Text(widget.title),
      ),
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
                  children: [
                    ParentEditorIllustration(art: widget.illustration),
                    const SizedBox(height: 16),
                    ...widget.children,
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
                    icon: BaseboundIconName.alert,
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
                    : const BaseboundIcon(
                        BaseboundIconName.check,
                        color: Colors.white,
                      ),
                label: Text(_saving ? 'Saving…' : 'Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum ParentEditorArt { child, contact, place }

/// Compact task-specific artwork keeps adult forms distinct without competing
/// with editable fields or the geographic map.
class ParentEditorIllustration extends StatelessWidget {
  const ParentEditorIllustration({required this.art, super.key});

  final ParentEditorArt art;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 160,
        height: 84,
        child: CustomPaint(painter: _ParentFormArtPainter(art)),
      ),
    ),
  );
}

class _ParentFormArtPainter extends CustomPainter {
  const _ParentFormArtPainter(this.art);

  final ParentEditorArt art;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 160, size.height / 84);
    final fill = Paint()..color = BaseboundColors.sky;
    canvas.drawOval(const Rect.fromLTWH(5, 10, 138, 68), fill);
    switch (art) {
      case ParentEditorArt.child:
        final card = RRect.fromRectAndRadius(
          const Rect.fromLTWH(16, 8, 121, 64),
          const Radius.circular(14),
        );
        canvas.drawRRect(card, Paint()..color = Colors.white);
        canvas.drawRRect(
          card,
          Paint()
            ..color = BaseboundColors.border
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        paintBaseboundIcon(
          canvas,
          const Rect.fromLTWH(25, 16, 44, 44),
          BaseboundIconName.child,
        );
        _cardLine(canvas, 80, 25, 119, 25);
        _cardLine(canvas, 80, 36, 111, 36);
        _cardLine(canvas, 80, 47, 101, 47);
        paintBaseboundIcon(
          canvas,
          const Rect.fromLTWH(119, 52, 28, 28),
          BaseboundIconName.heart,
        );
      case ParentEditorArt.contact:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(40, 5, 82, 72),
            const Radius.circular(13),
          ),
          Paint()..color = BaseboundColors.blue,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(50, 12, 62, 55),
            const Radius.circular(10),
          ),
          Paint()..color = Colors.white,
        );
        for (var y = 17.0; y < 70; y += 14) {
          _cardLine(canvas, 33, y, 44, y);
        }
        paintBaseboundIcon(
          canvas,
          const Rect.fromLTWH(62, 19, 37, 37),
          BaseboundIconName.family,
        );
        canvas.drawCircle(
          const Offset(123, 61),
          21,
          Paint()..color = BaseboundColors.cream,
        );
        paintBaseboundIcon(
          canvas,
          const Rect.fromLTWH(108, 46, 30, 30),
          BaseboundIconName.phone,
        );
      case ParentEditorArt.place:
        paintBaseboundIcon(
          canvas,
          const Rect.fromLTWH(15, 4, 82, 76),
          BaseboundIconName.map,
        );
        paintBaseboundIcon(
          canvas,
          const Rect.fromLTWH(84, 14, 57, 57),
          BaseboundIconName.pin,
        );
    }
  }

  void _cardLine(Canvas canvas, double x1, double y1, double x2, double y2) {
    canvas.drawLine(
      Offset(x1, y1),
      Offset(x2, y2),
      Paint()
        ..color = BaseboundColors.border
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ParentFormArtPainter oldDelegate) =>
      oldDelegate.art != art;
}

import 'package:flutter/material.dart';

import '../../ui/basebound_ui.dart';

/// Makes scene artwork tappable without drawing a button over the picture.
/// Keeps a labelled control for screen readers and a visible keyboard focus.
class SceneObjectTarget extends StatelessWidget {
  const SceneObjectTarget({
    super.key,
    required this.label,
    required this.onTap,
    required this.child,
    this.selected = false,
    this.rejected = false,
  });

  final String label;
  final VoidCallback? onTap;
  final Widget child;
  final bool selected;
  final bool rejected;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    enabled: onTap != null,
    selected: selected,
    onTap: onTap,
    hint: rejected ? 'Try another choice.' : null,
    child: ExcludeSemantics(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          focusColor: BaseboundColors.blue.withValues(alpha: .18),
          hoverColor: BaseboundColors.blue.withValues(alpha: .08),
          splashColor: BaseboundColors.blue.withValues(alpha: .12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Opacity(opacity: rejected ? .45 : 1, child: child),
          ),
        ),
      ),
    ),
  );
}

/// A quiet outline around a standalone person or object, never a filled card.
class SceneObjectHalo extends CustomPainter {
  const SceneObjectHalo({this.rejected = false});

  final bool rejected;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawOval(
    (Offset.zero & size).deflate(4),
    Paint()
      ..color = rejected ? BaseboundColors.muted : BaseboundColors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5,
  );

  @override
  bool shouldRepaint(SceneObjectHalo oldDelegate) =>
      rejected != oldDelegate.rejected;
}

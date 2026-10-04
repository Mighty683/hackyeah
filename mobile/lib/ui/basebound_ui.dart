/// Shared visual language for fictional practice; help uses a quieter variant.
library;

import 'package:flutter/material.dart';

import '../widgets/basebound_mascot.dart';
import 'basebound_icons.dart';
import 'basebound_theme.dart';

export 'basebound_theme.dart';

/// A quiet surface lets illustrations carry the scene's colour.
class IllustratedBackdrop extends StatelessWidget {
  const IllustratedBackdrop({
    super.key,
    required this.child,
    this.warm = false,
  });

  final Widget child;
  final bool warm;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: warm ? BaseboundColors.cream : const Color(0xFFF3F6FA),
    ),
    child: SizedBox.expand(child: child),
  );
}

class SoftPanel extends StatelessWidget {
  const SoftPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color = Colors.white,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor ?? BaseboundColors.border),
    ),
    child: child,
  );
}

/// A neutral navigation choice shared by entry, practice and saved-item lists.
class BaseboundActionTile extends StatelessWidget {
  const BaseboundActionTile({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.description,
    this.selected = false,
    this.large = false,
    this.leading,
    this.padding,
  });

  final String label;
  final BaseboundIconName icon;
  final VoidCallback? onPressed;
  final String? description;
  final bool selected;
  final bool large;

  /// Decorative artwork remains inside the tile's single navigation target.
  final Widget? leading;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding:
            padding ??
            EdgeInsets.symmetric(horizontal: 16, vertical: large ? 24 : 16),
        backgroundColor: selected ? BaseboundColors.sky : Colors.white,
        side: BorderSide(
          color: selected ? BaseboundColors.blue : BaseboundColors.border,
        ),
        alignment: Alignment.centerLeft,
      ),
      child: Row(
        children: [
          ExcludeSemantics(
            child: leading ?? BaseboundIcon(icon, size: large ? 32 : 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: large ? 22 : 18,
                    height: 1.3,
                    fontWeight: large ? FontWeight.w700 : null,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      color: BaseboundColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          ExcludeSemantics(
            child: BaseboundIcon(BaseboundIconName.next, size: large ? 24 : 20),
          ),
        ],
      ),
    ),
  );
}

/// Calm practice feedback; a symbol supplements color for every outcome.
class BaseboundGuide extends StatelessWidget {
  const BaseboundGuide({
    super.key,
    required this.message,
    this.positive = true,
    this.pose,
    this.mascotOnRight = false,
    this.compact = false,
  });

  final String message;
  final bool positive;
  final DinoPose? pose;
  final bool mascotOnRight;
  final bool compact;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 4, vertical: compact ? 4 : 12),
    child: LayoutBuilder(
      builder: (context, constraints) => Row(
        textDirection: mascotOnRight ? TextDirection.rtl : TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!compact &&
              constraints.maxWidth >= 220 &&
              MediaQuery.textScalerOf(context).scale(1) < 1.6) ...[
            BaseboundMascot(
              size: 76,
              pose: pose ?? (positive ? DinoPose.celebrate : DinoPose.calm),
              faceLeft: mascotOnRight,
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BaseboundIcon(
                  positive ? BaseboundIconName.check : BaseboundIconName.idea,
                  size: 26,
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: compact ? 17 : 20,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

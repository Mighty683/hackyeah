import 'package:flutter/material.dart';

/// Keeps unavailable web audio quiet on the screen and explains it on demand.
class UnavailableAudioTooltip extends StatefulWidget {
  const UnavailableAudioTooltip({
    required this.unavailable,
    required this.child,
    super.key,
  });

  final bool unavailable;
  final Widget child;

  static const message =
      'Głos w tej przeglądarce jest niedostępny. Czytaj z dorosłym.';

  @override
  State<UnavailableAudioTooltip> createState() =>
      _UnavailableAudioTooltipState();
}

class _UnavailableAudioTooltipState extends State<UnavailableAudioTooltip> {
  final _tooltipKey = GlobalKey<TooltipState>();

  void _showTooltip() => _tooltipKey.currentState?.ensureTooltipVisible();

  @override
  Widget build(BuildContext context) {
    if (!widget.unavailable) return widget.child;
    return Semantics(
      button: true,
      label: 'Dźwięk niedostępny',
      hint: UnavailableAudioTooltip.message,
      onTap: _showTooltip,
      child: ExcludeSemantics(
        child: Tooltip(
          key: _tooltipKey,
          message: UnavailableAudioTooltip.message,
          triggerMode: TooltipTriggerMode.tap,
          showDuration: const Duration(seconds: 4),
          child: IgnorePointer(
            child: ExcludeFocus(
              child: Opacity(opacity: 0.4, child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

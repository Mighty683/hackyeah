import 'package:flutter/material.dart';

import '../../ui/basebound_ui.dart';

/// Announces choice feedback and keeps both missions' outcome tiles consistent.
class PracticeFeedback extends StatelessWidget {
  const PracticeFeedback({
    super.key,
    required this.message,
    required this.positive,
  });

  final String message;
  final bool positive;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: BaseboundFeedbackPanel(
      message: message,
      positive: positive,
      compact: true,
    ),
  );
}

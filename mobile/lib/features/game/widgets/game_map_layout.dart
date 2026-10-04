import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../ui/basebound_icons.dart';
import '../../../ui/basebound_ui.dart';

class GameMapLayout extends StatelessWidget {
  const GameMapLayout({
    required this.instruction,
    required this.onReplay,
    required this.map,
    required this.controls,
    super.key,
  });
  final String instruction;
  final VoidCallback onReplay;
  final Widget map;
  final Widget controls;

  Widget _squareMap() => LayoutBuilder(
    builder: (context, bounds) {
      final side = math.min(bounds.maxWidth, bounds.maxHeight);
      return Center(
        child: SizedBox(width: side, height: side, child: map),
      );
    },
  );

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final landscape = constraints.maxWidth > constraints.maxHeight * 1.25;
        final controls = SingleChildScrollView(child: this.controls);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    header: true,
                    child: Text(
                      instruction,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onReplay,
                  tooltip: 'Posłuchaj ponownie',
                  icon: const BaseboundIcon(
                    BaseboundIconName.speaker,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Spaceruj z dorosłym · Północ jest u góry',
              style: TextStyle(fontSize: 12, color: BaseboundColors.muted),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: landscape
                  ? Row(
                      children: [
                        Expanded(child: _squareMap()),
                        const SizedBox(width: 12),
                        Expanded(child: controls),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(child: _squareMap()),
                        const SizedBox(height: 8),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: constraints.maxHeight * .4,
                          ),
                          child: controls,
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 8),
            const Text(
              '© autorzy OpenStreetMap · ODbL',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: BaseboundColors.muted),
            ),
          ],
        );
      },
    ),
  );
}

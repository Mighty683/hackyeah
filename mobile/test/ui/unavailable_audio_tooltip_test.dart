import 'package:do_bazy/ui/unavailable_audio_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('unavailable audio shows a tooltip without starting playback', (
    tester,
  ) async {
    var played = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UnavailableAudioTooltip(
            unavailable: true,
            child: IconButton(
              onPressed: () => played = true,
              icon: const Icon(Icons.volume_up),
            ),
          ),
        ),
      ),
    );
    expect(find.text(UnavailableAudioTooltip.message), findsNothing);
    await tester.tapAt(tester.getCenter(find.byType(UnavailableAudioTooltip)));
    await tester.pumpAndSettle();
    expect(played, isFalse);
    expect(find.text(UnavailableAudioTooltip.message), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text(UnavailableAudioTooltip.message), findsNothing);
  });

  testWidgets('available audio replays normally', (tester) async {
    var played = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UnavailableAudioTooltip(
            unavailable: false,
            child: IconButton(
              onPressed: () => played = true,
              icon: const Icon(Icons.volume_up),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.volume_up));
    expect(played, isTrue);
    expect(find.text(UnavailableAudioTooltip.message), findsNothing);
  });
}

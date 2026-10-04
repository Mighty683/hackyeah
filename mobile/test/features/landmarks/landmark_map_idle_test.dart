import 'package:do_bazy/features/landmarks/widgets/landmark_map.dart';
import 'package:do_bazy/game/maps/demo_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('an idle familiar-place map stops scheduling frames', (
    tester,
  ) async {
    final map = DemoMap(
      bounds: [19, 50, 20, 51],
      center: [19.5, 50.5],
      features: [],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 390,
            child: LandmarkMap(
              map: map,
              landmarks: const [],
              photoDirectory: '',
              onSelected: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });
}

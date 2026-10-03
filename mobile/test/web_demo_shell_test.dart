import 'package:do_bazy/features/demo/web_demo_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('desktop keeps a phone viewport when presentation is resized', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    Size? appSize;

    for (final size in [const Size(1440, 1080), const Size(1024, 600)]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MaterialApp(
          home: WebDemoShell(
            onReset: () {},
            child: Builder(
              builder: (context) {
                appSize = MediaQuery.sizeOf(context);
                return const Scaffold(body: Text('Phone screen'));
              },
            ),
          ),
        ),
      );
      await tester.pump();
      expect(appSize, const Size(390, 844));
      expect(tester.takeException(), isNull);
      final screen = tester.getRect(find.byType(Scaffold));
      expect(screen.width, lessThanOrEqualTo(390));
      expect(screen.top, greaterThanOrEqualTo(0));
      expect(screen.bottom, lessThanOrEqualTo(size.height));
    }
  });
}

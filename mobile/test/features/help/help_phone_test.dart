import 'package:do_bazy/features/help/help_phone.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('basebound/help_phone');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('112 uses the native mock popup without launching a dialler', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return true;
    });

    expect(await HelpPhone().openDialler('112'), isTrue);
    expect(calls.single.method, 'showMockEmergencyCall');
    expect(calls.single.arguments, isNull);
  });

  test('native popup failure never falls back to the dialler', () async {
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(code: 'UNAVAILABLE');
    });

    await expectLater(
      HelpPhone().openDialler('112'),
      throwsA(isA<PlatformException>()),
    );
  });
}

import 'package:do_bazy/audio/practice_audio.dart';
import 'package:do_bazy/features/game/location_permission_setup.dart';
import 'package:do_bazy/features/game/navigation_location.dart';
import 'package:do_bazy/features/help/help_phone.dart';
import 'package:do_bazy/features/landmarks/landmark_location.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('browser audio never invokes native channels', () async {
    const channel = MethodChannel('web-test/native-audio');
    var calls = 0;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (_) async {
      calls++;
      return true;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    final audio = PracticeAudio(channel: channel);
    expect(await audio.initialize(), isA<bool>());
    // An empty instruction verifies web routing without playing device audio.
    await audio.narrate('');
    await audio.playCue('alarm');
    await audio.stop();
    await audio.dispose();
    expect(calls, 0);
  }, skip: !kIsWeb);

  test('browser location and permission use the same fictional fix', () async {
    final source = defaultLocationSource();
    expect(source, isA<DemoLocationSource>());
    final fix = await source.positions().first;
    expect(DateTime.now().difference(fix.timestamp).inSeconds, lessThan(2));
    final point = await currentLandmarkLocation();
    expect(point.latitude, fix.latitude);
    expect(point.longitude, fix.longitude);
    final permission = LocationPermissionSetup();
    expect(
      await permission.ensureRequestedOnce(),
      LocationPermissionStatus.granted,
    );
    expect(await permission.openSettings(), isFalse);
  }, skip: !kIsWeb);

  test(
    'browser service remains simulated and direct calls cannot dial',
    () async {
      final phone = HelpPhone();
      final states = <HelpPhoneService>[];
      final subscription = phone.serviceStates().listen(states.add);
      await Future<void>.delayed(Duration.zero);
      expect(states, [HelpPhoneService.available]);
      expect(await phone.openDialler('112'), isFalse);
      expect(await phone.openDialler('+12025550101'), isFalse);
      await subscription.cancel();
    },
    skip: !kIsWeb,
  );
}

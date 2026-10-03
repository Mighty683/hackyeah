import 'package:do_bazy/features/landmarks/data/landmark.dart';
import 'package:do_bazy/features/landmarks/data/landmark_repository_web.dart';
import 'package:do_bazy/platform/app_storage.dart';
import 'package:do_bazy/platform/demo_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:do_bazy/features/demo/data/demo_data_seeder.dart';
import 'package:do_bazy/platform/photo_access_web.dart';

import 'support/browser_assets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    DemoSession.instance.reset();
    installBrowserAssetLoader();
  });
  tearDown(() {
    removeBrowserAssetLoader();
    DemoSession.instance.reset();
  });

  testWidgets(
    'browser startup seeds shared fictional records and readable photos',
    (tester) async {
      await tester.runAsync(() async {
        await DemoDataSeeder().seed();
        final repository = LandmarkRepository(storage: SessionDemoStorage());
        final places = await repository.load();
        expect(places.length, 3);
        expect(places.every((place) => place.isDemo), isTrue);
        final directory = await repository.photoDirectory();
        for (final place in places) {
          final path = '${directory.path}/${place.photoName}';
          expect(await photoExists(path), isTrue);
          expect(await readPhotoBytes(path), isNotEmpty);
        }
        await DemoDataSeeder().seed();
        expect((await repository.load()).length, 3);
      });
    },
    skip: !kIsWeb,
    timeout: const Timeout(Duration(seconds: 45)),
  );

  testWidgets(
    'browser saves a generated landmark from a bundled sample',
    (tester) async {
      await tester.runAsync(() async {
        final repository = LandmarkRepository(storage: SessionDemoStorage());
        final id = Landmark.newId();
        final place = Landmark(
          id: id,
          name: 'Browser sample',
          photoName: '$id.photo',
          latitude: 50.07,
          longitude: 19.99,
        );
        await repository.save(
          place,
          sourcePhoto: 'assets/landmarks/red-shop.png',
        );
        expect((await repository.load()).single.id, id);
        expect((await repository.load()).single.isDemo, isTrue);
        expect(await readPhotoBytes('/demo/photos/$id.photo'), isNotEmpty);
      });
    },
    skip: !kIsWeb,
    timeout: const Timeout(Duration(seconds: 45)),
  );

  test(
    'shared session retains photo bytes across repository instances',
    () async {
      final repository = LandmarkRepository(storage: SessionDemoStorage());
      final bytes = Uint8List.fromList([1, 2, 3]);
      await repository.save(_point('1_1', 'Shop'), photoBytes: bytes);
      bytes[0] = 9;
      final other = LandmarkRepository(storage: SessionDemoStorage());
      expect((await other.load()).single.name, 'Shop');
      final path = '${(await other.photoDirectory()).path}/1_1.photo';
      expect(DemoSession.instance.photos[path], [1, 2, 3]);
      await other.save(_point('1_1', 'Edited shop'));
      expect((await repository.load()).single.name, 'Edited shop');
      expect(DemoSession.instance.photos[path], [1, 2, 3]);
    },
  );

  test('new browser photo places always remain demo records', () async {
    final repository = LandmarkRepository(storage: SessionDemoStorage());
    await repository.save(
      const Landmark(
        id: '3_3',
        name: 'Mock photo',
        photoName: '3_3.photo',
        latitude: 50.07,
        longitude: 19.99,
      ),
      photoBytes: [1],
    );
    expect((await repository.load()).single.isDemo, isTrue);
  });

  test('metadata failure rolls back only the new photo', () async {
    final repository = LandmarkRepository(storage: SessionDemoStorage());
    await repository.save(_point('1_1', 'Existing'), photoBytes: [1]);
    final failing = LandmarkRepository(storage: _FailingStorage());
    await expectLater(
      failing.save(_point('2_2', 'New'), photoBytes: [2]),
      throwsStateError,
    );
    expect((await repository.load()).single.name, 'Existing');
    expect(DemoSession.instance.photos.keys, ['/demo/photos/1_1.photo']);
  });

  test(
    'delete all removes orphan photos and keeps other feature records',
    () async {
      final repository = LandmarkRepository(storage: SessionDemoStorage());
      await repository.save(_point('1_1', 'Shop'), photoBytes: [1]);
      DemoSession.instance.photos['/demo/photos/orphan.photo'] = Uint8List(1);
      DemoSession.instance.records['family'] = 'kept';
      await repository.deleteAll();
      expect(await repository.load(), isEmpty);
      expect(DemoSession.instance.photos, isEmpty);
      expect(DemoSession.instance.records['family'], 'kept');
    },
  );
}

Landmark _point(String id, String name) => Landmark(
  id: id,
  name: name,
  photoName: '$id.photo',
  latitude: 50.07,
  longitude: 19.99,
  isDemo: true,
);

class _FailingStorage extends SessionDemoStorage {
  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
  }) async => throw StateError('Demo write failed');
}

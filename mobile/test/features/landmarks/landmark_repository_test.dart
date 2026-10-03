import 'dart:io';

import 'package:do_bazy/features/landmarks/data/landmark.dart';
import 'package:do_bazy/features/landmarks/data/demo_landmarks.dart';
import 'package:do_bazy/features/landmarks/landmark_location.dart';
import 'package:do_bazy/game/maps/demo_map.dart';
import 'package:do_bazy/features/landmarks/data/landmark_repository.dart';
import 'package:do_bazy/features/landmarks/landmark_practice.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late File source;
  late LandmarkRepository repository;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    directory = await Directory.systemTemp.createTemp(
      'basebound-landmark-test-',
    );
    source = File('${directory.path}/original.jpg');
    await source.writeAsBytes([1, 2, 3, 4]);
    repository = LandmarkRepository(supportDirectory: () async => directory);
  });
  tearDown(() async => directory.delete(recursive: true));

  test('photos survive source removal and editing retains the photo', () async {
    final landmark = _point('1_1', 'Red shop');
    await repository.save(landmark, sourcePhoto: source.path);
    await source.delete();
    final copy = File(
      '${(await repository.photoDirectory()).path}/${landmark.photoName}',
    );
    expect(await copy.readAsBytes(), [1, 2, 3, 4]);
    await repository.save(_point('1_1', 'Corner shop'));
    final saved = (await repository.load()).single;
    expect(saved.name, 'Corner shop');
    expect(saved.photoName, landmark.photoName);
    expect(await copy.exists(), isTrue);
  });

  test(
    'failed metadata write rolls back new photo and preserves saved points',
    () async {
      await repository.save(
        _point('1_1', 'Existing'),
        sourcePhoto: source.path,
      );
      final failing = LandmarkRepository(
        storage: _FailingStorage(),
        supportDirectory: () async => directory,
      );
      await expectLater(
        failing.save(_point('2_2', 'New'), sourcePhoto: source.path),
        throwsStateError,
      );
      expect((await repository.load()).single.name, 'Existing');
      final photos = await (await repository.photoDirectory()).list().toList();
      expect(photos.length, 1);
    },
  );

  test(
    'delete removes app copies while preserving original gallery file',
    () async {
      final landmark = _point('1_1', 'Red shop');
      await repository.save(landmark, sourcePhoto: source.path);
      await repository.delete(landmark);
      expect(await repository.load(), isEmpty);
      expect(
        await (await repository.photoDirectory()).list().toList(),
        isEmpty,
      );
      expect(await source.exists(), isTrue);
      await repository.save(landmark, sourcePhoto: source.path);
      await File('${(await repository.photoDirectory()).path}/orphan.photo')
          .writeAsString('orphan');
      await repository.deleteAll();
      expect(await repository.load(), isEmpty);
      expect(await (await repository.photoDirectory()).exists(), isFalse);
      expect(await source.exists(), isTrue);
    },
  );

  test('invalid photo references fail without silently resetting metadata', () async {
    const invalid =
        '{"version":1,"landmarks":[{"id":"1_1","name":"Shop","photoName":"../other.photo","latitude":50.07,"longitude":20.0}]}';
    FlutterSecureStorage.setMockInitialValues({
      LandmarkRepository.storageKey: invalid,
    });
    await expectLater(repository.load(), throwsFormatException);
    expect(
      await const FlutterSecureStorage().read(
        key: LandmarkRepository.storageKey,
      ),
      invalid,
    );
  });

  test(
    'demo import is additive, stays within the map, and preserves edits',
    () async {
      final map = await DemoMapRepository().load();
      expect(await loadDemoLandmarks(repository), 3);
      final saved = await repository.load();
      expect(
        saved.every(
          (entry) => entry.isDemo && mapContainsPoint(map, entry.point),
        ),
        isTrue,
      );
      final edited = Landmark.fromJson({
        ...saved.first.toJson(),
        'name': 'Our familiar shop',
      });
      await repository.save(edited);
      await repository.save(
        _point('3_3', 'Family point'),
        sourcePhoto: source.path,
      );
      expect(await loadDemoLandmarks(repository), 0);
      final updated = await repository.load();
      expect(updated.length, 4);
      expect(updated.first.name, 'Our familiar shop');
      expect(updated.first.isDemo, isTrue);
      expect(updated.last.name, 'Family point');
    },
  );

  test('practice samples independent locations with two to four choices', () {
    final points = List.generate(
      7,
      (index) => _point('${index}_$index', 'Place $index'),
    );
    var previous = points.first.id;
    for (var attempt = 0; attempt < 20; attempt++) {
      final question = LandmarkQuestion.pick(points, previousId: previous);
      expect(question.choices.length, 4);
      expect(question.choices.map((entry) => entry.id).toSet().length, 4);
      expect(question.choices.where(question.isCorrect).length, 1);
      expect(question.target.id, isNot(previous));
      previous = question.target.id;
    }
    expect(LandmarkQuestion.pick(points.take(2).toList()).choices.length, 2);
  });
}

Landmark _point(String id, String name) => Landmark(
  id: id,
  name: name,
  photoName: '$id.photo',
  latitude: 50.073,
  longitude: 20.001,
);

class _FailingStorage extends FlutterSecureStorage {
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
  }) async {
    throw StateError('Storage unavailable');
  }
}

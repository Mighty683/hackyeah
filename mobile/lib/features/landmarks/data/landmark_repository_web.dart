import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../platform/app_storage.dart';
import '../../../platform/demo_session.dart';
import '../../../platform/photo_access_web.dart';
import 'landmark.dart';

/// Fictional demo photos and metadata live only in the current browser session.
class LandmarkRepository {
  LandmarkRepository({FlutterSecureStorage? storage})
    : _storage = storage ?? defaultAppStorage();

  static const storageKey = 'basebound.landmarks.v1';
  static const _photoRoot = '/demo/photos';
  final FlutterSecureStorage _storage;

  Future<DemoPhotoDirectory> photoDirectory() async =>
      const DemoPhotoDirectory(_photoRoot);

  Future<List<Landmark>> load() async {
    final source = await _storage.read(key: storageKey);
    if (source == null) return [];
    final json = jsonDecode(source) as Map<String, dynamic>;
    if (json['version'] != 1) {
      throw const FormatException('Unsupported landmark version');
    }
    final landmarks = (json['landmarks'] as List)
        .map((entry) => Landmark.fromJson(entry as Map<String, dynamic>))
        .toList();
    if (landmarks.map((entry) => entry.id).toSet().length != landmarks.length) {
      throw const FormatException('Duplicate landmarks');
    }
    return landmarks;
  }

  Future<void> save(
    Landmark landmark, {
    String? sourcePhoto,
    List<int>? photoBytes,
  }) async {
    if (sourcePhoto != null && photoBytes != null) {
      throw ArgumentError('Choose one photo source');
    }
    landmark = Landmark.fromJson({...landmark.toJson(), 'isDemo': true});
    final landmarks = await load();
    final index = landmarks.indexWhere((entry) => entry.id == landmark.id);
    final destination = '$_photoRoot/${landmark.photoName}';
    var copied = false;
    if (sourcePhoto != null || photoBytes != null) {
      if (index >= 0) throw StateError('Photo replacement is not supported');
      if (await photoExists(destination)) {
        throw StateError('Photo already exists');
      }
      final bytes = photoBytes == null
          ? await readPhotoBytes(sourcePhoto!)
          : Uint8List.fromList(photoBytes);
      DemoSession.instance.photos[destination] = Uint8List.fromList(bytes);
      copied = true;
    } else if (index < 0) {
      throw StateError('A new landmark needs a photo');
    }
    if (index < 0) {
      landmarks.add(landmark);
    } else {
      landmarks[index] = landmark;
    }
    try {
      await _write(landmarks);
    } catch (_) {
      if (copied) await deletePhotoIfExists(destination);
      rethrow;
    }
  }

  Future<void> delete(Landmark landmark) async {
    await _write(
      (await load()).where((entry) => entry.id != landmark.id).toList(),
    );
    await deletePhotoIfExists('$_photoRoot/${landmark.photoName}');
  }

  Future<void> deleteAll() async {
    DemoSession.instance.photos.removeWhere(
      (path, _) => path.startsWith('$_photoRoot/'),
    );
    await _storage.delete(key: storageKey);
  }

  Future<void> _write(List<Landmark> landmarks) => _storage.write(
    key: storageKey,
    value: jsonEncode({
      'version': 1,
      'landmarks': landmarks.map((entry) => entry.toJson()).toList(),
    }),
  );
}

/// Retains shared callers' directory.path wiring without a browser filesystem.
class DemoPhotoDirectory {
  const DemoPhotoDirectory(this.path);
  final String path;
}

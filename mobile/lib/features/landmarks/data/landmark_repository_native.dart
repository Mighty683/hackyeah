import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

import 'landmark.dart';
import '../../../platform/app_storage.dart';

/// Encrypted metadata and app-private photo files; no sync or route recording.
/// Photos are ordinary files, not covered by the metadata's encryption claim.
class LandmarkRepository {
  LandmarkRepository({
    FlutterSecureStorage? storage,
    Future<Directory> Function()? supportDirectory,
  }) : _storage = storage ?? defaultAppStorage(),
       _supportDirectory = supportDirectory ?? getApplicationSupportDirectory;

  static const storageKey = 'basebound.landmarks.v1';
  final FlutterSecureStorage _storage;
  final Future<Directory> Function() _supportDirectory;

  Future<Directory> photoDirectory() async {
    final root = await _supportDirectory();
    return Directory('${root.path}/basebound_landmarks');
  }

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

  /// Copy camera-cache images before committing their references. A failed
  /// metadata write removes the new copy and leaves existing records intact.
  Future<void> save(
    Landmark landmark, {
    String? sourcePhoto,
    List<int>? photoBytes,
  }) async {
    if (sourcePhoto != null && photoBytes != null) {
      throw ArgumentError('Choose one photo source');
    }
    Landmark.fromJson(landmark.toJson());
    final landmarks = await load();
    final index = landmarks.indexWhere((entry) => entry.id == landmark.id);
    File? copiedPhoto;
    if (sourcePhoto != null || photoBytes != null) {
      if (index >= 0) throw StateError('Photo replacement is not supported');
      final directory = await photoDirectory();
      await directory.create(recursive: true);
      final destination = File('${directory.path}/${landmark.photoName}');
      if (await destination.exists()) throw StateError('Photo already exists');
      try {
        copiedPhoto = destination;
        if (photoBytes != null) {
          await destination.writeAsBytes(photoBytes, flush: true);
        } else {
          await File(sourcePhoto!).copy(destination.path);
        }
      } catch (_) {
        if (await destination.exists()) await destination.delete();
        rethrow;
      }
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
      if (copiedPhoto != null && await copiedPhoto.exists()) {
        await copiedPhoto.delete();
      }
      rethrow;
    }
  }

  Future<void> delete(Landmark landmark) async {
    await _write(
      (await load()).where((entry) => entry.id != landmark.id).toList(),
    );
    final directory = await photoDirectory();
    final photo = File('${directory.path}/${landmark.photoName}');
    if (await photo.exists()) await photo.delete();
  }

  /// Removes even orphaned photos from interrupted saves, without touching the
  /// camera gallery or the separate family-plan record.
  Future<void> deleteAll() async {
    final directory = await photoDirectory();
    if (await directory.exists()) await directory.delete(recursive: true);
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

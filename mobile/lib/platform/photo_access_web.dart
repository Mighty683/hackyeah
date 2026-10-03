import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import 'demo_session.dart';

Future<Uint8List> readPhotoBytes(String path) async {
  if (path.startsWith('assets/')) {
    final data = await rootBundle.load(path);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
  final bytes = DemoSession.instance.photos[path];
  if (bytes == null) throw StateError('Photo unavailable');
  return bytes;
}

Future<bool> photoExists(String path) async =>
    path.startsWith('assets/') || DemoSession.instance.photos.containsKey(path);

Future<void> deletePhotoIfExists(String path) async {
  DemoSession.instance.photos.remove(path);
}

ImageProvider photoImageProvider(String path) => path.startsWith('assets/')
    ? AssetImage(path)
    : MemoryImage(DemoSession.instance.photos[path] ?? Uint8List(0));

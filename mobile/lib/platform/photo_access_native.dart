import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/painting.dart';

Future<Uint8List> readPhotoBytes(String path) => File(path).readAsBytes();
Future<bool> photoExists(String path) => File(path).exists();
Future<void> deletePhotoIfExists(String path) async {
  final file = File(path);
  if (await file.exists()) await file.delete();
}

ImageProvider photoImageProvider(String path) => FileImage(File(path));

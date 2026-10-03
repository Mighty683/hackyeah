import 'dart:typed_data';

/// Browser demo data shared across routes. Refresh/reset discards all edits.
/// This store is never used for Android records or presented as encryption.
class DemoSession {
  DemoSession._();

  static final instance = DemoSession._();

  final records = <String, String>{};
  final photos = <String, Uint8List>{};

  void reset() {
    records.clear();
    photos.clear();
  }
}

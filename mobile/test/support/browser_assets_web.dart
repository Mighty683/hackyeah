import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

@JS('fetch')
external JSPromise<_AssetResponse> _fetch(JSString url);

extension type _AssetResponse(JSObject _) implements JSObject {
  external bool get ok;
  external int get status;
  external JSPromise<JSArrayBuffer> arrayBuffer();
}

/// Flutter Chrome widget tests intentionally ignore engine platform messages,
/// including flutter/assets. The tracked test/assets symlink lets the Chrome
/// test server fetch genuine repository images/maps without building a bundle.
/// This project has no image-resolution variants; an empty generated manifest
/// keeps AssetImage on its original asset key, which is fetched unchanged.
void installBrowserAssetLoader() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (message) async {
        final key = utf8.decode(
          message!.buffer.asUint8List(
            message.offsetInBytes,
            message.lengthInBytes,
          ),
        );
        if (key == 'AssetManifest.bin.json') {
          final binary = const StandardMessageCodec().encodeMessage(
            <String, Object>{},
          )!;
          return ByteData.sublistView(
            Uint8List.fromList(
              utf8.encode(
                jsonEncode(
                  base64Encode(
                    binary.buffer.asUint8List(
                      binary.offsetInBytes,
                      binary.lengthInBytes,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        final response = await _fetch('/$key'.toJS).toDart;
        if (!response.ok) {
          throw StateError(
            'Browser test asset $key returned ${response.status}. '
            'Check the tracked test/assets symlink.',
          );
        }
        final buffer = await response.arrayBuffer().toDart;
        return ByteData.view(buffer.toDart);
      });
}

void removeBrowserAssetLoader() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', null);
}

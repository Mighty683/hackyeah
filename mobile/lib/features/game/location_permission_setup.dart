import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../platform/app_storage.dart';

import 'package:geolocator/geolocator.dart';

import 'navigation_location.dart';

enum LocationPermissionStatus { granted, denied, settingsRequired, unavailable }

/// Permission setup never tracks positions. The visible map and help can.
class LocationPermissionSetup {
  LocationPermissionSetup({
    LocationSource? source,
    FlutterSecureStorage? storage,
    Future<bool> Function()? openSettings,
  }) : _source = source ?? defaultLocationSource(),
       _storage = storage ?? defaultAppStorage(),
       _openSettings =
           openSettings ??
           (kIsWeb ? () async => false : Geolocator.openAppSettings);

  static const _attemptKey = 'basebound.location_permission_attempted.v1';
  final LocationSource _source;
  final FlutterSecureStorage _storage;
  final Future<bool> Function() _openSettings;
  Future<LocationPermissionStatus>? _startup;

  /// Ask once on first launch, including when the child journey is chosen first.
  /// The marker is separate from family details so deleting them cannot nag.
  Future<LocationPermissionStatus> ensureRequestedOnce({
    Future<void> Function()? beforeRequest,
  }) => _startup ??= _ensureRequestedOnce(beforeRequest);

  Future<LocationPermissionStatus> _ensureRequestedOnce(
    Future<void> Function()? beforeRequest,
  ) async {
    try {
      final permission = await _source.permission();
      if (permission != LocationPermission.denied) return _status(permission);
      if (await _storage.read(key: _attemptKey) != null) {
        return LocationPermissionStatus.denied;
      }
      await beforeRequest?.call();
      // Persist before showing Android's dialog, including interrupted requests.
      await _storage.write(key: _attemptKey, value: 'true');
      await beforeRequest?.call();
      return _status(await _source.requestPermission());
    } catch (_) {
      return LocationPermissionStatus.unavailable;
    }
  }

  Future<LocationPermissionStatus> check() async {
    try {
      return _status(await _source.permission());
    } catch (_) {
      return LocationPermissionStatus.unavailable;
    }
  }

  /// An adult may explicitly retry after denial; child maps never call this.
  Future<LocationPermissionStatus> requestFromAdult() async {
    try {
      var permission = await _source.permission();
      if (permission == LocationPermission.denied) {
        await _storage.write(key: _attemptKey, value: 'true');
        permission = await _source.requestPermission();
      }
      return _status(permission);
    } catch (_) {
      return LocationPermissionStatus.unavailable;
    }
  }

  Future<bool> openSettings() async {
    try {
      return await _openSettings();
    } catch (_) {
      return false;
    }
  }

  static LocationPermissionStatus _status(LocationPermission permission) =>
      switch (permission) {
        LocationPermission.always ||
        LocationPermission.whileInUse => LocationPermissionStatus.granted,
        LocationPermission.denied => LocationPermissionStatus.denied,
        LocationPermission.deniedForever =>
          LocationPermissionStatus.settingsRequired,
        _ => LocationPermissionStatus.unavailable,
      };
}

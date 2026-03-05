import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';

import '../storage/secure_storage.dart';

class BiometricService {
  final LocalAuthentication _localAuth;
  final SecureStorage _storage;

  static const _key = 'biometric_enabled';

  BiometricService({
    required LocalAuthentication localAuth,
    required SecureStorage storage,
  })  : _localAuth = localAuth,
        _storage = storage;

  Future<bool> isDeviceSupported() async {
    if (kIsWeb) return false;
    return await _localAuth.isDeviceSupported();
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _key);
    return value == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    if (enabled) {
      await _storage.write(key: _key, value: 'true');
    } else {
      await _storage.delete(key: _key);
    }
  }

  Future<bool> authenticate() async {
    if (kIsWeb) return false;
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access AnticiFi',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}

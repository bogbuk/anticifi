import 'dart:io' show Platform;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Platform-aware secure storage wrapper.
/// Uses FlutterSecureStorage on iOS/Android, in-memory map on macOS (dev).
class SecureStorage {
  final FlutterSecureStorage _storage;
  final Map<String, String> _memoryStore = {};
  final bool _useMemory;

  SecureStorage(this._storage) : _useMemory = Platform.isMacOS;

  Future<String?> read({required String key}) async {
    if (_useMemory) return _memoryStore[key];
    return await _storage.read(key: key);
  }

  Future<void> write({required String key, required String value}) async {
    if (_useMemory) {
      _memoryStore[key] = value;
      return;
    }
    await _storage.write(key: key, value: value);
  }

  Future<void> delete({required String key}) async {
    if (_useMemory) {
      _memoryStore.remove(key);
      return;
    }
    await _storage.delete(key: key);
  }
}

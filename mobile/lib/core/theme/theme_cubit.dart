import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/secure_storage.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final SecureStorage _storage;
  static const _key = 'theme_mode';

  ThemeCubit({required SecureStorage storage})
      : _storage = storage,
        super(const ThemeState(themeMode: ThemeMode.system)) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final saved = await _storage.read(key: _key);
    if (saved != null) {
      emit(ThemeState(themeMode: _parseThemeMode(saved)));
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _storage.write(key: _key, value: _themeModeToString(mode));
    emit(ThemeState(themeMode: mode));
  }

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
  }
}

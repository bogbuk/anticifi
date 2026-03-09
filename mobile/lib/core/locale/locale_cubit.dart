import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/secure_storage.dart';
import 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  final SecureStorage _storage;
  static const _key = 'app_locale';

  LocaleCubit({required SecureStorage storage})
      : _storage = storage,
        super(const LocaleState(locale: Locale('en'))) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final saved = await _storage.read(key: _key);
    if (saved != null) {
      emit(LocaleState(locale: Locale(saved)));
    }
  }

  Future<void> setLocale(Locale locale) async {
    await _storage.write(key: _key, value: locale.languageCode);
    emit(LocaleState(locale: locale));
  }
}

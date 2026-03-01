import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;

  SettingsCubit(this._repository) : super(const SettingsInitial());

  Future<void> loadProfile() async {
    emit(const SettingsLoading());
    try {
      final profile = await _repository.getProfile();
      emit(SettingsLoaded(profile));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> updateProfile(Map<String, dynamic> params) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      emit(SettingsUpdating(currentState.profile));
    }
    try {
      final profile = await _repository.updateProfile(params);
      emit(SettingsUpdated(profile));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _repository.deleteAccount();
      emit(const SettingsAccountDeleted());
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
}

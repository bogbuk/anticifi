import 'package:equatable/equatable.dart';

import '../../domain/entities/user_profile_entity.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final UserProfileEntity profile;

  const SettingsLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class SettingsUpdating extends SettingsState {
  final UserProfileEntity profile;

  const SettingsUpdating(this.profile);

  @override
  List<Object?> get props => [profile];
}

class SettingsUpdated extends SettingsState {
  final UserProfileEntity profile;

  const SettingsUpdated(this.profile);

  @override
  List<Object?> get props => [profile];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

class SettingsAccountDeleted extends SettingsState {
  const SettingsAccountDeleted();
}

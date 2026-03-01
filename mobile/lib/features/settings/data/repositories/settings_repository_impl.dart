import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource _remoteDataSource;

  SettingsRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserProfileEntity> getProfile() async {
    return await _remoteDataSource.getProfile();
  }

  @override
  Future<UserProfileEntity> updateProfile(Map<String, dynamic> params) async {
    return await _remoteDataSource.updateProfile(params);
  }

  @override
  Future<void> deleteAccount() async {
    await _remoteDataSource.deleteAccount();
  }
}

import '../entities/user_profile_entity.dart';

abstract class SettingsRepository {
  Future<UserProfileEntity> getProfile();
  Future<UserProfileEntity> updateProfile(Map<String, dynamic> params);
  Future<void> deleteAccount();
}

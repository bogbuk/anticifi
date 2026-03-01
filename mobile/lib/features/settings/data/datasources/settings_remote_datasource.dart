import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_profile_model.dart';

class SettingsRemoteDataSource {
  final DioClient dioClient;

  SettingsRemoteDataSource({required this.dioClient});

  Future<UserProfileModel> getProfile() async {
    final response = await dioClient.dio.get(ApiEndpoints.userProfile);
    final data = response.data as Map<String, dynamic>;
    return UserProfileModel.fromJson(data);
  }

  Future<UserProfileModel> updateProfile(Map<String, dynamic> params) async {
    final response = await dioClient.dio.patch(
      ApiEndpoints.userProfile,
      data: params,
    );
    final data = response.data as Map<String, dynamic>;
    return UserProfileModel.fromJson(data);
  }

  Future<void> deleteAccount() async {
    await dioClient.dio.delete(ApiEndpoints.userAccount);
  }
}

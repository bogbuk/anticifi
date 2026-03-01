import '../../../../core/storage/secure_storage.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final DioClient dioClient;
  final SecureStorage storage;

  AuthRemoteDataSource({
    required this.dioClient,
    required this.storage,
  });

  Future<UserModel> login(String email, String password) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;
    await _saveTokens(data);

    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> register(
      String name, String email, String password) async {
    final nameParts = name.trim().split(' ');
    final response = await dioClient.dio.post(
      ApiEndpoints.register,
      data: {
        'firstName': nameParts.first,
        'lastName': nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null,
        'email': email,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;
    await _saveTokens(data);

    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> refreshToken() async {
    final refreshToken = await storage.read(key: 'refresh_token');
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await dioClient.dio.post(
      ApiEndpoints.refresh,
      data: {'refreshToken': refreshToken},
    );

    final data = response.data as Map<String, dynamic>;
    await _saveTokens(data);
  }

  Future<UserModel> getUserProfile() async {
    final response = await dioClient.dio.get(ApiEndpoints.userProfile);
    final data = response.data as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  Future<void> logout() async {
    try {
      await dioClient.dio.post(ApiEndpoints.logout);
    } finally {
      await storage.delete(key: 'access_token');
      await storage.delete(key: 'refresh_token');
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await storage.read(key: 'access_token');
    return token != null;
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    if (data.containsKey('accessToken')) {
      await storage.write(
          key: 'access_token', value: data['accessToken'] as String);
    }
    if (data.containsKey('refreshToken')) {
      await storage.write(
          key: 'refresh_token', value: data['refreshToken'] as String);
    }
  }
}

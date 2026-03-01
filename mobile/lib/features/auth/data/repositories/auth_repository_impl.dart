import 'package:dio/dio.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      return await _remoteDataSource.login(email, password);
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Login failed'));
    }
  }

  @override
  Future<UserEntity> register(
      String name, String email, String password) async {
    try {
      return await _remoteDataSource.register(name, email, password);
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Registration failed'));
    }
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _remoteDataSource.isAuthenticated();
  }

  @override
  Future<UserEntity> getUserProfile() async {
    try {
      return await _remoteDataSource.getUserProfile();
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to get profile'));
    }
  }

  String _parseError(DioException e, {required String fallback}) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (data is Map<String, dynamic> && data.containsKey('message')) {
      final msg = data['message'];
      if (msg is List) return msg.join(', ');
      return msg.toString();
    }

    switch (statusCode) {
      case 400:
        return 'Please fill in all fields correctly';
      case 401:
        return 'Invalid email or password';
      case 409:
        return 'An account with this email already exists';
      default:
        return fallback;
    }
  }
}

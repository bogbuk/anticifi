import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_endpoints.dart';

class DioClient {
  final Dio dio;
  final FlutterSecureStorage _storage;

  DioClient(this._storage)
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(_authInterceptor());
    dio.interceptors.add(_refreshInterceptor());
  }

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    );
  }

  InterceptorsWrapper _refreshInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          try {
            final refreshToken = await _storage.read(key: 'refresh_token');
            if (refreshToken == null) {
              return handler.next(error);
            }

            final refreshDio = Dio(BaseOptions(
              baseUrl: ApiEndpoints.baseUrl,
            ));

            final response = await refreshDio.post(
              ApiEndpoints.refresh,
              data: {'refreshToken': refreshToken},
            );

            final newAccessToken = response.data['accessToken'] as String;
            final newRefreshToken = response.data['refreshToken'] as String;

            await _storage.write(key: 'access_token', value: newAccessToken);
            await _storage.write(key: 'refresh_token', value: newRefreshToken);

            // Retry original request
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await dio.fetch(opts);
            return handler.resolve(retryResponse);
          } catch (_) {
            // Refresh failed — clear tokens
            await _storage.delete(key: 'access_token');
            await _storage.delete(key: 'refresh_token');
            return handler.next(error);
          }
        }
        handler.next(error);
      },
    );
  }
}

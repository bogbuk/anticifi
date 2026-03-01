import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:anticifi/core/network/dio_client.dart';
import 'package:anticifi/features/settings/data/datasources/settings_remote_datasource.dart';

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockDioClient mockDioClient;
  late MockDio mockDio;
  late SettingsRemoteDataSource dataSource;

  setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    when(() => mockDioClient.dio).thenReturn(mockDio);
    dataSource = SettingsRemoteDataSource(dioClient: mockDioClient);
  });

  group('SettingsRemoteDataSource', () {
    group('getProfile', () {
      test('should return UserProfileModel', () async {
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              data: {
                'id': 'user-1',
                'email': 'test@example.com',
                'firstName': 'John',
                'lastName': 'Doe',
                'currency': 'USD',
                'locale': 'en',
                'notificationsEnabled': true,
                'theme': 'system',
                'createdAt': '2026-01-01T00:00:00.000Z',
              },
              statusCode: 200,
              requestOptions: RequestOptions(path: '/users/profile'),
            ));

        final result = await dataSource.getProfile();

        expect(result.id, 'user-1');
        expect(result.firstName, 'John');
        expect(result.lastName, 'Doe');
        expect(result.fullName, 'John Doe');
      });
    });

    group('updateProfile', () {
      test('should send PATCH and return updated profile', () async {
        when(() => mockDio.patch(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              data: {
                'id': 'user-1',
                'email': 'test@example.com',
                'firstName': 'Jane',
                'lastName': 'Doe',
                'currency': 'EUR',
                'locale': 'en',
                'notificationsEnabled': true,
                'theme': 'system',
                'createdAt': '2026-01-01T00:00:00.000Z',
              },
              statusCode: 200,
              requestOptions: RequestOptions(path: '/users/profile'),
            ));

        final result = await dataSource.updateProfile({
          'firstName': 'Jane',
          'currency': 'EUR',
        });

        expect(result.firstName, 'Jane');
        expect(result.currency, 'EUR');
      });
    });

    group('deleteAccount', () {
      test('should send DELETE request', () async {
        when(() => mockDio.delete(any())).thenAnswer((_) async => Response(
              statusCode: 204,
              requestOptions: RequestOptions(path: '/users/account'),
            ));

        await dataSource.deleteAccount();

        verify(() => mockDio.delete(any())).called(1);
      });
    });
  });
}

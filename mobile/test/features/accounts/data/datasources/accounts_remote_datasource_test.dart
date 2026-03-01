import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:anticifi/core/network/dio_client.dart';
import 'package:anticifi/features/accounts/data/datasources/accounts_remote_datasource.dart';

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockDioClient mockDioClient;
  late MockDio mockDio;
  late AccountsRemoteDataSource dataSource;

  setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    when(() => mockDioClient.dio).thenReturn(mockDio);
    dataSource = AccountsRemoteDataSource(dioClient: mockDioClient);
  });

  group('AccountsRemoteDataSource', () {
    group('getAccounts', () {
      test('should return list of AccountModel', () async {
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              data: [
                {
                  'id': 'acc-1',
                  'userId': 'user-1',
                  'name': 'Checking',
                  'type': 'checking',
                  'currency': 'USD',
                  'balance': 1500.0,
                  'initialBalance': 1000.0,
                },
              ],
              statusCode: 200,
              requestOptions: RequestOptions(path: '/accounts'),
            ));

        final result = await dataSource.getAccounts();

        expect(result.length, 1);
        expect(result[0].id, 'acc-1');
        expect(result[0].name, 'Checking');
      });
    });

    group('createAccount', () {
      test('should send POST and return AccountModel', () async {
        when(() => mockDio.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              data: {
                'id': 'acc-new',
                'userId': 'user-1',
                'name': 'New Account',
                'type': 'savings',
                'currency': 'USD',
                'balance': 0.0,
                'initialBalance': 0.0,
              },
              statusCode: 201,
              requestOptions: RequestOptions(path: '/accounts'),
            ));

        final result = await dataSource.createAccount({
          'name': 'New Account',
          'type': 'savings',
        });

        expect(result.id, 'acc-new');
      });
    });

    group('updateAccount', () {
      test('should send PATCH (not PUT) request', () async {
        when(() => mockDio.patch(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              data: {
                'id': 'acc-1',
                'userId': 'user-1',
                'name': 'Updated',
                'type': 'checking',
                'currency': 'EUR',
                'balance': 1500.0,
                'initialBalance': 1000.0,
              },
              statusCode: 200,
              requestOptions: RequestOptions(path: '/accounts/acc-1'),
            ));

        final result = await dataSource.updateAccount(
          'acc-1',
          {'name': 'Updated', 'currency': 'EUR'},
        );

        expect(result.name, 'Updated');
        verify(() => mockDio.patch(
              any(),
              data: any(named: 'data'),
            )).called(1);
      });
    });

    group('deleteAccount', () {
      test('should send DELETE request', () async {
        when(() => mockDio.delete(any())).thenAnswer((_) async => Response(
              statusCode: 204,
              requestOptions: RequestOptions(path: '/accounts/acc-1'),
            ));

        await dataSource.deleteAccount('acc-1');

        verify(() => mockDio.delete(any())).called(1);
      });
    });
  });
}

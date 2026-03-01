import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:anticifi/core/network/dio_client.dart';
import 'package:anticifi/features/scheduled_payments/data/datasources/scheduled_payments_remote_datasource.dart';

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockDioClient mockDioClient;
  late MockDio mockDio;
  late ScheduledPaymentsRemoteDataSource dataSource;

  setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    when(() => mockDioClient.dio).thenReturn(mockDio);
    dataSource = ScheduledPaymentsRemoteDataSource(dioClient: mockDioClient);
  });

  group('ScheduledPaymentsRemoteDataSource', () {
    group('getScheduledPayments', () {
      test('should return list of ScheduledPaymentModel', () async {
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              data: {
                'data': [
                  {
                    'id': 'sp-1',
                    'account': {
                      'id': 'acc-1',
                      'name': 'Checking',
                      'type': 'checking',
                      'currency': 'USD',
                    },
                    'name': 'Rent',
                    'amount': 1200.0,
                    'type': 'expense',
                    'frequency': 'monthly',
                    'startDate': '2026-01-01T00:00:00.000Z',
                    'nextExecutionDate': '2026-04-01T00:00:00.000Z',
                    'isActive': true,
                  },
                ],
              },
              statusCode: 200,
              requestOptions: RequestOptions(path: '/scheduled-payments'),
            ));

        final result = await dataSource.getScheduledPayments();

        expect(result.length, 1);
        expect(result[0].id, 'sp-1');
        expect(result[0].accountId, 'acc-1');
        expect(result[0].accountName, 'Checking');
      });
    });

    group('createScheduledPayment', () {
      test('should send POST and return model', () async {
        when(() => mockDio.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              data: {
                'id': 'sp-new',
                'accountId': 'acc-1',
                'accountName': 'Checking',
                'name': 'Gym',
                'amount': 50.0,
                'type': 'expense',
                'frequency': 'monthly',
                'startDate': '2026-03-01T00:00:00.000Z',
                'nextExecutionDate': '2026-04-01T00:00:00.000Z',
                'isActive': true,
              },
              statusCode: 201,
              requestOptions: RequestOptions(path: '/scheduled-payments'),
            ));

        final result = await dataSource.createScheduledPayment({
          'name': 'Gym',
          'amount': 50.0,
        });

        expect(result.id, 'sp-new');
        expect(result.name, 'Gym');
      });
    });

    group('updateScheduledPayment', () {
      test('should send PATCH (not PUT) request', () async {
        when(() => mockDio.patch(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              data: {
                'id': 'sp-1',
                'accountId': 'acc-1',
                'accountName': 'Checking',
                'name': 'Updated Rent',
                'amount': 1300.0,
                'type': 'expense',
                'frequency': 'monthly',
                'startDate': '2026-01-01T00:00:00.000Z',
                'nextExecutionDate': '2026-04-01T00:00:00.000Z',
                'isActive': true,
              },
              statusCode: 200,
              requestOptions:
                  RequestOptions(path: '/scheduled-payments/sp-1'),
            ));

        final result = await dataSource.updateScheduledPayment(
          'sp-1',
          {'name': 'Updated Rent', 'amount': 1300.0},
        );

        expect(result.name, 'Updated Rent');
        verify(() => mockDio.patch(
              any(),
              data: any(named: 'data'),
            )).called(1);
      });
    });

    group('deleteScheduledPayment', () {
      test('should send DELETE request', () async {
        when(() => mockDio.delete(any())).thenAnswer((_) async => Response(
              statusCode: 204,
              requestOptions:
                  RequestOptions(path: '/scheduled-payments/sp-1'),
            ));

        await dataSource.deleteScheduledPayment('sp-1');

        verify(() => mockDio.delete(any())).called(1);
      });
    });

    group('executeScheduledPayment', () {
      test('should send POST to execute endpoint', () async {
        when(() => mockDio.post(any())).thenAnswer((_) async => Response(
              data: {
                'id': 'sp-1',
                'accountId': 'acc-1',
                'accountName': 'Checking',
                'name': 'Rent',
                'amount': 1200.0,
                'type': 'expense',
                'frequency': 'monthly',
                'startDate': '2026-01-01T00:00:00.000Z',
                'nextExecutionDate': '2026-05-01T00:00:00.000Z',
                'isActive': true,
                'lastExecutedAt': '2026-04-01T00:00:00.000Z',
              },
              statusCode: 200,
              requestOptions:
                  RequestOptions(path: '/scheduled-payments/sp-1/execute'),
            ));

        final result = await dataSource.executeScheduledPayment('sp-1');

        expect(result.lastExecutedAt, isNotNull);
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:anticifi/core/network/dio_client.dart';
import 'package:anticifi/features/transactions/data/datasources/transactions_remote_datasource.dart';

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockDioClient mockDioClient;
  late MockDio mockDio;
  late TransactionsRemoteDataSource dataSource;

  setUp(() {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    when(() => mockDioClient.dio).thenReturn(mockDio);
    dataSource = TransactionsRemoteDataSource(dioClient: mockDioClient);
  });

  group('TransactionsRemoteDataSource', () {
    group('getTransactions', () {
      test('should return TransactionsResponse on success', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: {
                'data': [
                  {
                    'id': 'txn-1',
                    'accountId': 'acc-1',
                    'amount': 100.0,
                    'type': 'expense',
                    'date': '2026-03-01T10:00:00.000Z',
                  },
                ],
                'total': 1,
                'totalPages': 1,
              },
              statusCode: 200,
              requestOptions: RequestOptions(path: '/transactions'),
            ));

        final result = await dataSource.getTransactions();

        expect(result.transactions.length, 1);
        expect(result.transactions[0].id, 'txn-1');
        expect(result.total, 1);
        expect(result.hasMore, false);
      });

      test('should pass query parameters', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: {'data': [], 'total': 0, 'totalPages': 0},
              statusCode: 200,
              requestOptions: RequestOptions(path: '/transactions'),
            ));

        await dataSource.getTransactions(page: 2, type: 'income');

        verify(() => mockDio.get(
              any(),
              queryParameters: {
                'page': 2,
                'limit': 20,
                'type': 'income',
              },
            )).called(1);
      });
    });

    group('createTransaction', () {
      test('should send POST and return TransactionModel', () async {
        when(() => mockDio.post(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              data: {
                'id': 'txn-new',
                'accountId': 'acc-1',
                'amount': 50.0,
                'type': 'expense',
                'date': '2026-03-01T10:00:00.000Z',
              },
              statusCode: 201,
              requestOptions: RequestOptions(path: '/transactions'),
            ));

        final result = await dataSource.createTransaction({
          'accountId': 'acc-1',
          'amount': 50.0,
          'type': 'expense',
        });

        expect(result.id, 'txn-new');
        expect(result.amount, 50.0);
      });
    });

    group('updateTransaction', () {
      test('should send PATCH (not PUT) request', () async {
        when(() => mockDio.patch(
              any(),
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              data: {
                'id': 'txn-1',
                'accountId': 'acc-1',
                'amount': 75.0,
                'type': 'expense',
                'date': '2026-03-01T10:00:00.000Z',
              },
              statusCode: 200,
              requestOptions: RequestOptions(path: '/transactions/txn-1'),
            ));

        final result = await dataSource.updateTransaction(
          'txn-1',
          {'amount': 75.0},
        );

        expect(result.amount, 75.0);
        verify(() => mockDio.patch(
              any(),
              data: any(named: 'data'),
            )).called(1);
      });
    });

    group('deleteTransaction', () {
      test('should send DELETE request', () async {
        when(() => mockDio.delete(any())).thenAnswer((_) async => Response(
              statusCode: 204,
              requestOptions: RequestOptions(path: '/transactions/txn-1'),
            ));

        await dataSource.deleteTransaction('txn-1');

        verify(() => mockDio.delete(any())).called(1);
      });
    });
  });
}

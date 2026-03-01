import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:anticifi/features/transactions/domain/entities/transaction_entity.dart';
import 'package:anticifi/features/transactions/domain/repositories/transactions_repository.dart';
import 'package:anticifi/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:anticifi/features/transactions/presentation/bloc/transactions_event.dart';
import 'package:anticifi/features/transactions/presentation/bloc/transactions_state.dart';

class MockTransactionsRepository extends Mock
    implements TransactionsRepository {}

void main() {
  late MockTransactionsRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionsRepository();
  });

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  final testTransactions = [
    TransactionEntity(
      id: 'txn-1',
      accountId: 'acc-1',
      amount: 250.0,
      type: 'expense',
      description: 'Groceries',
      categoryName: 'Food',
      date: DateTime.parse('2026-03-01T10:00:00.000Z'),
    ),
    TransactionEntity(
      id: 'txn-2',
      accountId: 'acc-1',
      amount: 3000.0,
      type: 'income',
      description: 'Salary',
      date: DateTime.parse('2026-03-01T08:00:00.000Z'),
    ),
  ];

  final testResponse = TransactionsResponse(
    transactions: testTransactions,
    total: 2,
    hasMore: false,
  );

  group('TransactionsBloc', () {
    test('initial state is TransactionsInitial', () {
      final bloc = TransactionsBloc(mockRepository);
      expect(bloc.state, const TransactionsInitial());
      bloc.close();
    });

    group('LoadTransactions', () {
      blocTest<TransactionsBloc, TransactionsState>(
        'emits [Loading, Loaded] when LoadTransactions succeeds',
        build: () {
          when(() => mockRepository.getTransactions(
                page: any(named: 'page'),
                type: any(named: 'type'),
                dateFrom: any(named: 'dateFrom'),
                dateTo: any(named: 'dateTo'),
              )).thenAnswer((_) async => testResponse);
          return TransactionsBloc(mockRepository);
        },
        act: (bloc) => bloc.add(const LoadTransactions()),
        expect: () => [
          const TransactionsLoading(),
          isA<TransactionsLoaded>()
              .having((s) => s.transactions.length, 'count', 2)
              .having((s) => s.hasMore, 'hasMore', false)
              .having((s) => s.total, 'total', 2),
        ],
      );

      blocTest<TransactionsBloc, TransactionsState>(
        'emits [Loading, Error] when LoadTransactions fails',
        build: () {
          when(() => mockRepository.getTransactions(
                page: any(named: 'page'),
                type: any(named: 'type'),
                dateFrom: any(named: 'dateFrom'),
                dateTo: any(named: 'dateTo'),
              )).thenThrow(Exception('Network error'));
          return TransactionsBloc(mockRepository);
        },
        act: (bloc) => bloc.add(const LoadTransactions()),
        expect: () => [
          const TransactionsLoading(),
          isA<TransactionsError>(),
        ],
      );

      blocTest<TransactionsBloc, TransactionsState>(
        'passes filter params to repository',
        build: () {
          when(() => mockRepository.getTransactions(
                page: any(named: 'page'),
                type: any(named: 'type'),
                dateFrom: any(named: 'dateFrom'),
                dateTo: any(named: 'dateTo'),
              )).thenAnswer((_) async => testResponse);
          return TransactionsBloc(mockRepository);
        },
        act: (bloc) => bloc.add(const LoadTransactions(
          page: 2,
          typeFilter: 'expense',
        )),
        verify: (_) {
          verify(() => mockRepository.getTransactions(
                page: 2,
                type: 'expense',
                dateFrom: null,
                dateTo: null,
              )).called(1);
        },
      );
    });

    group('CreateTransaction', () {
      blocTest<TransactionsBloc, TransactionsState>(
        'creates transaction and reloads list',
        build: () {
          when(() => mockRepository.createTransaction(any()))
              .thenAnswer((_) async => testTransactions.first);
          when(() => mockRepository.getTransactions(
                page: any(named: 'page'),
                type: any(named: 'type'),
                dateFrom: any(named: 'dateFrom'),
                dateTo: any(named: 'dateTo'),
              )).thenAnswer((_) async => testResponse);
          return TransactionsBloc(mockRepository);
        },
        act: (bloc) => bloc.add(const CreateTransaction({
          'accountId': 'acc-1',
          'amount': 50.0,
          'type': 'expense',
        })),
        verify: (_) {
          verify(() => mockRepository.createTransaction(any())).called(1);
        },
      );
    });

    group('DeleteTransaction', () {
      blocTest<TransactionsBloc, TransactionsState>(
        'deletes transaction and reloads list',
        build: () {
          when(() => mockRepository.deleteTransaction('txn-1'))
              .thenAnswer((_) async {});
          when(() => mockRepository.getTransactions(
                page: any(named: 'page'),
                type: any(named: 'type'),
                dateFrom: any(named: 'dateFrom'),
                dateTo: any(named: 'dateTo'),
              )).thenAnswer((_) async => testResponse);
          return TransactionsBloc(mockRepository);
        },
        act: (bloc) => bloc.add(const DeleteTransaction('txn-1')),
        verify: (_) {
          verify(() => mockRepository.deleteTransaction('txn-1')).called(1);
        },
      );
    });
  });
}

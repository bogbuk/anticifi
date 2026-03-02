import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:anticifi/features/accounts/domain/entities/account_entity.dart';
import 'package:anticifi/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:anticifi/features/accounts/data/datasources/plaid_remote_datasource.dart';
import 'package:anticifi/features/accounts/presentation/bloc/accounts_cubit.dart';
import 'package:anticifi/features/accounts/presentation/bloc/accounts_state.dart';

class MockAccountsRepository extends Mock implements AccountsRepository {}

class MockPlaidRemoteDataSource extends Mock implements PlaidRemoteDataSource {}

void main() {
  late MockAccountsRepository mockRepository;
  late MockPlaidRemoteDataSource mockPlaidDataSource;

  setUp(() {
    mockRepository = MockAccountsRepository();
    mockPlaidDataSource = MockPlaidRemoteDataSource();
  });

  const testAccounts = [
    AccountEntity(
      id: 'acc-1',
      userId: 'user-1',
      name: 'Checking',
      type: 'checking',
      currency: 'USD',
      balance: 1500.0,
      initialBalance: 1000.0,
    ),
    AccountEntity(
      id: 'acc-2',
      userId: 'user-1',
      name: 'Savings',
      type: 'savings',
      currency: 'USD',
      balance: 5000.0,
      initialBalance: 3000.0,
    ),
  ];

  group('AccountsCubit', () {
    test('initial state is AccountsInitial', () {
      final cubit = AccountsCubit(mockRepository, mockPlaidDataSource);
      expect(cubit.state, const AccountsInitial());
      cubit.close();
    });

    group('loadAccounts', () {
      blocTest<AccountsCubit, AccountsState>(
        'emits [AccountsLoading, AccountsLoaded] when loadAccounts succeeds',
        build: () {
          when(() => mockRepository.getAccounts())
              .thenAnswer((_) async => testAccounts);
          return AccountsCubit(mockRepository, mockPlaidDataSource);
        },
        act: (cubit) => cubit.loadAccounts(),
        expect: () => [
          const AccountsLoading(),
          const AccountsLoaded(testAccounts),
        ],
      );

      blocTest<AccountsCubit, AccountsState>(
        'emits [AccountsLoading, AccountsError] when loadAccounts fails',
        build: () {
          when(() => mockRepository.getAccounts())
              .thenThrow(Exception('Failed to load accounts'));
          return AccountsCubit(mockRepository, mockPlaidDataSource);
        },
        act: (cubit) => cubit.loadAccounts(),
        expect: () => [
          const AccountsLoading(),
          isA<AccountsError>(),
        ],
      );
    });

    group('createAccount', () {
      blocTest<AccountsCubit, AccountsState>(
        'calls createAccount and reloads accounts on success',
        build: () {
          when(() => mockRepository.createAccount(any()))
              .thenAnswer((_) async => testAccounts.first);
          when(() => mockRepository.getAccounts())
              .thenAnswer((_) async => testAccounts);
          return AccountsCubit(mockRepository, mockPlaidDataSource);
        },
        act: (cubit) => cubit.createAccount({
          'name': 'New Account',
          'type': 'checking',
          'currency': 'USD',
        }),
        expect: () => [
          const AccountsLoading(),
          const AccountsLoaded(testAccounts),
        ],
        verify: (_) {
          verify(() => mockRepository.createAccount(any())).called(1);
          verify(() => mockRepository.getAccounts()).called(1);
        },
      );
    });

    group('deleteAccount', () {
      blocTest<AccountsCubit, AccountsState>(
        'calls deleteAccount and reloads accounts on success',
        build: () {
          when(() => mockRepository.deleteAccount('acc-1'))
              .thenAnswer((_) async {});
          when(() => mockRepository.getAccounts())
              .thenAnswer((_) async => [testAccounts[1]]);
          return AccountsCubit(mockRepository, mockPlaidDataSource);
        },
        act: (cubit) => cubit.deleteAccount('acc-1'),
        expect: () => [
          const AccountsLoading(),
          AccountsLoaded([testAccounts[1]]),
        ],
        verify: (_) {
          verify(() => mockRepository.deleteAccount('acc-1')).called(1);
          verify(() => mockRepository.getAccounts()).called(1);
        },
      );
    });
  });
}

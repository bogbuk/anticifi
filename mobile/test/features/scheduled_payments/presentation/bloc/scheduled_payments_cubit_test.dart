import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:anticifi/features/scheduled_payments/domain/entities/scheduled_payment_entity.dart';
import 'package:anticifi/features/scheduled_payments/domain/repositories/scheduled_payments_repository.dart';
import 'package:anticifi/features/scheduled_payments/presentation/bloc/scheduled_payments_cubit.dart';
import 'package:anticifi/features/scheduled_payments/presentation/bloc/scheduled_payments_state.dart';

class MockScheduledPaymentsRepository extends Mock
    implements ScheduledPaymentsRepository {}

void main() {
  late MockScheduledPaymentsRepository mockRepository;

  setUp(() {
    mockRepository = MockScheduledPaymentsRepository();
  });

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  final testPayments = [
    ScheduledPaymentEntity(
      id: 'sp-1',
      accountId: 'acc-1',
      accountName: 'Checking',
      name: 'Rent',
      amount: 1200.0,
      type: 'expense',
      frequency: 'monthly',
      startDate: DateTime.parse('2026-01-01T00:00:00.000Z'),
      nextExecutionDate: DateTime.parse('2026-04-01T00:00:00.000Z'),
      isActive: true,
    ),
  ];

  group('ScheduledPaymentsCubit', () {
    test('initial state is ScheduledPaymentsInitial', () {
      final cubit = ScheduledPaymentsCubit(mockRepository);
      expect(cubit.state, const ScheduledPaymentsInitial());
      cubit.close();
    });

    group('loadScheduledPayments', () {
      blocTest<ScheduledPaymentsCubit, ScheduledPaymentsState>(
        'emits [Loading, Loaded] when succeeds',
        build: () {
          when(() => mockRepository.getScheduledPayments())
              .thenAnswer((_) async => testPayments);
          return ScheduledPaymentsCubit(mockRepository);
        },
        act: (cubit) => cubit.loadScheduledPayments(),
        expect: () => [
          const ScheduledPaymentsLoading(),
          ScheduledPaymentsLoaded(testPayments),
        ],
      );

      blocTest<ScheduledPaymentsCubit, ScheduledPaymentsState>(
        'emits [Loading, Error] when fails',
        build: () {
          when(() => mockRepository.getScheduledPayments())
              .thenThrow(Exception('Failed'));
          return ScheduledPaymentsCubit(mockRepository);
        },
        act: (cubit) => cubit.loadScheduledPayments(),
        expect: () => [
          const ScheduledPaymentsLoading(),
          isA<ScheduledPaymentsError>(),
        ],
      );
    });

    group('createScheduledPayment', () {
      blocTest<ScheduledPaymentsCubit, ScheduledPaymentsState>(
        'creates and reloads payments',
        build: () {
          when(() => mockRepository.createScheduledPayment(any()))
              .thenAnswer((_) async => testPayments.first);
          when(() => mockRepository.getScheduledPayments())
              .thenAnswer((_) async => testPayments);
          return ScheduledPaymentsCubit(mockRepository);
        },
        act: (cubit) => cubit.createScheduledPayment({
          'name': 'New Payment',
          'amount': 50.0,
        }),
        verify: (_) {
          verify(() => mockRepository.createScheduledPayment(any())).called(1);
          verify(() => mockRepository.getScheduledPayments()).called(1);
        },
      );
    });

    group('deleteScheduledPayment', () {
      blocTest<ScheduledPaymentsCubit, ScheduledPaymentsState>(
        'deletes and reloads payments',
        build: () {
          when(() => mockRepository.deleteScheduledPayment('sp-1'))
              .thenAnswer((_) async {});
          when(() => mockRepository.getScheduledPayments())
              .thenAnswer((_) async => []);
          return ScheduledPaymentsCubit(mockRepository);
        },
        act: (cubit) => cubit.deleteScheduledPayment('sp-1'),
        verify: (_) {
          verify(() => mockRepository.deleteScheduledPayment('sp-1')).called(1);
          verify(() => mockRepository.getScheduledPayments()).called(1);
        },
      );
    });

    group('executeScheduledPayment', () {
      blocTest<ScheduledPaymentsCubit, ScheduledPaymentsState>(
        'executes and reloads payments',
        build: () {
          when(() => mockRepository.executeScheduledPayment('sp-1'))
              .thenAnswer((_) async => testPayments.first);
          when(() => mockRepository.getScheduledPayments())
              .thenAnswer((_) async => testPayments);
          return ScheduledPaymentsCubit(mockRepository);
        },
        act: (cubit) => cubit.executeScheduledPayment('sp-1'),
        verify: (_) {
          verify(() => mockRepository.executeScheduledPayment('sp-1'))
              .called(1);
        },
      );
    });
  });
}

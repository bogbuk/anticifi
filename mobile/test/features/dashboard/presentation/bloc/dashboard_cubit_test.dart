import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:anticifi/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:anticifi/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:anticifi/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:anticifi/features/dashboard/presentation/bloc/dashboard_state.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late MockDashboardRepository mockRepository;

  setUp(() {
    mockRepository = MockDashboardRepository();
  });

  const testDashboard = DashboardEntity(
    totalBalance: 5000.0,
    monthlyIncome: 3000.0,
    monthlyExpense: 1500.0,
    previousMonthIncome: 2800.0,
    previousMonthExpense: 1200.0,
    accounts: [],
    spendingByCategory: [],
    recentTransactions: [],
  );

  group('DashboardCubit', () {
    test('initial state is DashboardInitial', () {
      final cubit = DashboardCubit(mockRepository);
      expect(cubit.state, const DashboardInitial());
      cubit.close();
    });

    blocTest<DashboardCubit, DashboardState>(
      'emits [Loading, Loaded] when loadDashboard succeeds',
      build: () {
        when(() => mockRepository.getDashboard())
            .thenAnswer((_) async => testDashboard);
        return DashboardCubit(mockRepository);
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const DashboardLoading(),
        const DashboardLoaded(testDashboard),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'emits [Loading, Error] when loadDashboard fails',
      build: () {
        when(() => mockRepository.getDashboard())
            .thenThrow(Exception('Failed'));
        return DashboardCubit(mockRepository);
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const DashboardLoading(),
        isA<DashboardError>(),
      ],
    );
  });
}

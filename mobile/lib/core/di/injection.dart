import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../storage/secure_storage.dart';
import '../network/dio_client.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/accounts/data/datasources/accounts_remote_datasource.dart';
import '../../features/accounts/data/datasources/plaid_remote_datasource.dart';
import '../../features/accounts/data/repositories/accounts_repository_impl.dart';
import '../../features/accounts/domain/repositories/accounts_repository.dart';
import '../../features/accounts/presentation/bloc/accounts_cubit.dart';

import '../../features/transactions/data/datasources/transactions_remote_datasource.dart';
import '../../features/transactions/data/repositories/transactions_repository_impl.dart';
import '../../features/transactions/domain/repositories/transactions_repository.dart';
import '../../features/transactions/presentation/bloc/transactions_bloc.dart';

import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/presentation/bloc/dashboard_cubit.dart';

import '../../features/import/presentation/bloc/import_cubit.dart';

import '../../features/scheduled_payments/data/datasources/scheduled_payments_remote_datasource.dart';
import '../../features/scheduled_payments/data/repositories/scheduled_payments_repository_impl.dart';
import '../../features/scheduled_payments/domain/repositories/scheduled_payments_repository.dart';
import '../../features/scheduled_payments/presentation/bloc/scheduled_payments_cubit.dart';

import '../../features/oracle/data/datasources/oracle_remote_datasource.dart';
import '../../features/oracle/data/repositories/oracle_repository_impl.dart';
import '../../features/oracle/domain/repositories/oracle_repository.dart';
import '../../features/oracle/presentation/bloc/oracle_cubit.dart';

import '../../features/settings/data/datasources/settings_remote_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/bloc/settings_cubit.dart';

import '../../features/budgets/data/datasources/budgets_remote_datasource.dart';
import '../../features/budgets/data/repositories/budgets_repository_impl.dart';
import '../../features/budgets/domain/repositories/budgets_repository.dart';
import '../../features/budgets/presentation/bloc/budgets_cubit.dart';

import '../../features/debts/data/datasources/debts_remote_datasource.dart';
import '../../features/debts/data/repositories/debts_repository_impl.dart';
import '../../features/debts/domain/repositories/debts_repository.dart';
import '../../features/debts/presentation/bloc/debts_cubit.dart';

import '../../features/notifications/data/datasources/notifications_remote_datasource.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/presentation/bloc/notifications_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  // Core
  getIt.registerSingleton<FlutterSecureStorage>(
    const FlutterSecureStorage(),
  );

  getIt.registerSingleton<SecureStorage>(
    SecureStorage(getIt<FlutterSecureStorage>()),
  );

  getIt.registerSingleton<DioClient>(
    DioClient(getIt<SecureStorage>()),
  );

  // ── Auth ──────────────────────────────────────────────

  // Data sources
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSource(
      dioClient: getIt<DioClient>(),
      storage: getIt<SecureStorage>(),
    ),
  );

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

  // BLoCs
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(getIt<AuthRepository>()),
  );

  // ── Accounts ──────────────────────────────────────────

  // Data sources
  getIt.registerSingleton<AccountsRemoteDataSource>(
    AccountsRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  getIt.registerSingleton<PlaidRemoteDataSource>(
    PlaidRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  // Repositories
  getIt.registerSingleton<AccountsRepository>(
    AccountsRepositoryImpl(getIt<AccountsRemoteDataSource>()),
  );

  // Cubits
  getIt.registerFactory<AccountsCubit>(
    () => AccountsCubit(
      getIt<AccountsRepository>(),
      getIt<PlaidRemoteDataSource>(),
    ),
  );

  // ── Transactions ──────────────────────────────────────

  // Data sources
  getIt.registerSingleton<TransactionsRemoteDataSource>(
    TransactionsRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  // Repositories
  getIt.registerSingleton<TransactionsRepository>(
    TransactionsRepositoryImpl(getIt<TransactionsRemoteDataSource>()),
  );

  // BLoCs
  getIt.registerFactory<TransactionsBloc>(
    () => TransactionsBloc(getIt<TransactionsRepository>()),
  );

  // ── Dashboard ────────────────────────────────────────

  // Data sources
  getIt.registerSingleton<DashboardRemoteDataSource>(
    DashboardRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  // Repositories
  getIt.registerSingleton<DashboardRepository>(
    DashboardRepositoryImpl(getIt<DashboardRemoteDataSource>()),
  );

  // Cubits
  getIt.registerFactory<DashboardCubit>(
    () => DashboardCubit(getIt<DashboardRepository>()),
  );

  // ── Import ────────────────────────────────────────────

  getIt.registerFactory<ImportCubit>(
    () => ImportCubit(getIt<DioClient>()),
  );

  // ── Scheduled Payments ─────────────────────────────────

  // Data sources
  getIt.registerSingleton<ScheduledPaymentsRemoteDataSource>(
    ScheduledPaymentsRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  // Repositories
  getIt.registerSingleton<ScheduledPaymentsRepository>(
    ScheduledPaymentsRepositoryImpl(
        getIt<ScheduledPaymentsRemoteDataSource>()),
  );

  // Cubits
  getIt.registerFactory<ScheduledPaymentsCubit>(
    () => ScheduledPaymentsCubit(getIt<ScheduledPaymentsRepository>()),
  );

  // ── Budgets ──────────────────────────────────────────────

  // Data sources
  getIt.registerSingleton<BudgetsRemoteDataSource>(
    BudgetsRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  // Repositories
  getIt.registerSingleton<BudgetsRepository>(
    BudgetsRepositoryImpl(getIt<BudgetsRemoteDataSource>()),
  );

  // Cubits
  getIt.registerFactory<BudgetsCubit>(
    () => BudgetsCubit(getIt<BudgetsRepository>()),
  );

  // ── Debts ──────────────────────────────────────────────

  // Data sources
  getIt.registerSingleton<DebtsRemoteDataSource>(
    DebtsRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  // Repositories
  getIt.registerSingleton<DebtsRepository>(
    DebtsRepositoryImpl(getIt<DebtsRemoteDataSource>()),
  );

  // Cubits
  getIt.registerFactory<DebtsCubit>(
    () => DebtsCubit(getIt<DebtsRepository>()),
  );

  // ── Oracle ──────────────────────────────────────────────

  // Data sources
  getIt.registerSingleton<OracleRemoteDataSource>(
    OracleRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  // Repositories
  getIt.registerSingleton<OracleRepository>(
    OracleRepositoryImpl(getIt<OracleRemoteDataSource>()),
  );

  // Cubits
  getIt.registerFactory<OracleCubit>(
    () => OracleCubit(getIt<OracleRepository>()),
  );

  // ── Settings ──────────────────────────────────────────────

  // Data sources
  getIt.registerSingleton<SettingsRemoteDataSource>(
    SettingsRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  // Repositories
  getIt.registerSingleton<SettingsRepository>(
    SettingsRepositoryImpl(getIt<SettingsRemoteDataSource>()),
  );

  // Cubits
  getIt.registerFactory<SettingsCubit>(
    () => SettingsCubit(getIt<SettingsRepository>()),
  );

  // ── Notifications ─────────────────────────────────────────

  // Data sources
  getIt.registerSingleton<NotificationsRemoteDataSource>(
    NotificationsRemoteDataSource(dioClient: getIt<DioClient>()),
  );

  // Repositories
  getIt.registerSingleton<NotificationsRepository>(
    NotificationsRepositoryImpl(getIt<NotificationsRemoteDataSource>()),
  );

  // Cubits
  getIt.registerFactory<NotificationsCubit>(
    () => NotificationsCubit(getIt<NotificationsRepository>()),
  );
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/accounts/data/datasources/accounts_remote_datasource.dart';
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

final getIt = GetIt.instance;

Future<void> setupDI() async {
  // Core
  getIt.registerSingleton<FlutterSecureStorage>(
    const FlutterSecureStorage(),
  );

  getIt.registerSingleton<DioClient>(
    DioClient(getIt<FlutterSecureStorage>()),
  );

  // ── Auth ──────────────────────────────────────────────

  // Data sources
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSource(
      dioClient: getIt<DioClient>(),
      storage: getIt<FlutterSecureStorage>(),
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

  // Repositories
  getIt.registerSingleton<AccountsRepository>(
    AccountsRepositoryImpl(getIt<AccountsRemoteDataSource>()),
  );

  // Cubits
  getIt.registerFactory<AccountsCubit>(
    () => AccountsCubit(getIt<AccountsRepository>()),
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
}

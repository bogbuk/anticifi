import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../di/injection.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';
import '../../features/transactions/presentation/pages/transaction_form_page.dart';
import '../../features/transactions/presentation/bloc/transactions_bloc.dart';
import '../../features/transactions/domain/entities/transaction_entity.dart';
import '../../features/dashboard/presentation/bloc/dashboard_cubit.dart';
import '../../features/oracle/presentation/pages/oracle_page.dart';
import '../../features/oracle/presentation/bloc/oracle_cubit.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/edit_profile_page.dart';
import '../../features/settings/presentation/bloc/settings_cubit.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/notifications/presentation/bloc/notifications_cubit.dart';
import '../../features/accounts/presentation/pages/accounts_page.dart';
import '../../features/accounts/presentation/pages/account_form_page.dart';
import '../../features/accounts/presentation/bloc/accounts_cubit.dart';
import '../../features/accounts/domain/entities/account_entity.dart';
import '../../features/import/presentation/pages/import_page.dart';
import '../../features/import/presentation/bloc/import_cubit.dart';
import '../../features/scheduled_payments/presentation/pages/scheduled_payments_page.dart';
import '../../features/scheduled_payments/presentation/pages/scheduled_payment_form_page.dart';
import '../../features/scheduled_payments/presentation/bloc/scheduled_payments_cubit.dart';
import '../../features/scheduled_payments/domain/entities/scheduled_payment_entity.dart';

GoRouter createAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _GoRouterAuthRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isOnAuthPage = state.location.startsWith('/auth');
      final isSplash = state.location == '/';

      if (authState is AuthInitial || authState is AuthLoading) {
        // Still checking auth, stay on splash
        if (isSplash) return null;
        return '/';
      }

      if (authState is AuthUnauthenticated || authState is AuthError) {
        // Not authenticated — redirect to login (unless already on auth page)
        if (isOnAuthPage) return null;
        return '/auth/login';
      }

      if (authState is AuthAuthenticated) {
        // Authenticated — redirect away from auth/splash
        if (isSplash || isOnAuthPage) return '/dashboard';
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => BlocProvider(
          create: (_) => getIt<NotificationsCubit>(),
          child: HomePage(child: child),
        ),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (_) => getIt<DashboardCubit>(),
                child: const DashboardPage(),
              ),
            ),
          ),
          GoRoute(
            path: '/transactions',
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (_) => getIt<TransactionsBloc>(),
                child: const TransactionsPage(),
              ),
            ),
          ),
          GoRoute(
            path: '/oracle',
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (_) => getIt<OracleCubit>(),
                child: const OraclePage(),
              ),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (_) => getIt<SettingsCubit>(),
                child: const SettingsPage(),
              ),
            ),
          ),
        ],
      ),

      // ── Accounts routes ──────────────────────────────
      GoRoute(
        path: '/accounts',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<AccountsCubit>(),
          child: const AccountsPage(),
        ),
      ),
      GoRoute(
        path: '/accounts/add',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<AccountsCubit>(),
          child: const AccountFormPage(),
        ),
      ),
      GoRoute(
        path: '/accounts/:id/edit',
        builder: (context, state) {
          final account = state.extra as AccountEntity?;
          return BlocProvider(
            create: (_) => getIt<AccountsCubit>(),
            child: AccountFormPage(account: account),
          );
        },
      ),

      // ── Transaction form routes ──────────────────────
      GoRoute(
        path: '/transactions/add',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<TransactionsBloc>(),
          child: const TransactionFormPage(),
        ),
      ),
      GoRoute(
        path: '/transactions/:id/edit',
        builder: (context, state) {
          final transaction = state.extra as TransactionEntity?;
          return BlocProvider(
            create: (_) => getIt<TransactionsBloc>(),
            child: TransactionFormPage(transaction: transaction),
          );
        },
      ),

      // ── Import route ─────────────────────────────────
      GoRoute(
        path: '/import',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<ImportCubit>()),
            BlocProvider(create: (_) => getIt<AccountsCubit>()),
          ],
          child: const ImportPage(),
        ),
      ),

      // ── Scheduled Payments routes ──────────────────────
      GoRoute(
        path: '/scheduled-payments',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<ScheduledPaymentsCubit>(),
          child: const ScheduledPaymentsPage(),
        ),
      ),
      GoRoute(
        path: '/scheduled-payments/add',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<ScheduledPaymentsCubit>()),
            BlocProvider(create: (_) => getIt<AccountsCubit>()),
          ],
          child: const ScheduledPaymentFormPage(),
        ),
      ),
      GoRoute(
        path: '/scheduled-payments/:id/edit',
        builder: (context, state) {
          final payment = state.extra as ScheduledPaymentEntity?;
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (_) => getIt<ScheduledPaymentsCubit>()),
              BlocProvider(create: (_) => getIt<AccountsCubit>()),
            ],
            child: ScheduledPaymentFormPage(payment: payment),
          );
        },
      ),

      // ── Notifications route ────────────────────────────
      GoRoute(
        path: '/notifications',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<NotificationsCubit>(),
          child: const NotificationsPage(),
        ),
      ),

      // ── Settings: Edit Profile route ───────────────────
      GoRoute(
        path: '/settings/edit-profile',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<SettingsCubit>()..loadProfile(),
          child: const EditProfilePage(),
        ),
      ),
    ],
  );
}

/// Converts a Stream into a Listenable for GoRouter's refreshListenable.
class _GoRouterAuthRefreshStream extends ChangeNotifier {
  _GoRouterAuthRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

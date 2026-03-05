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
import '../../features/accounts/presentation/pages/link_bank_page.dart';
import '../../features/accounts/presentation/bloc/accounts_cubit.dart';
import '../../features/accounts/domain/entities/account_entity.dart';
import '../../features/import/presentation/pages/import_page.dart';
import '../../features/import/presentation/bloc/import_cubit.dart';
import '../../features/scheduled_payments/presentation/pages/scheduled_payments_page.dart';
import '../../features/scheduled_payments/presentation/pages/scheduled_payment_form_page.dart';
import '../../features/scheduled_payments/presentation/bloc/scheduled_payments_cubit.dart';
import '../../features/scheduled_payments/domain/entities/scheduled_payment_entity.dart';
import '../../features/budgets/presentation/pages/budgets_page.dart';
import '../../features/budgets/presentation/pages/budget_form_page.dart';
import '../../features/budgets/presentation/bloc/budgets_cubit.dart';
import '../../features/budgets/domain/entities/budget_entity.dart';
import '../../features/debts/presentation/pages/debts_page.dart';
import '../../features/debts/presentation/pages/debt_detail_page.dart';
import '../../features/debts/presentation/pages/debt_form_page.dart';
import '../../features/debts/presentation/pages/debt_payment_form_page.dart';
import '../../features/debts/presentation/bloc/debts_cubit.dart';
import '../../features/debts/domain/entities/debt_entity.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/receipts/presentation/pages/receipt_scan_page.dart';
import '../../features/receipts/presentation/bloc/receipt_cubit.dart';
import '../../features/export/presentation/pages/export_page.dart';
import '../../features/export/presentation/bloc/export_cubit.dart';
import '../../features/subscription/presentation/pages/paywall_page.dart';
import '../../features/subscription/presentation/bloc/subscription_cubit.dart';

GoRouter createAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _GoRouterAuthRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isOnAuthPage = state.location.startsWith('/auth');
      final isSplash = state.location == '/';
      final isOnboarding = state.location == '/onboarding';

      if (authState is AuthInitial || authState is AuthLoading) {
        // Still checking auth, stay on splash
        if (isSplash) return null;
        return '/';
      }

      if (authState is AuthLoginSuccessState) {
        // Login success but biometric dialog pending — stay on current page
        return null;
      }

      if (authState is AuthUnauthenticated || authState is AuthError) {
        // Not authenticated — redirect to login (unless already on auth page)
        if (isOnAuthPage) return null;
        return '/auth/login';
      }

      if (authState is AuthAuthenticated) {
        // Check onboarding
        if (!authState.user.onboardingCompleted) {
          if (isOnboarding) return null;
          return '/onboarding';
        }
        // Authenticated — redirect away from auth/splash/onboarding
        if (isSplash || isOnAuthPage || isOnboarding) return '/dashboard';
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
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
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
        path: '/accounts/link-bank',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<AccountsCubit>(),
          child: const LinkBankPage(),
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

      // ── Budgets routes ────────────────────────────────────
      GoRoute(
        path: '/budgets',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<BudgetsCubit>(),
          child: const BudgetsPage(),
        ),
      ),
      GoRoute(
        path: '/budgets/add',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<BudgetsCubit>(),
          child: const BudgetFormPage(),
        ),
      ),
      GoRoute(
        path: '/budgets/:id/edit',
        builder: (context, state) {
          final budget = state.extra as BudgetEntity?;
          return BlocProvider(
            create: (_) => getIt<BudgetsCubit>(),
            child: BudgetFormPage(budget: budget),
          );
        },
      ),

      // ── Debts routes ────────────────────────────────────
      GoRoute(
        path: '/debts',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<DebtsCubit>(),
          child: const DebtsPage(),
        ),
      ),
      GoRoute(
        path: '/debts/add',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<DebtsCubit>(),
          child: const DebtFormPage(),
        ),
      ),
      GoRoute(
        path: '/debts/:id',
        builder: (context, state) {
          final id = state.params['id']!;
          return BlocProvider(
            create: (_) => getIt<DebtsCubit>(),
            child: DebtDetailPage(debtId: id),
          );
        },
      ),
      GoRoute(
        path: '/debts/:id/edit',
        builder: (context, state) {
          final debt = state.extra as DebtEntity?;
          return BlocProvider(
            create: (_) => getIt<DebtsCubit>(),
            child: DebtFormPage(debt: debt),
          );
        },
      ),
      GoRoute(
        path: '/debts/:id/pay',
        builder: (context, state) {
          final debt = state.extra as DebtEntity;
          return BlocProvider(
            create: (_) => getIt<DebtsCubit>(),
            child: DebtPaymentFormPage(debt: debt),
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

      // ── Receipt Scan route ────────────────────────────
      GoRoute(
        path: '/receipts/scan',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<ReceiptCubit>(),
          child: const ReceiptScanPage(),
        ),
      ),

      // ── Export route ──────────────────────────────────
      GoRoute(
        path: '/export',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<ExportCubit>(),
          child: const ExportPage(),
        ),
      ),

      // ── Subscription / Paywall route ─────────────────
      GoRoute(
        path: '/subscription',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<SubscriptionCubit>(),
          child: const PaywallPage(),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'core/di/injection.dart';
import 'core/locale/locale_cubit.dart';
import 'core/locale/locale_state.dart';
import 'core/router/app_router.dart';
import 'core/services/fcm_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/theme/theme_state.dart';
import 'core/widgets/offline_banner.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';

class AnticiFiApp extends StatelessWidget {
  const AnticiFiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
        BlocProvider<ThemeCubit>.value(value: getIt<ThemeCubit>()),
        BlocProvider<LocaleCubit>.value(value: getIt<LocaleCubit>()),
      ],
      child: Builder(
        builder: (context) {
          final authBloc = context.read<AuthBloc>();
          final router = createAppRouter(authBloc);
          getIt<FcmService>().setRouter(router);

          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              final fcmService = getIt<FcmService>();
              if (state is AuthAuthenticated) {
                fcmService.initialize();
              } else if (state is AuthUnauthenticated) {
                fcmService.removeToken();
              }
            },
            child: BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, themeState) {
                return BlocBuilder<LocaleCubit, LocaleState>(
                  builder: (context, localeState) {
                    return MaterialApp.router(
                      title: 'AnticiFi',
                      debugShowCheckedModeBanner: false,
                      theme: AppTheme.lightTheme,
                      darkTheme: AppTheme.darkTheme,
                      themeMode: themeState.themeMode,
                      locale: localeState.locale,
                      supportedLocales: AppLocalizations.supportedLocales,
                      localizationsDelegates: AppLocalizations.localizationsDelegates,
                      routerConfig: router,
                      builder: (context, child) {
                        return OfflineBanner(child: child ?? const SizedBox.shrink());
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

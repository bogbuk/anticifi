import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/services/fcm_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';

class AnticiFiApp extends StatelessWidget {
  const AnticiFiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => getIt<AuthBloc>(),
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
            child: MaterialApp.router(
              title: 'AnticiFi',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.darkTheme,
              routerConfig: router,
            ),
          );
        },
      ),
    );
  }
}

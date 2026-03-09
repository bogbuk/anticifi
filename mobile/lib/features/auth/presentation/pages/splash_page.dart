import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../domain/repositories/auth_repository.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final biometricService = getIt<BiometricService>();
    final authRepository = getIt<AuthRepository>();

    final hasToken = await authRepository.isAuthenticated();
    final biometricEnabled = await biometricService.isBiometricEnabled();

    if (!mounted) return;

    if (hasToken && biometricEnabled) {
      context.read<AuthBloc>().add(const AuthBiometricRequested());
    } else {
      context.read<AuthBloc>().add(const AuthCheckRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: const AppLogo(size: 90),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/gradient_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoginSuccessState) {
          _showBiometricDialog(context, state.user);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  // Logo
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ).createShader(bounds),
                    child: const Text(
                      'AnticiFi',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Title
                  Text(
                    l10n.createAccount,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.signUpToGetStarted,
                    style: TextStyle(
                      fontSize: 16,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Name field
                  AuthTextField(
                    controller: _nameController,
                    label: l10n.fullName,
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  // Email field
                  AuthTextField(
                    controller: _emailController,
                    label: l10n.email,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  // Password field
                  AuthTextField(
                    controller: _passwordController,
                    label: l10n.password,
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  // Confirm Password field
                  AuthTextField(
                    controller: _confirmPasswordController,
                    label: l10n.confirmPassword,
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 24),
                  // Create Account button
                  GradientButton(
                    text: l10n.signUp,
                    isLoading: isLoading,
                    onPressed: () {
                      if (_passwordController.text !=
                          _confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.passwordsDoNotMatch),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }
                      context.read<AuthBloc>().add(
                            AuthRegisterRequested(
                              name: _nameController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            ),
                          );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Login link
                  TextButton(
                    onPressed: () => context.go('/auth/login'),
                    child: RichText(
                      text: TextSpan(
                        text: '${l10n.alreadyHaveAccount} ',
                        style: TextStyle(color: context.appColors.textSecondary),
                        children: [
                          TextSpan(
                            text: l10n.signIn,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showBiometricDialog(
      BuildContext context, dynamic user) async {
    final l10n = AppLocalizations.of(context)!;
    final authBloc = context.read<AuthBloc>();
    final biometricService = authBloc.biometricService;

    final isSupported = await biometricService.isDeviceSupported();
    final alreadyEnabled = await biometricService.isBiometricEnabled();

    if (!mounted) return;

    if (isSupported && !alreadyEnabled) {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            l10n.enableBiometricTitle,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          content: Text(
            l10n.enableBiometricContent,
            style: TextStyle(color: context.appColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                l10n.notNow,
                style: TextStyle(color: context.appColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                l10n.enable,
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );

      if (result == true) {
        await biometricService.setBiometricEnabled(true);
      }
    }

    if (!mounted) return;
    authBloc.add(AuthConfirmLogin(user));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../../../core/widgets/app_logo.dart';
import '../widgets/onboarding_step.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  List<OnboardingStep> _buildSteps(AppLocalizations l10n) => [
    OnboardingStep(
      icon: Icons.auto_awesome,
      customIcon: const AppLogo(size: 100, showText: true),
      title: l10n.onboardingTitle1,
      description: l10n.onboardingDesc1,
    ),
    OnboardingStep(
      icon: Icons.insights,
      title: l10n.onboardingTitle2,
      description: l10n.onboardingDesc2,
    ),
    OnboardingStep(
      icon: Icons.track_changes,
      title: l10n.onboardingTitle3,
      description: l10n.onboardingDesc3,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);
    try {
      final settingsRepo = getIt<SettingsRepository>();
      await settingsRepo.updateProfile({'onboardingCompleted': true});
    } catch (_) {}

    if (mounted) {
      final authBloc = context.read<AuthBloc>();
      final currentState = authBloc.state;
      if (currentState is AuthAuthenticated) {
        final updatedUser = UserEntity(
          id: currentState.user.id,
          name: currentState.user.name,
          email: currentState.user.email,
          onboardingCompleted: true,
        );
        authBloc.add(AuthConfirmLogin(updatedUser));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final steps = _buildSteps(l10n);
    final isLastPage = _currentPage == steps.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    l10n.skip,
                    style: TextStyle(
                      color: context.appColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: steps.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) => steps[index],
              ),
            ),

            // Dots indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  steps.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentPage == index
                          ? AppColors.primary
                          : context.appColors.textMuted.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),

            // Next / Get Started button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: GradientButton(
                text: isLastPage ? l10n.getStarted : l10n.next,
                isLoading: _isLoading,
                onPressed: () {
                  if (isLastPage) {
                    _completeOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

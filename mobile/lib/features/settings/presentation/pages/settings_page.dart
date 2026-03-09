import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/locale/locale_cubit.dart';
import '../../../../core/locale/locale_state.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/theme/theme_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../subscription/presentation/bloc/subscription_cubit.dart';
import '../../../subscription/presentation/bloc/subscription_state.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _biometricSupported = false;
  bool _biometricEnabled = false;

  late final SubscriptionCubit _subscriptionCubit;

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().loadProfile();
    _subscriptionCubit = getIt<SubscriptionCubit>()..loadSubscription();
    _loadBiometricState();
  }

  @override
  void dispose() {
    _subscriptionCubit.close();
    super.dispose();
  }

  Future<void> _loadBiometricState() async {
    final biometricService = getIt<BiometricService>();
    final supported = await biometricService.isDeviceSupported();
    final enabled = await biometricService.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _biometricSupported = supported;
        _biometricEnabled = enabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state is SettingsAccountDeleted) {
            context.read<AuthBloc>().add(const AuthLogoutRequested());
          }
          if (state is SettingsUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.profileUpdated),
                backgroundColor: AppColors.success,
              ),
            );
          }
          if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          final profile = state is SettingsLoaded
              ? state.profile
              : state is SettingsUpdated
                  ? state.profile
                  : state is SettingsUpdating
                      ? state.profile
                      : null;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              if (profile != null)
                _buildUserHeader(profile)
                    .animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              _buildSectionHeader(l10n.subscription)
                  .animate().fadeIn(duration: 400.ms, delay: 100.ms),
              BlocBuilder<SubscriptionCubit, SubscriptionState>(
                bloc: _subscriptionCubit,
                builder: (context, subState) {
                  final isPremium = subState is SubscriptionLoaded &&
                      subState.subscription.isPremium;
                  return _buildListTile(
                    icon: Icons.workspace_premium,
                    title: isPremium
                        ? l10n.manageSubscription
                        : l10n.upgradeToPremium,
                    iconColor: isPremium ? AppColors.accent : null,
                    trailing: isPremium
                        ? Text(
                            l10n.active,
                            style: const TextStyle(
                              color: AppColors.success,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : null,
                    onTap: () => context.push('/subscription'),
                  );
                },
              ),
              _buildDivider(),

              _buildSectionHeader(l10n.account)
                  .animate().fadeIn(duration: 400.ms, delay: 150.ms),
              _buildListTile(
                icon: Icons.person_outline,
                title: l10n.editProfile,
                onTap: () => context.push('/settings/edit-profile'),
              ),
              _buildListTile(
                icon: Icons.account_balance_wallet_outlined,
                title: l10n.manageAccounts,
                onTap: () => context.push('/accounts'),
              ),
              _buildDivider(),

              _buildSectionHeader(l10n.preferences)
                  .animate().fadeIn(duration: 400.ms, delay: 200.ms),
              _buildListTile(
                icon: Icons.attach_money,
                title: l10n.currency,
                trailing: Text(
                  profile?.currency ?? 'USD',
                  style: TextStyle(
                    color: context.appColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                onTap: () => _showCurrencyPicker(context),
              ),
              BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, themeState) {
                  return _buildListTile(
                    icon: Icons.dark_mode_outlined,
                    title: l10n.theme,
                    trailing: Text(
                      _themeModeLabel(themeState.themeMode),
                      style: TextStyle(
                        color: context.appColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () => _showThemePicker(context),
                  );
                },
              ),
              if (_biometricSupported)
                _buildSwitchTile(
                  icon: Icons.fingerprint,
                  title: l10n.biometricLogin,
                  value: _biometricEnabled,
                  onChanged: (value) async {
                    final biometricService = getIt<BiometricService>();
                    if (value) {
                      final authenticated =
                          await biometricService.authenticate();
                      if (authenticated) {
                        await biometricService.setBiometricEnabled(true);
                        if (mounted) {
                          setState(() => _biometricEnabled = true);
                        }
                      }
                    } else {
                      await biometricService.setBiometricEnabled(false);
                      if (mounted) {
                        setState(() => _biometricEnabled = false);
                      }
                    }
                  },
                ),
              BlocBuilder<LocaleCubit, LocaleState>(
                builder: (context, localeState) {
                  return _buildListTile(
                    icon: Icons.language,
                    title: l10n.language,
                    trailing: Text(
                      _localeLabel(localeState.locale.languageCode),
                      style: TextStyle(
                        color: context.appColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () => _showLanguagePicker(context),
                  );
                },
              ),
              _buildDivider(),

              _buildSectionHeader(l10n.notifications)
                  .animate().fadeIn(duration: 400.ms, delay: 300.ms),
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: l10n.pushNotifications,
                value: profile?.notificationsEnabled ?? true,
                onChanged: (value) {
                  context.read<SettingsCubit>().updateProfile({
                    'notificationsEnabled': value,
                  });
                },
              ),
              _buildDivider(),

              _buildSectionHeader(l10n.data)
                  .animate().fadeIn(duration: 400.ms, delay: 400.ms),
              _buildListTile(
                icon: Icons.receipt_long,
                title: l10n.scanReceipt,
                onTap: () => context.push('/receipts/scan'),
              ),
              _buildListTile(
                icon: Icons.history,
                title: 'Receipt History',
                onTap: () => context.push('/receipts/history'),
              ),
              _buildListTile(
                icon: Icons.upload_file,
                title: l10n.importTransactions,
                onTap: () => context.push('/import'),
              ),
              _buildListTile(
                icon: Icons.download,
                title: l10n.exportData,
                onTap: () => context.push('/export'),
              ),
              _buildListTile(
                icon: Icons.schedule,
                title: l10n.scheduledPayments,
                onTap: () => context.push('/scheduled-payments'),
              ),
              _buildListTile(
                icon: Icons.account_balance_wallet_outlined,
                title: l10n.budgets,
                onTap: () => context.push('/budgets'),
              ),
              _buildListTile(
                icon: Icons.money_off,
                title: l10n.debts,
                onTap: () => context.push('/debts'),
              ),
              _buildDivider(),

              _buildSectionHeader(l10n.about)
                  .animate().fadeIn(duration: 400.ms, delay: 500.ms),
              _buildListTile(
                icon: Icons.info_outline,
                title: l10n.appVersion,
                trailing: Text(
                  '1.0.0',
                  style: TextStyle(
                    color: context.appColors.textMuted,
                    fontSize: 14,
                  ),
                ),
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.privacy_tip_outlined,
                title: l10n.privacyPolicy,
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.description_outlined,
                title: l10n.termsOfService,
                onTap: () {},
              ),
              _buildDivider(),

              _buildSectionHeader(l10n.dangerZone)
                  .animate().fadeIn(duration: 400.ms, delay: 600.ms),
              _buildListTile(
                icon: Icons.delete_forever,
                title: l10n.deleteAccount,
                iconColor: AppColors.error,
                titleColor: AppColors.error,
                onTap: () => _showDeleteConfirmation(context),
              ),
              _buildListTile(
                icon: Icons.logout,
                title: l10n.logout,
                iconColor: AppColors.error,
                titleColor: AppColors.error,
                onTap: () => _showLogoutConfirmation(context),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserHeader(dynamic profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.appColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(
              child: Text(
                profile.fullName.isNotEmpty
                    ? profile.fullName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email as String,
                  style: TextStyle(
                    color: context.appColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<SubscriptionCubit, SubscriptionState>(
            bloc: _subscriptionCubit,
            builder: (context, subState) {
              final isPremium = subState is SubscriptionLoaded &&
                  subState.subscription.isPremium;
              return GestureDetector(
                onTap: () => context.push('/subscription'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: isPremium
                        ? const LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                          )
                        : null,
                    color: isPremium
                        ? null
                        : AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isPremium ? AppLocalizations.of(context)!.premium : AppLocalizations.of(context)!.free,
                    style: TextStyle(
                      color: isPremium ? Colors.white : AppColors.primaryLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          color: context.appColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? context.appColors.textSecondary,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? Theme.of(context).colorScheme.onSurface,
          fontSize: 15,
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: context.appColors.textMuted,
            size: 20,
          ),
      onTap: onTap,
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: context.appColors.textSecondary,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 15,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Divider(color: context.appColors.border, height: 1),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case ThemeMode.dark:
        return l10n.dark;
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.system:
        return l10n.system;
    }
  }

  String _localeLabel(String locale) {
    final l10n = AppLocalizations.of(context)!;
    switch (locale) {
      case 'ru':
        return l10n.russian;
      case 'ro':
        return l10n.romanian;
      case 'es':
        return l10n.spanish;
      case 'fr':
        return l10n.french;
      case 'de':
        return l10n.german;
      case 'uk':
        return l10n.ukrainian;
      case 'pt':
        return l10n.portuguese;
      case 'it':
        return l10n.italian;
      case 'tr':
        return l10n.turkish;
      case 'zh':
        return l10n.chinese;
      case 'ja':
        return l10n.japanese;
      default:
        return l10n.english;
    }
  }

  void _showCurrencyPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const currencies = ['USD', 'EUR', 'GBP', 'MDL', 'RON'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.selectCurrency,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...currencies.map(
              (c) => ListTile(
                title: Text(
                  c,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.read<SettingsCubit>().updateProfile({'currency': c});
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themes = {
      ThemeMode.system: l10n.system,
      ThemeMode.dark: l10n.dark,
      ThemeMode.light: l10n.light,
    };
    final currentMode = context.read<ThemeCubit>().state.themeMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.selectTheme,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...themes.entries.map(
              (e) => ListTile(
                title: Text(
                  e.value,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
                trailing: currentMode == e.key
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  context.read<ThemeCubit>().setThemeMode(e.key);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languages = {
      const Locale('en'): l10n.english,
      const Locale('ru'): l10n.russian,
      const Locale('ro'): l10n.romanian,
      const Locale('es'): l10n.spanish,
      const Locale('fr'): l10n.french,
      const Locale('de'): l10n.german,
      const Locale('uk'): l10n.ukrainian,
      const Locale('pt'): l10n.portuguese,
      const Locale('it'): l10n.italian,
      const Locale('tr'): l10n.turkish,
      const Locale('zh'): l10n.chinese,
      const Locale('ja'): l10n.japanese,
    };
    final currentLocale = context.read<LocaleCubit>().state.locale;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.selectLanguage,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: languages.entries.map(
                  (e) => ListTile(
                    title: Text(
                      e.value,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),
                    trailing: currentLocale.languageCode == e.key.languageCode
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      context.read<LocaleCubit>().setLocale(e.key);
                    },
                  ),
                ).toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          l10n.deleteAccount,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          l10n.deleteAccountConfirm,
          style: TextStyle(color: context.appColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: context.appColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SettingsCubit>().deleteAccount();
            },
            child: Text(
              l10n.delete,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          l10n.logout,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          l10n.logoutConfirm,
          style: TextStyle(color: context.appColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: context.appColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: Text(
              l10n.logout,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

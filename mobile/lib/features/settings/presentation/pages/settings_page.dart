import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().loadProfile();
    _loadBiometricState();
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state is SettingsAccountDeleted) {
            context.read<AuthBloc>().add(const AuthLogoutRequested());
          }
          if (state is SettingsUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated'),
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
              // User info header
              if (profile != null) _buildUserHeader(profile),

              const SizedBox(height: 24),

              // Account section
              _buildSectionHeader('Account'),
              _buildListTile(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () => context.push('/settings/edit-profile'),
              ),
              _buildListTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Manage Accounts',
                onTap: () => context.push('/accounts'),
              ),
              _buildDivider(),

              // Preferences section
              _buildSectionHeader('Preferences'),
              _buildListTile(
                icon: Icons.attach_money,
                title: 'Currency',
                trailing: Text(
                  profile?.currency ?? 'USD',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                onTap: () => _showCurrencyPicker(context),
              ),
              _buildListTile(
                icon: Icons.dark_mode_outlined,
                title: 'Theme',
                trailing: Text(
                  _themeLabel(profile?.theme ?? 'system'),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                onTap: () => _showThemePicker(context),
              ),
              if (_biometricSupported)
                _buildSwitchTile(
                  icon: Icons.fingerprint,
                  title: 'Biometric Login',
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
              _buildListTile(
                icon: Icons.language,
                title: 'Language',
                trailing: Text(
                  _localeLabel(profile?.locale ?? 'en'),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                onTap: () {},
              ),
              _buildDivider(),

              // Notifications section
              _buildSectionHeader('Notifications'),
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                value: profile?.notificationsEnabled ?? true,
                onChanged: (value) {
                  context.read<SettingsCubit>().updateProfile({
                    'notificationsEnabled': value,
                  });
                },
              ),
              _buildDivider(),

              // Data section
              _buildSectionHeader('Data'),
              _buildListTile(
                icon: Icons.upload_file,
                title: 'Import Transactions',
                onTap: () => context.push('/import'),
              ),
              _buildListTile(
                icon: Icons.schedule,
                title: 'Scheduled Payments',
                onTap: () => context.push('/scheduled-payments'),
              ),
              _buildListTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Budgets',
                onTap: () => context.push('/budgets'),
              ),
              _buildListTile(
                icon: Icons.money_off,
                title: 'Debts',
                onTap: () => context.push('/debts'),
              ),
              _buildDivider(),

              // About section
              _buildSectionHeader('About'),
              _buildListTile(
                icon: Icons.info_outline,
                title: 'App Version',
                trailing: const Text(
                  '1.0.0',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () {},
              ),
              _buildDivider(),

              // Danger zone
              _buildSectionHeader('Danger Zone'),
              _buildListTile(
                icon: Icons.delete_forever,
                title: 'Delete Account',
                iconColor: AppColors.error,
                titleColor: AppColors.error,
                onTap: () => _showDeleteConfirmation(context),
              ),
              _buildListTile(
                icon: Icons.logout,
                title: 'Logout',
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
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email as String,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'FREE',
              style: TextStyle(
                color: AppColors.primaryLight,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
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
        style: const TextStyle(
          color: AppColors.textMuted,
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
        color: iconColor ?? AppColors.textSecondary,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppColors.textPrimary,
          fontSize: 15,
        ),
      ),
      trailing: trailing ??
          const Icon(
            Icons.chevron_right,
            color: AppColors.textMuted,
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
        color: AppColors.textSecondary,
        size: 22,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
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
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Divider(color: AppColors.border, height: 1),
    );
  }

  String _themeLabel(String theme) {
    switch (theme) {
      case 'dark':
        return 'Dark';
      case 'light':
        return 'Light';
      default:
        return 'System';
    }
  }

  String _localeLabel(String locale) {
    switch (locale) {
      case 'ro':
        return 'Romanian';
      case 'ru':
        return 'Russian';
      default:
        return 'English';
    }
  }

  void _showCurrencyPicker(BuildContext context) {
    const currencies = ['USD', 'EUR', 'GBP', 'MDL', 'RON'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Currency',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...currencies.map(
              (c) => ListTile(
                title: Text(
                  c,
                  style: const TextStyle(color: AppColors.textPrimary),
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
    const themes = {'system': 'System', 'dark': 'Dark', 'light': 'Light'};
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Theme',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...themes.entries.map(
              (e) => ListTile(
                title: Text(
                  e.value,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<SettingsCubit>()
                      .updateProfile({'theme': e.key});
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Delete Account',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently removed.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SettingsCubit>().deleteAccount();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Logout',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

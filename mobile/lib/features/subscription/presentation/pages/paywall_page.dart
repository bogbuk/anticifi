import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/subscription_cubit.dart';
import '../bloc/subscription_state.dart';

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionCubit>().loadSubscription();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.unlockFullPower),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionLoaded && state.subscription.isPremium) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.welcomeToPremium),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop(true);
          }
          if (state is SubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SubscriptionLoading || state is SubscriptionPurchasing) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  if (state is SubscriptionPurchasing) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.processingPurchase,
                      style: TextStyle(color: context.appColors.textSecondary),
                    ),
                  ],
                ],
              ),
            );
          }

          final packages = state is SubscriptionLoaded ? state.packages : <Package>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildHeroSection()
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: 32),
                _buildFeaturesList()
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms),
                const SizedBox(height: 32),
                _buildPricingCards(packages)
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 400.ms),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    context.read<SubscriptionCubit>().restorePurchases();
                  },
                  child: Text(
                    l10n.restorePurchases,
                    style: TextStyle(color: context.appColors.textMuted, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroSection() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.workspace_premium,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.unlockFullPower,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.unlockSubtitle,
          style: TextStyle(
            color: context.appColors.textSecondary,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesList() {
    final l10n = AppLocalizations.of(context)!;
    final features = <Map<String, dynamic>>[
      {'title': l10n.featureUnlimitedAccounts, 'icon': Icons.account_balance},
      {'title': l10n.featureBankSync, 'icon': Icons.sync},
      {'title': l10n.featureReceiptScanning, 'icon': Icons.receipt_long},
      {'title': l10n.featureAiPredictions, 'icon': Icons.auto_awesome},
      {'title': l10n.featureSmartCategorization, 'icon': Icons.category},
      {'title': l10n.featureBudgetsDebts, 'icon': Icons.pie_chart},
      {'title': l10n.featureExport, 'icon': Icons.download},
      {'title': l10n.featureMultiCurrency, 'icon': Icons.currency_exchange},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.appColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.premiumIncludes,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(f['icon'] as IconData, color: AppColors.primaryLight, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    f['title'] as String,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCards(List<Package> packages) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildPriceCard(
          title: l10n.yearlyPrice,
          price: '\$34.99/year',
          subtitle: l10n.yearlySaving,
          isPopular: true,
          onTap: () {
            final pkg = _findPackage(packages, PackageType.annual);
            if (pkg != null) {
              context.read<SubscriptionCubit>().purchasePackage(pkg.identifier);
            }
          },
        ),
        const SizedBox(height: 12),
        _buildPriceCard(
          title: l10n.monthlyPrice,
          price: '\$4.99/month',
          subtitle: l10n.cancelAnytime,
          isPopular: false,
          onTap: () {
            final pkg = _findPackage(packages, PackageType.monthly);
            if (pkg != null) {
              context.read<SubscriptionCubit>().purchasePackage(pkg.identifier);
            }
          },
        ),
        const SizedBox(height: 12),
        _buildPriceCard(
          title: l10n.lifetimePrice,
          price: '\$99.99',
          subtitle: l10n.lifetimeSubtitle,
          isPopular: false,
          onTap: () {
            final pkg = _findPackage(packages, PackageType.lifetime);
            if (pkg != null) {
              context.read<SubscriptionCubit>().purchasePackage(pkg.identifier);
            }
          },
        ),
      ],
    );
  }

  Package? _findPackage(List<Package> packages, PackageType type) {
    try {
      return packages.firstWhere((p) => p.packageType == type);
    } catch (_) {
      return packages.isNotEmpty ? packages.first : null;
    }
  }

  Widget _buildPriceCard({
    required String title,
    required String price,
    required String subtitle,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isPopular
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isPopular ? null : context.appColors.card,
          borderRadius: BorderRadius.circular(16),
          border: isPopular ? null : Border.all(color: context.appColors.border),
        ),
        child: Column(
          children: [
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppLocalizations.of(context)!.bestValue,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            Text(
              title,
              style: TextStyle(
                color: isPopular ? Colors.white70 : context.appColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: TextStyle(
                color: isPopular ? Colors.white : Theme.of(context).colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isPopular ? Colors.white60 : context.appColors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:purchases_flutter/purchases_flutter.dart';

import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/revenuecat_datasource.dart';
import '../datasources/subscription_remote_datasource.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final RevenueCatDataSource _revenueCatDataSource;
  final SubscriptionRemoteDataSource _remoteDataSource;

  SubscriptionRepositoryImpl(
    this._revenueCatDataSource,
    this._remoteDataSource,
  );

  @override
  Future<SubscriptionEntity> getSubscriptionStatus() async {
    return await _remoteDataSource.getSubscriptionStatus();
  }

  @override
  Future<void> purchasePackage(String packageId) async {
    final packages = await _revenueCatDataSource.getOfferings();
    final package = packages.firstWhere(
      (p) => p.identifier == packageId,
      orElse: () => throw Exception('Package not found: $packageId'),
    );

    final customerInfo = await _revenueCatDataSource.purchasePackage(package);
    await _syncToBackend(customerInfo);
  }

  @override
  Future<void> restorePurchases() async {
    final customerInfo = await _revenueCatDataSource.restorePurchases();
    await _syncToBackend(customerInfo);
  }

  @override
  Future<void> syncSubscription() async {
    final customerInfo = await _revenueCatDataSource.getCustomerInfo();
    await _syncToBackend(customerInfo);
  }

  Future<void> _syncToBackend(CustomerInfo customerInfo) async {
    final isPremium =
        customerInfo.entitlements.all['premium']?.isActive ?? false;
    final expiresAt =
        customerInfo.entitlements.all['premium']?.expirationDate;
    final productId =
        customerInfo.entitlements.all['premium']?.productIdentifier;
    final rcUserId = await _revenueCatDataSource.getAppUserId();

    await _remoteDataSource.syncSubscription(
      revenuecatId: rcUserId ?? '',
      isPremium: isPremium,
      expiresAt: expiresAt,
      productId: productId,
    );
  }
}

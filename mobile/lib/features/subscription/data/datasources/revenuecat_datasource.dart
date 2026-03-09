import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatDataSource {
  static const _apiKeyIos = String.fromEnvironment('REVENUECAT_IOS_KEY');
  static const _apiKeyAndroid = String.fromEnvironment('REVENUECAT_ANDROID_KEY');
  static const _entitlementId = 'AnticiFi Pro';

  bool _isConfigured = false;

  Future<void> initialize(String userId) async {
    final apiKey = Platform.isIOS ? _apiKeyIos : _apiKeyAndroid;
    if (apiKey.isEmpty) {
      return;
    }

    final configuration = PurchasesConfiguration(apiKey)..appUserID = userId;
    await Purchases.configure(configuration);
    _isConfigured = true;
  }

  Future<bool> isPremium() async {
    if (!_isConfigured) return false;
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<List<Package>> getOfferings() async {
    if (!_isConfigured) return [];
    final offerings = await Purchases.getOfferings();
    return offerings.current?.availablePackages ?? [];
  }

  Future<CustomerInfo> purchasePackage(Package package) async {
    if (!_isConfigured) throw Exception('RevenueCat not configured');
    return await Purchases.purchasePackage(package);
  }

  Future<CustomerInfo> restorePurchases() async {
    if (!_isConfigured) throw Exception('RevenueCat not configured');
    return await Purchases.restorePurchases();
  }

  Future<CustomerInfo> getCustomerInfo() async {
    if (!_isConfigured) throw Exception('RevenueCat not configured');
    return await Purchases.getCustomerInfo();
  }

  Future<String?> getAppUserId() async {
    if (!_isConfigured) return null;
    return await Purchases.appUserID;
  }
}

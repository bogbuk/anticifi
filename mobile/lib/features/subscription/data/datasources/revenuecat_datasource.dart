import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatDataSource {
  static const _apiKeyIos = String.fromEnvironment('REVENUECAT_IOS_KEY');
  static const _apiKeyAndroid = String.fromEnvironment('REVENUECAT_ANDROID_KEY');
  static const _entitlementId = 'AnticiFi Pro';

  Future<void> initialize(String userId) async {
    final apiKey = Platform.isIOS ? _apiKeyIos : _apiKeyAndroid;

    final configuration = PurchasesConfiguration(apiKey)..appUserID = userId;
    await Purchases.configure(configuration);
  }

  Future<bool> isPremium() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[_entitlementId]?.isActive ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<List<Package>> getOfferings() async {
    final offerings = await Purchases.getOfferings();
    return offerings.current?.availablePackages ?? [];
  }

  Future<CustomerInfo> purchasePackage(Package package) async {
    return await Purchases.purchasePackage(package);
  }

  Future<CustomerInfo> restorePurchases() async {
    return await Purchases.restorePurchases();
  }

  Future<CustomerInfo> getCustomerInfo() async {
    return await Purchases.getCustomerInfo();
  }

  Future<String?> getAppUserId() async {
    return await Purchases.appUserID;
  }
}

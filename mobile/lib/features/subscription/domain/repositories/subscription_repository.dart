import '../entities/subscription_entity.dart';

abstract class SubscriptionRepository {
  Future<SubscriptionEntity> getSubscriptionStatus();
  Future<void> purchasePackage(String packageId);
  Future<void> restorePurchases();
  Future<void> syncSubscription();
}

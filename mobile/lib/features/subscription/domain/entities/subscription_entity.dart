import 'package:equatable/equatable.dart';

enum SubscriptionTier { free, premium }

class SubscriptionEntity extends Equatable {
  final SubscriptionTier tier;
  final bool isPremium;
  final String? expiresAt;
  final String? period;
  final List<String> entitlements;

  const SubscriptionEntity({
    required this.tier,
    required this.isPremium,
    this.expiresAt,
    this.period,
    this.entitlements = const [],
  });

  bool get isLifetime => isPremium && period == 'lifetime';

  bool hasEntitlement(String entitlement) => entitlements.contains(entitlement);

  @override
  List<Object?> get props => [tier, isPremium, expiresAt, period, entitlements];
}

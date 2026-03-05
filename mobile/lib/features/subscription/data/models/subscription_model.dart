import '../../domain/entities/subscription_entity.dart';

class SubscriptionModel extends SubscriptionEntity {
  const SubscriptionModel({
    required super.tier,
    required super.isPremium,
    super.expiresAt,
    super.period,
    super.entitlements,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final tierStr = json['tier'] as String? ?? 'free';
    return SubscriptionModel(
      tier: tierStr == 'premium' ? SubscriptionTier.premium : SubscriptionTier.free,
      isPremium: json['isPremium'] as bool? ?? false,
      expiresAt: json['expiresAt'] as String?,
      period: json['period'] as String?,
      entitlements: (json['entitlements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

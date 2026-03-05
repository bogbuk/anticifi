import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/subscription_model.dart';

class SubscriptionRemoteDataSource {
  final DioClient _dioClient;

  SubscriptionRemoteDataSource({required DioClient dioClient})
      : _dioClient = dioClient;

  Future<SubscriptionModel> getSubscriptionStatus() async {
    final response = await _dioClient.dio.get(ApiEndpoints.subscriptionStatus);
    return SubscriptionModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> syncSubscription({
    required String revenuecatId,
    required bool isPremium,
    String? expiresAt,
    String? productId,
  }) async {
    await _dioClient.dio.post(ApiEndpoints.subscriptionSync, data: {
      'revenuecatId': revenuecatId,
      'isPremium': isPremium,
      if (expiresAt != null) 'expiresAt': expiresAt,
      if (productId != null) 'productId': productId,
    });
  }
}

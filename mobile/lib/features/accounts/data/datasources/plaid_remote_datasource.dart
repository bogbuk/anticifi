import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

class PlaidRemoteDataSource {
  final DioClient dioClient;

  PlaidRemoteDataSource({required this.dioClient});

  Future<String> createLinkToken() async {
    final response = await dioClient.dio.post(ApiEndpoints.plaidLinkToken);
    final data = response.data as Map<String, dynamic>;
    return data['linkToken'] as String;
  }

  Future<Map<String, dynamic>> exchangePublicToken({
    required String publicToken,
    String? institutionId,
    String? institutionName,
  }) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.plaidExchangeToken,
      data: {
        'publicToken': publicToken,
        if (institutionId != null) 'institutionId': institutionId,
        if (institutionName != null) 'institutionName': institutionName,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getPlaidItems() async {
    final response = await dioClient.dio.get(ApiEndpoints.plaidItems);
    final list = response.data as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> removePlaidItem(String id) async {
    await dioClient.dio.delete('${ApiEndpoints.plaidItems}/$id');
  }

  Future<Map<String, dynamic>> syncItem(String id) async {
    final response = await dioClient.dio.post('${ApiEndpoints.plaidSync}/$id');
    return response.data as Map<String, dynamic>;
  }
}

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../models/transaction_model.dart';

class TransactionsRemoteDataSource {
  final DioClient dioClient;

  TransactionsRemoteDataSource({required this.dioClient});

  Future<TransactionsResponse> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (type != null) queryParams['type'] = type;
    if (dateFrom != null) queryParams['dateFrom'] = dateFrom.toIso8601String();
    if (dateTo != null) queryParams['dateTo'] = dateTo.toIso8601String();

    final response = await dioClient.dio.get(
      ApiEndpoints.transactions,
      queryParameters: queryParams,
    );

    final data = response.data as Map<String, dynamic>;
    final list = (data['data'] as List<dynamic>?) ?? [];
    final total = data['total'] as int? ?? 0;
    final totalPages = data['totalPages'] as int? ?? 1;

    return TransactionsResponse(
      transactions: list
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: total,
      hasMore: page < totalPages,
    );
  }

  Future<TransactionModel> getTransaction(String id) async {
    final response =
        await dioClient.dio.get('${ApiEndpoints.transactions}/$id');
    final data = response.data as Map<String, dynamic>;
    return TransactionModel.fromJson(data);
  }

  Future<TransactionModel> createTransaction(
      Map<String, dynamic> params) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.transactions,
      data: params,
    );
    final data = response.data as Map<String, dynamic>;
    return TransactionModel.fromJson(data);
  }

  Future<TransactionModel> updateTransaction(
      String id, Map<String, dynamic> params) async {
    final response = await dioClient.dio.patch(
      '${ApiEndpoints.transactions}/$id',
      data: params,
    );
    final data = response.data as Map<String, dynamic>;
    return TransactionModel.fromJson(data);
  }

  Future<void> deleteTransaction(String id) async {
    await dioClient.dio.delete('${ApiEndpoints.transactions}/$id');
  }

  Future<List<Map<String, dynamic>>> suggestCategory({
    required String description,
    String? type,
    double? amount,
  }) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.transactionsCategorize,
      data: {
        'description': description,
        if (type != null) 'type': type,
        if (amount != null) 'amount': amount,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final suggestions = data['suggestions'] as List<dynamic>? ?? [];
    return suggestions
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }
}

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/debt_model.dart';
import '../models/debt_payment_model.dart';
import '../models/debt_summary_model.dart';

class DebtsRemoteDataSource {
  final DioClient dioClient;

  DebtsRemoteDataSource({required this.dioClient});

  Future<List<DebtModel>> getDebts({bool? isActive, bool? isPaidOff}) async {
    final queryParams = <String, dynamic>{};
    if (isActive != null) queryParams['isActive'] = isActive.toString();
    if (isPaidOff != null) queryParams['isPaidOff'] = isPaidOff.toString();

    final response = await dioClient.dio.get(
      ApiEndpoints.debts,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final data = response.data as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list.map((e) => DebtModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<DebtModel> getDebt(String id) async {
    final response = await dioClient.dio.get('${ApiEndpoints.debts}/$id');
    final data = response.data as Map<String, dynamic>;
    return DebtModel.fromJson(data);
  }

  Future<DebtModel> createDebt(Map<String, dynamic> params) async {
    final response = await dioClient.dio.post(ApiEndpoints.debts, data: params);
    final data = response.data as Map<String, dynamic>;
    return DebtModel.fromJson(data);
  }

  Future<DebtModel> updateDebt(String id, Map<String, dynamic> params) async {
    final response = await dioClient.dio.patch('${ApiEndpoints.debts}/$id', data: params);
    final data = response.data as Map<String, dynamic>;
    return DebtModel.fromJson(data);
  }

  Future<void> deleteDebt(String id) async {
    await dioClient.dio.delete('${ApiEndpoints.debts}/$id');
  }

  Future<DebtPaymentModel> recordPayment(String debtId, Map<String, dynamic> params) async {
    final response = await dioClient.dio.post(
      '${ApiEndpoints.debts}/$debtId/payments',
      data: params,
    );
    final data = response.data as Map<String, dynamic>;
    return DebtPaymentModel.fromJson(data);
  }

  Future<List<DebtPaymentModel>> getPayments(String debtId) async {
    final response = await dioClient.dio.get('${ApiEndpoints.debts}/$debtId/payments');
    final data = response.data as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list.map((e) => DebtPaymentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<DebtSummaryModel> getSummary() async {
    final response = await dioClient.dio.get(ApiEndpoints.debtsSummary);
    final data = response.data as Map<String, dynamic>;
    return DebtSummaryModel.fromJson(data);
  }
}

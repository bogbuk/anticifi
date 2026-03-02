import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/budget_model.dart';

class BudgetsRemoteDataSource {
  final DioClient dioClient;

  BudgetsRemoteDataSource({required this.dioClient});

  Future<List<BudgetModel>> getBudgets() async {
    final response = await dioClient.dio.get(ApiEndpoints.budgets);
    final data = response.data as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list
        .map((e) => BudgetModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BudgetModel> getBudget(String id) async {
    final response = await dioClient.dio.get('${ApiEndpoints.budgets}/$id');
    final data = response.data as Map<String, dynamic>;
    return BudgetModel.fromJson(data);
  }

  Future<BudgetModel> createBudget(Map<String, dynamic> params) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.budgets,
      data: params,
    );
    final data = response.data as Map<String, dynamic>;
    return BudgetModel.fromJson(data);
  }

  Future<BudgetModel> updateBudget(
      String id, Map<String, dynamic> params) async {
    final response = await dioClient.dio.patch(
      '${ApiEndpoints.budgets}/$id',
      data: params,
    );
    final data = response.data as Map<String, dynamic>;
    return BudgetModel.fromJson(data);
  }

  Future<void> deleteBudget(String id) async {
    await dioClient.dio.delete('${ApiEndpoints.budgets}/$id');
  }

  Future<List<BudgetModel>> getBudgetsSummary() async {
    final response = await dioClient.dio.get(ApiEndpoints.budgetsSummary);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => BudgetModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

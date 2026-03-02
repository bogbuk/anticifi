import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budgets_repository.dart';
import '../datasources/budgets_remote_datasource.dart';

class BudgetsRepositoryImpl implements BudgetsRepository {
  final BudgetsRemoteDataSource _remoteDataSource;

  BudgetsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<BudgetEntity>> getBudgets() async {
    return await _remoteDataSource.getBudgets();
  }

  @override
  Future<BudgetEntity> getBudget(String id) async {
    return await _remoteDataSource.getBudget(id);
  }

  @override
  Future<BudgetEntity> createBudget(Map<String, dynamic> params) async {
    return await _remoteDataSource.createBudget(params);
  }

  @override
  Future<BudgetEntity> updateBudget(
      String id, Map<String, dynamic> params) async {
    return await _remoteDataSource.updateBudget(id, params);
  }

  @override
  Future<void> deleteBudget(String id) async {
    await _remoteDataSource.deleteBudget(id);
  }

  @override
  Future<List<BudgetEntity>> getBudgetsSummary() async {
    return await _remoteDataSource.getBudgetsSummary();
  }
}

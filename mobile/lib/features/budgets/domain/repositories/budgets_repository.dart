import '../entities/budget_entity.dart';

abstract class BudgetsRepository {
  Future<List<BudgetEntity>> getBudgets();
  Future<BudgetEntity> getBudget(String id);
  Future<BudgetEntity> createBudget(Map<String, dynamic> params);
  Future<BudgetEntity> updateBudget(String id, Map<String, dynamic> params);
  Future<void> deleteBudget(String id);
  Future<List<BudgetEntity>> getBudgetsSummary();
}

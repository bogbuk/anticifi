import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/budgets_repository.dart';
import 'budgets_state.dart';

class BudgetsCubit extends Cubit<BudgetsState> {
  final BudgetsRepository _repository;

  BudgetsCubit(this._repository) : super(const BudgetsInitial());

  Future<void> loadBudgets() async {
    emit(const BudgetsLoading());
    try {
      final budgets = await _repository.getBudgets();
      emit(BudgetsLoaded(budgets));
    } catch (e) {
      emit(BudgetsError(e.toString()));
    }
  }

  Future<void> createBudget(Map<String, dynamic> params) async {
    try {
      await _repository.createBudget(params);
      await loadBudgets();
    } catch (e) {
      emit(BudgetsError(e.toString()));
    }
  }

  Future<void> updateBudget(String id, Map<String, dynamic> params) async {
    try {
      await _repository.updateBudget(id, params);
      await loadBudgets();
    } catch (e) {
      emit(BudgetsError(e.toString()));
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      await _repository.deleteBudget(id);
      await loadBudgets();
    } catch (e) {
      emit(BudgetsError(e.toString()));
    }
  }
}

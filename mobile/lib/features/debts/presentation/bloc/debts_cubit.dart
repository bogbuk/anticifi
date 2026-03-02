import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/debts_repository.dart';
import 'debts_state.dart';

class DebtsCubit extends Cubit<DebtsState> {
  final DebtsRepository _repository;

  DebtsCubit(this._repository) : super(const DebtsInitial());

  Future<void> loadDebts() async {
    emit(const DebtsLoading());
    try {
      final debts = await _repository.getDebts();
      final summary = await _repository.getSummary();
      emit(DebtsLoaded(debts, summary));
    } catch (e) {
      emit(DebtsError(e.toString()));
    }
  }

  Future<void> loadDebtDetail(String id) async {
    emit(const DebtsLoading());
    try {
      final debt = await _repository.getDebt(id);
      final payments = await _repository.getPayments(id);
      emit(DebtDetailLoaded(debt, payments));
    } catch (e) {
      emit(DebtsError(e.toString()));
    }
  }

  Future<void> createDebt(Map<String, dynamic> params) async {
    try {
      await _repository.createDebt(params);
      await loadDebts();
    } catch (e) {
      emit(DebtsError(e.toString()));
    }
  }

  Future<void> updateDebt(String id, Map<String, dynamic> params) async {
    try {
      await _repository.updateDebt(id, params);
      await loadDebts();
    } catch (e) {
      emit(DebtsError(e.toString()));
    }
  }

  Future<void> deleteDebt(String id) async {
    try {
      await _repository.deleteDebt(id);
      await loadDebts();
    } catch (e) {
      emit(DebtsError(e.toString()));
    }
  }

  Future<void> recordPayment(String debtId, Map<String, dynamic> params) async {
    try {
      await _repository.recordPayment(debtId, params);
      await loadDebtDetail(debtId);
    } catch (e) {
      emit(DebtsError(e.toString()));
    }
  }
}

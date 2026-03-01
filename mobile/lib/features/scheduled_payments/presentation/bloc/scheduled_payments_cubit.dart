import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/scheduled_payments_repository.dart';
import 'scheduled_payments_state.dart';

class ScheduledPaymentsCubit extends Cubit<ScheduledPaymentsState> {
  final ScheduledPaymentsRepository _repository;

  ScheduledPaymentsCubit(this._repository)
      : super(const ScheduledPaymentsInitial());

  Future<void> loadScheduledPayments() async {
    emit(const ScheduledPaymentsLoading());
    try {
      final payments = await _repository.getScheduledPayments();
      emit(ScheduledPaymentsLoaded(payments));
    } catch (e) {
      emit(ScheduledPaymentsError(e.toString()));
    }
  }

  Future<void> createScheduledPayment(Map<String, dynamic> params) async {
    try {
      await _repository.createScheduledPayment(params);
      await loadScheduledPayments();
    } catch (e) {
      emit(ScheduledPaymentsError(e.toString()));
    }
  }

  Future<void> updateScheduledPayment(
      String id, Map<String, dynamic> params) async {
    try {
      await _repository.updateScheduledPayment(id, params);
      await loadScheduledPayments();
    } catch (e) {
      emit(ScheduledPaymentsError(e.toString()));
    }
  }

  Future<void> deleteScheduledPayment(String id) async {
    try {
      await _repository.deleteScheduledPayment(id);
      await loadScheduledPayments();
    } catch (e) {
      emit(ScheduledPaymentsError(e.toString()));
    }
  }

  Future<void> executeScheduledPayment(String id) async {
    try {
      await _repository.executeScheduledPayment(id);
      await loadScheduledPayments();
    } catch (e) {
      emit(ScheduledPaymentsError(e.toString()));
    }
  }
}

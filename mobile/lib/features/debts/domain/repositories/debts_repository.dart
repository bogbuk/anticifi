import '../entities/debt_entity.dart';
import '../entities/debt_payment_entity.dart';
import '../entities/debt_summary_entity.dart';

abstract class DebtsRepository {
  Future<List<DebtEntity>> getDebts({bool? isActive, bool? isPaidOff});
  Future<DebtEntity> getDebt(String id);
  Future<DebtEntity> createDebt(Map<String, dynamic> params);
  Future<DebtEntity> updateDebt(String id, Map<String, dynamic> params);
  Future<void> deleteDebt(String id);
  Future<DebtPaymentEntity> recordPayment(String debtId, Map<String, dynamic> params);
  Future<List<DebtPaymentEntity>> getPayments(String debtId);
  Future<DebtSummaryEntity> getSummary();
}

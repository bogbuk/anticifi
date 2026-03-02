import '../../domain/entities/debt_entity.dart';
import '../../domain/entities/debt_payment_entity.dart';
import '../../domain/entities/debt_summary_entity.dart';
import '../../domain/repositories/debts_repository.dart';
import '../datasources/debts_remote_datasource.dart';

class DebtsRepositoryImpl implements DebtsRepository {
  final DebtsRemoteDataSource _remoteDataSource;

  DebtsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<DebtEntity>> getDebts({bool? isActive, bool? isPaidOff}) async =>
      await _remoteDataSource.getDebts(isActive: isActive, isPaidOff: isPaidOff);

  @override
  Future<DebtEntity> getDebt(String id) async =>
      await _remoteDataSource.getDebt(id);

  @override
  Future<DebtEntity> createDebt(Map<String, dynamic> params) async =>
      await _remoteDataSource.createDebt(params);

  @override
  Future<DebtEntity> updateDebt(String id, Map<String, dynamic> params) async =>
      await _remoteDataSource.updateDebt(id, params);

  @override
  Future<void> deleteDebt(String id) async =>
      await _remoteDataSource.deleteDebt(id);

  @override
  Future<DebtPaymentEntity> recordPayment(String debtId, Map<String, dynamic> params) async =>
      await _remoteDataSource.recordPayment(debtId, params);

  @override
  Future<List<DebtPaymentEntity>> getPayments(String debtId) async =>
      await _remoteDataSource.getPayments(debtId);

  @override
  Future<DebtSummaryEntity> getSummary() async =>
      await _remoteDataSource.getSummary();
}

import '../../domain/entities/scheduled_payment_entity.dart';
import '../../domain/repositories/scheduled_payments_repository.dart';
import '../datasources/scheduled_payments_remote_datasource.dart';

class ScheduledPaymentsRepositoryImpl implements ScheduledPaymentsRepository {
  final ScheduledPaymentsRemoteDataSource _remoteDataSource;

  ScheduledPaymentsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ScheduledPaymentEntity>> getScheduledPayments() async {
    return await _remoteDataSource.getScheduledPayments();
  }

  @override
  Future<ScheduledPaymentEntity> getScheduledPayment(String id) async {
    return await _remoteDataSource.getScheduledPayment(id);
  }

  @override
  Future<ScheduledPaymentEntity> createScheduledPayment(
      Map<String, dynamic> params) async {
    return await _remoteDataSource.createScheduledPayment(params);
  }

  @override
  Future<ScheduledPaymentEntity> updateScheduledPayment(
      String id, Map<String, dynamic> params) async {
    return await _remoteDataSource.updateScheduledPayment(id, params);
  }

  @override
  Future<void> deleteScheduledPayment(String id) async {
    await _remoteDataSource.deleteScheduledPayment(id);
  }

  @override
  Future<ScheduledPaymentEntity> executeScheduledPayment(String id) async {
    return await _remoteDataSource.executeScheduledPayment(id);
  }
}

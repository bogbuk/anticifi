import '../entities/scheduled_payment_entity.dart';

abstract class ScheduledPaymentsRepository {
  Future<List<ScheduledPaymentEntity>> getScheduledPayments();
  Future<ScheduledPaymentEntity> getScheduledPayment(String id);
  Future<ScheduledPaymentEntity> createScheduledPayment(
      Map<String, dynamic> params);
  Future<ScheduledPaymentEntity> updateScheduledPayment(
      String id, Map<String, dynamic> params);
  Future<void> deleteScheduledPayment(String id);
  Future<ScheduledPaymentEntity> executeScheduledPayment(String id);
}

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/scheduled_payment_model.dart';

class ScheduledPaymentsRemoteDataSource {
  final DioClient dioClient;

  ScheduledPaymentsRemoteDataSource({required this.dioClient});

  Future<List<ScheduledPaymentModel>> getScheduledPayments() async {
    final response =
        await dioClient.dio.get(ApiEndpoints.scheduledPayments);
    final data = response.data as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list
        .map((e) =>
            ScheduledPaymentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ScheduledPaymentModel> getScheduledPayment(String id) async {
    final response =
        await dioClient.dio.get('${ApiEndpoints.scheduledPayments}/$id');
    final data = response.data as Map<String, dynamic>;
    return ScheduledPaymentModel.fromJson(data);
  }

  Future<ScheduledPaymentModel> createScheduledPayment(
      Map<String, dynamic> params) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.scheduledPayments,
      data: params,
    );
    final data = response.data as Map<String, dynamic>;
    return ScheduledPaymentModel.fromJson(data);
  }

  Future<ScheduledPaymentModel> updateScheduledPayment(
      String id, Map<String, dynamic> params) async {
    final response = await dioClient.dio.patch(
      '${ApiEndpoints.scheduledPayments}/$id',
      data: params,
    );
    final data = response.data as Map<String, dynamic>;
    return ScheduledPaymentModel.fromJson(data);
  }

  Future<void> deleteScheduledPayment(String id) async {
    await dioClient.dio
        .delete('${ApiEndpoints.scheduledPayments}/$id');
  }

  Future<ScheduledPaymentModel> executeScheduledPayment(
      String id) async {
    final response = await dioClient.dio
        .post('${ApiEndpoints.scheduledPayments}/$id/execute');
    final data = response.data as Map<String, dynamic>;
    return ScheduledPaymentModel.fromJson(data);
  }
}

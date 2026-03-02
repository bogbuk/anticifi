import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/notification_model.dart';

class NotificationsRemoteDataSource {
  final DioClient dioClient;

  NotificationsRemoteDataSource({required this.dioClient});

  Future<List<NotificationModel>> getNotifications() async {
    final response = await dioClient.dio.get(ApiEndpoints.notifications);
    final data = response.data as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;
    return list
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response =
        await dioClient.dio.get(ApiEndpoints.notificationsUnreadCount);
    final data = response.data as Map<String, dynamic>;
    return data['count'] as int? ?? 0;
  }

  Future<void> markAsRead(String id) async {
    await dioClient.dio.patch('${ApiEndpoints.notifications}/$id/read');
  }

  Future<void> markAllAsRead() async {
    await dioClient.dio.patch(ApiEndpoints.notificationsReadAll);
  }

  Future<void> registerFcmToken(String token) async {
    await dioClient.dio.post(ApiEndpoints.fcmToken, data: {'token': token});
  }

  Future<void> removeFcmToken() async {
    await dioClient.dio.delete(ApiEndpoints.fcmToken);
  }
}

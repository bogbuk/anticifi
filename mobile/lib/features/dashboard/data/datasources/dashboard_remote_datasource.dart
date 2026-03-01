import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/dashboard_model.dart';

class DashboardRemoteDataSource {
  final DioClient dioClient;

  DashboardRemoteDataSource({required this.dioClient});

  Future<DashboardModel> getDashboard() async {
    final response = await dioClient.dio.get(ApiEndpoints.dashboard);
    final data = response.data as Map<String, dynamic>;
    return DashboardModel.fromJson(data);
  }
}

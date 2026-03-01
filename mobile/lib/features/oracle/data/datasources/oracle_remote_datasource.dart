import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/prediction_model.dart';

class OracleRemoteDataSource {
  final DioClient dioClient;

  OracleRemoteDataSource({required this.dioClient});

  Future<ChatResponseModel> askQuestion(String question) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.predictionChat,
      data: {'question': question},
    );
    final data = response.data as Map<String, dynamic>;
    return ChatResponseModel.fromJson(data);
  }

  Future<ForecastModel> getForecast(
      String? accountId, int daysAhead) async {
    String url = ApiEndpoints.predictionForecast;
    if (accountId != null) {
      url = '$url/$accountId';
    }
    final response = await dioClient.dio.get(
      url,
      queryParameters: {'daysAhead': daysAhead},
    );
    final data = response.data as Map<String, dynamic>;
    return ForecastModel.fromJson(data);
  }
}

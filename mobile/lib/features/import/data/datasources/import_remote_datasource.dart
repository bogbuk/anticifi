import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/import_job_model.dart';

class ImportRemoteDataSource {
  final DioClient dioClient;

  ImportRemoteDataSource({required this.dioClient});

  Future<ImportJobModel> uploadCsv({
    required String accountId,
    required String filePath,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'accountId': accountId,
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await dioClient.dio.post(
      ApiEndpoints.importCsv,
      data: formData,
    );

    final data = response.data as Map<String, dynamic>;
    return ImportJobModel.fromJson(data);
  }

  Future<List<ImportJobModel>> getJobs() async {
    final response = await dioClient.dio.get(ApiEndpoints.importJobs);
    final data = response.data as Map<String, dynamic>;
    final list = data['jobs'] as List<dynamic>;
    return list
        .map((e) => ImportJobModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ImportJobModel> getJob(String id) async {
    final response =
        await dioClient.dio.get('${ApiEndpoints.importJobs}/$id');
    final data = response.data as Map<String, dynamic>;
    return ImportJobModel.fromJson(data);
  }
}

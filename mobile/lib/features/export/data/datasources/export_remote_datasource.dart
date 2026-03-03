import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/export_entity.dart';

class ExportRemoteDataSource {
  final DioClient dioClient;

  ExportRemoteDataSource({required this.dioClient});

  Future<File> exportData({
    required ExportFormat format,
    DateTime? startDate,
    DateTime? endDate,
    String? accountId,
    String? type,
  }) async {
    final endpoint =
        format == ExportFormat.csv ? ApiEndpoints.exportCsv : ApiEndpoints.exportPdf;

    final queryParams = <String, dynamic>{};
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String().split('T').first;
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String().split('T').first;
    }
    if (accountId != null) queryParams['accountId'] = accountId;
    if (type != null) queryParams['type'] = type;

    final response = await dioClient.dio.get(
      endpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      options: Options(responseType: ResponseType.bytes),
    );

    final tempDir = await getTemporaryDirectory();
    final fileName =
        'anticifi_export_${DateTime.now().millisecondsSinceEpoch}.${format.extension}';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(response.data as List<int>);
    return file;
  }
}

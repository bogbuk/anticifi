import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/receipt_scan_model.dart';

class ReceiptRemoteDataSource {
  final DioClient dioClient;

  ReceiptRemoteDataSource({required this.dioClient});

  Future<ReceiptScanModel> scanReceipt(File image) async {
    final fileName = image.path.split('/').last;
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        image.path,
        filename: fileName,
      ),
    });

    final response = await dioClient.dio.post(
      ApiEndpoints.receiptsScan,
      data: formData,
    );
    final data = response.data as Map<String, dynamic>;
    return ReceiptScanModel.fromJson(data);
  }

  Future<void> confirmReceipt(
    String receiptId, {
    required String accountId,
    required double amount,
    String? merchant,
    required String date,
    required String type,
    String? categoryId,
  }) async {
    await dioClient.dio.post(
      '${ApiEndpoints.receipts}/$receiptId/confirm',
      data: {
        'accountId': accountId,
        'amount': amount,
        'merchant': merchant,
        'date': date,
        'type': type,
        if (categoryId != null) 'categoryId': categoryId,
      },
    );
  }

  Future<List<ReceiptScanModel>> getUserScans() async {
    final response = await dioClient.dio.get(ApiEndpoints.receipts);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => ReceiptScanModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

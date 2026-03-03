import 'dart:io';

import '../entities/receipt_scan_entity.dart';

abstract class ReceiptRepository {
  Future<ReceiptScanEntity> scanReceipt(File image);
  Future<void> confirmReceipt(
    String receiptId, {
    required String accountId,
    required double amount,
    String? merchant,
    required String date,
    required String type,
    String? categoryId,
  });
  Future<List<ReceiptScanEntity>> getUserScans();
}

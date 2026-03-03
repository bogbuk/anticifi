import 'dart:io';

import '../../domain/entities/receipt_scan_entity.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../datasources/receipt_remote_datasource.dart';

class ReceiptRepositoryImpl implements ReceiptRepository {
  final ReceiptRemoteDataSource _dataSource;

  ReceiptRepositoryImpl(this._dataSource);

  @override
  Future<ReceiptScanEntity> scanReceipt(File image) {
    return _dataSource.scanReceipt(image);
  }

  @override
  Future<void> confirmReceipt(
    String receiptId, {
    required String accountId,
    required double amount,
    String? merchant,
    required String date,
    required String type,
    String? categoryId,
  }) {
    return _dataSource.confirmReceipt(
      receiptId,
      accountId: accountId,
      amount: amount,
      merchant: merchant,
      date: date,
      type: type,
      categoryId: categoryId,
    );
  }

  @override
  Future<List<ReceiptScanEntity>> getUserScans() {
    return _dataSource.getUserScans();
  }
}

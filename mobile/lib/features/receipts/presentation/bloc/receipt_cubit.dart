import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/receipt_repository.dart';
import 'receipt_state.dart';

class ReceiptCubit extends Cubit<ReceiptState> {
  final ReceiptRepository _repository;

  ReceiptCubit(this._repository) : super(const ReceiptInitial());

  Future<void> scanReceipt(File image) async {
    emit(const ReceiptScanning());
    try {
      final scan = await _repository.scanReceipt(image);
      emit(ReceiptScanned(scan));
    } catch (e) {
      emit(ReceiptError(e.toString()));
    }
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
    final currentState = state;
    if (currentState is ReceiptScanned) {
      emit(ReceiptConfirming(currentState.scan));
    }
    try {
      await _repository.confirmReceipt(
        receiptId,
        accountId: accountId,
        amount: amount,
        merchant: merchant,
        date: date,
        type: type,
        categoryId: categoryId,
      );
      emit(const ReceiptConfirmed());
    } catch (e) {
      emit(ReceiptError(e.toString()));
    }
  }

  Future<void> loadHistory() async {
    try {
      final scans = await _repository.getUserScans();
      emit(ReceiptHistoryLoaded(scans));
    } catch (e) {
      emit(ReceiptError(e.toString()));
    }
  }

  void reset() {
    emit(const ReceiptInitial());
  }
}

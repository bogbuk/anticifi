import 'package:equatable/equatable.dart';

import '../../domain/entities/receipt_scan_entity.dart';

abstract class ReceiptState extends Equatable {
  const ReceiptState();

  @override
  List<Object?> get props => [];
}

class ReceiptInitial extends ReceiptState {
  const ReceiptInitial();
}

class ReceiptScanning extends ReceiptState {
  const ReceiptScanning();
}

class ReceiptScanned extends ReceiptState {
  final ReceiptScanEntity scan;

  const ReceiptScanned(this.scan);

  @override
  List<Object?> get props => [scan];
}

class ReceiptConfirming extends ReceiptState {
  final ReceiptScanEntity scan;

  const ReceiptConfirming(this.scan);

  @override
  List<Object?> get props => [scan];
}

class ReceiptConfirmed extends ReceiptState {
  const ReceiptConfirmed();
}

class ReceiptHistoryLoaded extends ReceiptState {
  final List<ReceiptScanEntity> scans;

  const ReceiptHistoryLoaded(this.scans);

  @override
  List<Object?> get props => [scans];
}

class ReceiptError extends ReceiptState {
  final String message;

  const ReceiptError(this.message);

  @override
  List<Object?> get props => [message];
}

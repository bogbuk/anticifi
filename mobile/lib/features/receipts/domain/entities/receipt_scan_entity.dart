import 'package:equatable/equatable.dart';

class ReceiptParsedData extends Equatable {
  final String? merchant;
  final double? amount;
  final String? date;
  final List<ReceiptItem>? items;
  final String? currency;

  const ReceiptParsedData({
    this.merchant,
    this.amount,
    this.date,
    this.items,
    this.currency,
  });

  @override
  List<Object?> get props => [merchant, amount, date, items, currency];
}

class ReceiptItem extends Equatable {
  final String name;
  final double price;

  const ReceiptItem({required this.name, required this.price});

  @override
  List<Object?> get props => [name, price];
}

class ReceiptScanEntity extends Equatable {
  final String id;
  final String status;
  final String originalFilename;
  final ReceiptParsedData? parsedData;
  final double confidence;
  final DateTime createdAt;

  const ReceiptScanEntity({
    required this.id,
    required this.status,
    required this.originalFilename,
    this.parsedData,
    required this.confidence,
    required this.createdAt,
  });

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isProcessing => status == 'processing';

  @override
  List<Object?> get props => [
        id,
        status,
        originalFilename,
        parsedData,
        confidence,
        createdAt,
      ];
}

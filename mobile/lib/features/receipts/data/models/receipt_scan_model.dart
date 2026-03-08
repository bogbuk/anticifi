import '../../domain/entities/receipt_scan_entity.dart';

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

class ReceiptItemModel extends ReceiptItem {
  const ReceiptItemModel({required super.name, required super.price});

  factory ReceiptItemModel.fromJson(Map<String, dynamic> json) {
    return ReceiptItemModel(
      name: json['name'] as String? ?? '',
      price: _toDouble(json['price']),
    );
  }
}

class ReceiptParsedDataModel extends ReceiptParsedData {
  const ReceiptParsedDataModel({
    super.merchant,
    super.amount,
    super.date,
    super.items,
    super.currency,
  });

  factory ReceiptParsedDataModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ReceiptParsedDataModel();
    }
    return ReceiptParsedDataModel(
      merchant: json['merchant'] as String?,
      amount: json['amount'] != null ? _toDouble(json['amount']) : null,
      date: json['date'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => ReceiptItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currency: json['currency'] as String?,
    );
  }
}

class ReceiptScanModel extends ReceiptScanEntity {
  const ReceiptScanModel({
    required super.id,
    required super.status,
    required super.originalFilename,
    super.parsedData,
    required super.confidence,
    required super.createdAt,
  });

  factory ReceiptScanModel.fromJson(Map<String, dynamic> json) {
    final parsed = json['parsedData'] ?? json['parsed_data'];
    return ReceiptScanModel(
      id: json['id'] as String,
      status: json['status'] as String,
      originalFilename:
          (json['originalFilename'] ?? json['original_filename']) as String? ??
              '',
      parsedData: parsed != null
          ? ReceiptParsedDataModel.fromJson(parsed as Map<String, dynamic>)
          : null,
      confidence: _toDouble(json['confidence']),
      createdAt: DateTime.parse(
          (json['createdAt'] ?? json['created_at']) as String),
    );
  }
}

import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.accountId,
    required super.amount,
    required super.type,
    super.description,
    super.categoryId,
    super.categoryName,
    required super.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final rawAmount = json['amount'];
    final amount = rawAmount is num
        ? rawAmount.toDouble()
        : double.tryParse(rawAmount.toString()) ?? 0.0;

    final category = json['category'] as Map<String, dynamic>?;

    return TransactionModel(
      id: json['id'] as String,
      accountId: json['accountId'] as String? ?? '',
      amount: amount,
      type: json['type'] as String,
      description: json['description'] as String?,
      categoryId: json['categoryId'] as String? ?? category?['id'] as String?,
      categoryName: json['categoryName'] as String? ?? category?['name'] as String?,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'amount': amount,
      'type': type,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'date': date.toIso8601String(),
    };
  }
}

import '../../domain/entities/debt_payment_entity.dart';

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

class DebtPaymentModel extends DebtPaymentEntity {
  const DebtPaymentModel({
    required super.id,
    required super.debtId,
    required super.amount,
    required super.paymentDate,
    super.notes,
  });

  factory DebtPaymentModel.fromJson(Map<String, dynamic> json) {
    return DebtPaymentModel(
      id: json['id'] as String,
      debtId: json['debtId'] as String,
      amount: _toDouble(json['amount']),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'debtId': debtId,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String().split('T')[0],
      'notes': notes,
    };
  }
}

import '../../domain/entities/debt_entity.dart';

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

class DebtModel extends DebtEntity {
  const DebtModel({
    required super.id,
    required super.name,
    required super.type,
    required super.originalAmount,
    required super.currentBalance,
    required super.interestRate,
    required super.minimumPayment,
    super.dueDay,
    required super.startDate,
    super.expectedPayoffDate,
    super.creditorName,
    super.notes,
    required super.isActive,
    required super.isPaidOff,
    required super.totalPaid,
    required super.progressPercent,
  });

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      originalAmount: _toDouble(json['originalAmount']),
      currentBalance: _toDouble(json['currentBalance']),
      interestRate: _toDouble(json['interestRate']),
      minimumPayment: _toDouble(json['minimumPayment']),
      dueDay: json['dueDay'] as int?,
      startDate: DateTime.parse(json['startDate'] as String),
      expectedPayoffDate: json['expectedPayoffDate'] != null
          ? DateTime.parse(json['expectedPayoffDate'] as String)
          : null,
      creditorName: json['creditorName'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isPaidOff: json['isPaidOff'] as bool? ?? false,
      totalPaid: _toDouble(json['totalPaid']),
      progressPercent: _toDouble(json['progressPercent']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'originalAmount': originalAmount,
      'currentBalance': currentBalance,
      'interestRate': interestRate,
      'minimumPayment': minimumPayment,
      'dueDay': dueDay,
      'startDate': startDate.toIso8601String().split('T')[0],
      'expectedPayoffDate': expectedPayoffDate?.toIso8601String().split('T')[0],
      'creditorName': creditorName,
      'notes': notes,
      'isActive': isActive,
      'isPaidOff': isPaidOff,
    };
  }
}

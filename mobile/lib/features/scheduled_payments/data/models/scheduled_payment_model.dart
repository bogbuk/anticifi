import '../../domain/entities/scheduled_payment_entity.dart';

class ScheduledPaymentModel extends ScheduledPaymentEntity {
  const ScheduledPaymentModel({
    required super.id,
    required super.accountId,
    required super.accountName,
    super.categoryId,
    required super.name,
    required super.amount,
    required super.type,
    required super.frequency,
    required super.startDate,
    super.endDate,
    required super.nextExecutionDate,
    required super.isActive,
    super.lastExecutedAt,
    super.description,
  });

  factory ScheduledPaymentModel.fromJson(Map<String, dynamic> json) {
    return ScheduledPaymentModel(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      accountName: json['accountName'] as String? ?? '',
      categoryId: json['categoryId'] as String?,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      frequency: json['frequency'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      nextExecutionDate:
          DateTime.parse(json['nextExecutionDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      lastExecutedAt: json['lastExecutedAt'] != null
          ? DateTime.parse(json['lastExecutedAt'] as String)
          : null,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'accountName': accountName,
      'categoryId': categoryId,
      'name': name,
      'amount': amount,
      'type': type,
      'frequency': frequency,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'nextExecutionDate': nextExecutionDate.toIso8601String(),
      'isActive': isActive,
      'lastExecutedAt': lastExecutedAt?.toIso8601String(),
      'description': description,
    };
  }
}

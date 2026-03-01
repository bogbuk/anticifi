import 'package:equatable/equatable.dart';

class ScheduledPaymentEntity extends Equatable {
  final String id;
  final String accountId;
  final String accountName;
  final String? categoryId;
  final String name;
  final double amount;
  final String type; // income / expense
  final String frequency; // daily / weekly / biweekly / monthly / quarterly / yearly
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextExecutionDate;
  final bool isActive;
  final DateTime? lastExecutedAt;
  final String? description;

  const ScheduledPaymentEntity({
    required this.id,
    required this.accountId,
    required this.accountName,
    this.categoryId,
    required this.name,
    required this.amount,
    required this.type,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.nextExecutionDate,
    required this.isActive,
    this.lastExecutedAt,
    this.description,
  });

  @override
  List<Object?> get props => [
        id,
        accountId,
        accountName,
        categoryId,
        name,
        amount,
        type,
        frequency,
        startDate,
        endDate,
        nextExecutionDate,
        isActive,
        lastExecutedAt,
        description,
      ];
}

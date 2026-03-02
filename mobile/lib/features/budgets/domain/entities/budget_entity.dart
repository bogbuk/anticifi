import 'package:equatable/equatable.dart';

class BudgetEntity extends Equatable {
  final String id;
  final String name;
  final double amount;
  final double spentAmount;
  final String period; // weekly / monthly / yearly
  final String? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  const BudgetEntity({
    required this.id,
    required this.name,
    required this.amount,
    required this.spentAmount,
    required this.period,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    required this.startDate,
    this.endDate,
    required this.isActive,
  });

  double get progressPercent =>
      amount > 0 ? (spentAmount / amount * 100).clamp(0, 999) : 0;

  double get remainingAmount => (amount - spentAmount).clamp(0, double.infinity);

  bool get isOverBudget => spentAmount > amount;

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        spentAmount,
        period,
        categoryId,
        categoryName,
        categoryIcon,
        categoryColor,
        startDate,
        endDate,
        isActive,
      ];
}

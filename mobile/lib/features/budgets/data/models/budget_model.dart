import '../../domain/entities/budget_entity.dart';

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

class BudgetModel extends BudgetEntity {
  const BudgetModel({
    required super.id,
    required super.name,
    required super.amount,
    required super.spentAmount,
    required super.period,
    super.categoryId,
    super.categoryName,
    super.categoryIcon,
    super.categoryColor,
    required super.startDate,
    super.endDate,
    required super.isActive,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;

    return BudgetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: _toDouble(json['amount']),
      spentAmount: _toDouble(json['spent']),
      period: json['period'] as String,
      categoryId: json['categoryId'] as String? ??
          category?['id'] as String?,
      categoryName: json['categoryName'] as String? ??
          category?['name'] as String?,
      categoryIcon: json['categoryIcon'] as String? ??
          category?['icon'] as String?,
      categoryColor: json['categoryColor'] as String? ??
          category?['color'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'period': period,
      'categoryId': categoryId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
    };
  }
}

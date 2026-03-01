import '../../domain/entities/dashboard_entity.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

class AccountSummaryModel extends AccountSummary {
  const AccountSummaryModel({
    required super.id,
    required super.name,
    required super.type,
    required super.balance,
    required super.currency,
  });

  factory AccountSummaryModel.fromJson(Map<String, dynamic> json) {
    return AccountSummaryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      balance: _toDouble(json['balance']),
      currency: json['currency'] as String? ?? 'USD',
    );
  }
}

class CategorySpendingModel extends CategorySpending {
  const CategorySpendingModel({
    required super.categoryId,
    required super.categoryName,
    required super.amount,
    required super.color,
  });

  factory CategorySpendingModel.fromJson(Map<String, dynamic> json) {
    return CategorySpendingModel(
      categoryId: json['categoryId'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? 'Other',
      amount: _toDouble(json['total']),
      color: json['categoryColor'] as String? ?? '#6366F1',
    );
  }
}

class DashboardTransactionModel extends TransactionEntity {
  const DashboardTransactionModel({
    required super.id,
    required super.accountId,
    required super.amount,
    required super.type,
    super.description,
    super.categoryId,
    super.categoryName,
    required super.date,
  });

  factory DashboardTransactionModel.fromJson(Map<String, dynamic> json) {
    return DashboardTransactionModel(
      id: json['id'] as String,
      accountId: json['accountId'] as String? ?? '',
      amount: _toDouble(json['amount']),
      type: json['type'] as String,
      description: json['description'] as String?,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class DashboardModel extends DashboardEntity {
  const DashboardModel({
    required super.totalBalance,
    required super.monthlyIncome,
    required super.monthlyExpense,
    required super.previousMonthIncome,
    required super.previousMonthExpense,
    required super.accounts,
    required super.spendingByCategory,
    required super.recentTransactions,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final accountsList = (json['accounts'] as List<dynamic>?)
            ?.map((e) =>
                AccountSummaryModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final spendingList = (json['spendingByCategory'] as List<dynamic>?)
            ?.map((e) =>
                CategorySpendingModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final transactionsList = (json['recentTransactions'] as List<dynamic>?)
            ?.map((e) =>
                DashboardTransactionModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final currentMonth = json['currentMonth'] as Map<String, dynamic>?;
    final previousMonth = json['previousMonth'] as Map<String, dynamic>?;

    return DashboardModel(
      totalBalance: _toDouble(json['totalBalance']),
      monthlyIncome: _toDouble(currentMonth?['income']),
      monthlyExpense: _toDouble(currentMonth?['expense']),
      previousMonthIncome: _toDouble(previousMonth?['income']),
      previousMonthExpense: _toDouble(previousMonth?['expense']),
      accounts: accountsList,
      spendingByCategory: spendingList,
      recentTransactions: transactionsList,
    );
  }
}

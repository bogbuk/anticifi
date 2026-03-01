import 'package:equatable/equatable.dart';

import '../../../transactions/domain/entities/transaction_entity.dart';

class AccountSummary extends Equatable {
  final String id;
  final String name;
  final String type;
  final double balance;
  final String currency;

  const AccountSummary({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
  });

  @override
  List<Object?> get props => [id, name, type, balance, currency];
}

class CategorySpending extends Equatable {
  final String categoryId;
  final String categoryName;
  final double amount;
  final String color;

  const CategorySpending({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.color,
  });

  @override
  List<Object?> get props => [categoryId, categoryName, amount, color];
}

class DashboardEntity extends Equatable {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double previousMonthIncome;
  final double previousMonthExpense;
  final List<AccountSummary> accounts;
  final List<CategorySpending> spendingByCategory;
  final List<TransactionEntity> recentTransactions;

  const DashboardEntity({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.previousMonthIncome,
    required this.previousMonthExpense,
    required this.accounts,
    required this.spendingByCategory,
    required this.recentTransactions,
  });

  @override
  List<Object?> get props => [
        totalBalance,
        monthlyIncome,
        monthlyExpense,
        previousMonthIncome,
        previousMonthExpense,
        accounts,
        spendingByCategory,
        recentTransactions,
      ];
}

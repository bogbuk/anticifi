import 'package:flutter_test/flutter_test.dart';
import 'package:anticifi/features/dashboard/data/models/dashboard_model.dart';
import 'package:anticifi/features/dashboard/domain/entities/dashboard_entity.dart';

void main() {
  group('DashboardModel', () {
    test('fromJson should parse nested currentMonth/previousMonth structure', () {
      final json = {
        'totalBalance': 5000.50,
        'currentMonth': {
          'income': 3000.0,
          'expense': 1500.0,
        },
        'previousMonth': {
          'income': 2800.0,
          'expense': 1200.0,
        },
        'accounts': [],
        'spendingByCategory': [],
        'recentTransactions': [],
      };

      final model = DashboardModel.fromJson(json);

      expect(model.totalBalance, 5000.50);
      expect(model.monthlyIncome, 3000.0);
      expect(model.monthlyExpense, 1500.0);
      expect(model.previousMonthIncome, 2800.0);
      expect(model.previousMonthExpense, 1200.0);
    });

    test('fromJson should handle missing nested objects with defaults', () {
      final json = <String, dynamic>{
        'totalBalance': 100.0,
      };

      final model = DashboardModel.fromJson(json);

      expect(model.totalBalance, 100.0);
      expect(model.monthlyIncome, 0.0);
      expect(model.monthlyExpense, 0.0);
      expect(model.previousMonthIncome, 0.0);
      expect(model.previousMonthExpense, 0.0);
      expect(model.accounts, isEmpty);
      expect(model.spendingByCategory, isEmpty);
      expect(model.recentTransactions, isEmpty);
    });

    test('fromJson should parse accounts list', () {
      final json = {
        'totalBalance': 0.0,
        'accounts': [
          {
            'id': 'acc-1',
            'name': 'Checking',
            'type': 'checking',
            'balance': 1500.0,
            'currency': 'USD',
          },
        ],
        'spendingByCategory': [],
        'recentTransactions': [],
      };

      final model = DashboardModel.fromJson(json);

      expect(model.accounts.length, 1);
      expect(model.accounts[0].id, 'acc-1');
      expect(model.accounts[0].name, 'Checking');
      expect(model.accounts[0].balance, 1500.0);
    });

    test('fromJson should parse recentTransactions with optional accountId', () {
      final json = {
        'totalBalance': 0.0,
        'accounts': [],
        'spendingByCategory': [],
        'recentTransactions': [
          {
            'id': 'txn-1',
            'amount': 50.0,
            'type': 'expense',
            'description': 'Coffee',
            'date': '2026-03-01T10:00:00.000Z',
            'categoryName': 'Food',
            'accountName': 'Checking',
          },
        ],
      };

      final model = DashboardModel.fromJson(json);

      expect(model.recentTransactions.length, 1);
      expect(model.recentTransactions[0].id, 'txn-1');
      expect(model.recentTransactions[0].amount, 50.0);
      expect(model.recentTransactions[0].accountId, '');
    });

    test('should be a DashboardEntity', () {
      final model = DashboardModel.fromJson(const {'totalBalance': 0.0});
      expect(model, isA<DashboardEntity>());
    });
  });

  group('CategorySpendingModel', () {
    test('fromJson should parse total and categoryColor from backend format', () {
      final json = {
        'categoryId': 'cat-1',
        'categoryName': 'Food',
        'total': 350.0,
        'categoryColor': '#FF5733',
      };

      final model = CategorySpendingModel.fromJson(json);

      expect(model.categoryId, 'cat-1');
      expect(model.categoryName, 'Food');
      expect(model.amount, 350.0);
      expect(model.color, '#FF5733');
    });

    test('fromJson should handle missing fields with defaults', () {
      final json = <String, dynamic>{};

      final model = CategorySpendingModel.fromJson(json);

      expect(model.categoryId, '');
      expect(model.categoryName, 'Other');
      expect(model.amount, 0.0);
      expect(model.color, '#6366F1');
    });
  });

  group('AccountSummaryModel', () {
    test('fromJson should parse all fields', () {
      final json = {
        'id': 'acc-1',
        'name': 'Savings',
        'type': 'savings',
        'balance': 10000.0,
        'currency': 'EUR',
      };

      final model = AccountSummaryModel.fromJson(json);

      expect(model.id, 'acc-1');
      expect(model.name, 'Savings');
      expect(model.type, 'savings');
      expect(model.balance, 10000.0);
      expect(model.currency, 'EUR');
    });
  });

  group('DashboardTransactionModel', () {
    test('fromJson should parse dashboard transaction format', () {
      final json = {
        'id': 'txn-1',
        'amount': 25.0,
        'type': 'expense',
        'description': 'Lunch',
        'date': '2026-03-01T12:00:00.000Z',
        'categoryName': 'Food',
        'accountName': 'Checking',
      };

      final model = DashboardTransactionModel.fromJson(json);

      expect(model.id, 'txn-1');
      expect(model.amount, 25.0);
      expect(model.type, 'expense');
      expect(model.accountId, '');
      expect(model.categoryName, 'Food');
    });

    test('fromJson should use accountId when provided', () {
      final json = {
        'id': 'txn-2',
        'accountId': 'acc-1',
        'amount': 100.0,
        'type': 'income',
        'date': '2026-03-01T12:00:00.000Z',
      };

      final model = DashboardTransactionModel.fromJson(json);

      expect(model.accountId, 'acc-1');
    });
  });
}

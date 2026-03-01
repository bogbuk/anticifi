import 'package:flutter_test/flutter_test.dart';
import 'package:anticifi/features/transactions/data/models/transaction_model.dart';
import 'package:anticifi/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  group('TransactionModel', () {
    test('fromJson should create TransactionModel with full data', () {
      final json = {
        'id': 'txn-1',
        'accountId': 'acc-1',
        'amount': 250.75,
        'type': 'expense',
        'description': 'Groceries',
        'categoryId': 'cat-1',
        'categoryName': 'Food',
        'date': '2026-03-01T10:30:00.000Z',
      };

      final model = TransactionModel.fromJson(json);

      expect(model.id, 'txn-1');
      expect(model.accountId, 'acc-1');
      expect(model.amount, 250.75);
      expect(model.type, 'expense');
      expect(model.description, 'Groceries');
      expect(model.categoryId, 'cat-1');
      expect(model.categoryName, 'Food');
      expect(model.date, DateTime.parse('2026-03-01T10:30:00.000Z'));
    });

    test('fromJson should handle null optional fields', () {
      final json = {
        'id': 'txn-2',
        'accountId': 'acc-1',
        'amount': 100.0,
        'type': 'income',
        'date': '2026-02-15T08:00:00.000Z',
      };

      final model = TransactionModel.fromJson(json);

      expect(model.id, 'txn-2');
      expect(model.accountId, 'acc-1');
      expect(model.amount, 100.0);
      expect(model.type, 'income');
      expect(model.description, isNull);
      expect(model.categoryId, isNull);
      expect(model.categoryName, isNull);
    });

    test('fromJson should convert int amount to double', () {
      final json = {
        'id': 'txn-3',
        'accountId': 'acc-1',
        'amount': 300,
        'type': 'expense',
        'date': '2026-01-20T12:00:00.000Z',
      };

      final model = TransactionModel.fromJson(json);

      expect(model.amount, isA<double>());
      expect(model.amount, 300.0);
    });

    test('fromJson should correctly parse date string', () {
      final json = {
        'id': 'txn-4',
        'accountId': 'acc-1',
        'amount': 50.0,
        'type': 'expense',
        'date': '2026-06-15T14:30:00.000Z',
      };

      final model = TransactionModel.fromJson(json);

      expect(model.date.year, 2026);
      expect(model.date.month, 6);
      expect(model.date.day, 15);
    });

    test('toJson should produce correct map', () {
      final date = DateTime.parse('2026-03-01T10:30:00.000Z');
      final model = TransactionModel(
        id: 'txn-1',
        accountId: 'acc-1',
        amount: 250.75,
        type: 'expense',
        description: 'Groceries',
        categoryId: 'cat-1',
        categoryName: 'Food',
        date: date,
      );

      final json = model.toJson();

      expect(json['id'], 'txn-1');
      expect(json['accountId'], 'acc-1');
      expect(json['amount'], 250.75);
      expect(json['type'], 'expense');
      expect(json['description'], 'Groceries');
      expect(json['categoryId'], 'cat-1');
      expect(json['categoryName'], 'Food');
      expect(json['date'], date.toIso8601String());
    });

    test('TransactionModel should be a TransactionEntity', () {
      final model = TransactionModel(
        id: 'txn-1',
        accountId: 'acc-1',
        amount: 100.0,
        type: 'income',
        date: DateTime.now(),
      );

      expect(model, isA<TransactionEntity>());
    });
  });
}

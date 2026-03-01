import 'package:flutter_test/flutter_test.dart';
import 'package:anticifi/features/accounts/data/models/account_model.dart';
import 'package:anticifi/features/accounts/domain/entities/account_entity.dart';

void main() {
  group('AccountModel', () {
    test('fromJson should create AccountModel with all fields', () {
      final json = {
        'id': 'acc-1',
        'userId': 'user-1',
        'name': 'Main Account',
        'type': 'checking',
        'bank': 'Chase',
        'currency': 'EUR',
        'balance': 1500.50,
        'initialBalance': 1000.0,
      };

      final model = AccountModel.fromJson(json);

      expect(model.id, 'acc-1');
      expect(model.userId, 'user-1');
      expect(model.name, 'Main Account');
      expect(model.type, 'checking');
      expect(model.bank, 'Chase');
      expect(model.currency, 'EUR');
      expect(model.balance, 1500.50);
      expect(model.initialBalance, 1000.0);
    });

    test('fromJson should use defaults for missing optional fields', () {
      final json = {
        'id': 'acc-2',
        'name': 'Savings',
        'type': 'savings',
      };

      final model = AccountModel.fromJson(json);

      expect(model.id, 'acc-2');
      expect(model.userId, '');
      expect(model.name, 'Savings');
      expect(model.type, 'savings');
      expect(model.bank, isNull);
      expect(model.currency, 'USD');
      expect(model.balance, 0.0);
      expect(model.initialBalance, 0.0);
    });

    test('fromJson should convert int balance and initialBalance to double', () {
      final json = {
        'id': 'acc-3',
        'userId': 'user-1',
        'name': 'Cash',
        'type': 'cash',
        'currency': 'USD',
        'balance': 500,
        'initialBalance': 100,
      };

      final model = AccountModel.fromJson(json);

      expect(model.balance, isA<double>());
      expect(model.balance, 500.0);
      expect(model.initialBalance, isA<double>());
      expect(model.initialBalance, 100.0);
    });

    test('toJson should produce correct map', () {
      const model = AccountModel(
        id: 'acc-1',
        userId: 'user-1',
        name: 'Main Account',
        type: 'checking',
        bank: 'Chase',
        currency: 'EUR',
        balance: 1500.50,
        initialBalance: 1000.0,
      );

      final json = model.toJson();

      expect(json, {
        'id': 'acc-1',
        'userId': 'user-1',
        'name': 'Main Account',
        'type': 'checking',
        'bank': 'Chase',
        'currency': 'EUR',
        'balance': 1500.50,
        'initialBalance': 1000.0,
      });
    });

    test('AccountModel should be an AccountEntity', () {
      const model = AccountModel(
        id: 'acc-1',
        userId: 'user-1',
        name: 'Main Account',
        type: 'checking',
        currency: 'USD',
        balance: 0.0,
        initialBalance: 0.0,
      );

      expect(model, isA<AccountEntity>());
    });
  });
}

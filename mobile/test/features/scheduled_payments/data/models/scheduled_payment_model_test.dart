import 'package:flutter_test/flutter_test.dart';
import 'package:anticifi/features/scheduled_payments/data/models/scheduled_payment_model.dart';
import 'package:anticifi/features/scheduled_payments/domain/entities/scheduled_payment_entity.dart';

void main() {
  group('ScheduledPaymentModel', () {
    test('fromJson should parse nested account object', () {
      final json = {
        'id': 'sp-1',
        'account': {
          'id': 'acc-1',
          'name': 'Checking',
          'type': 'checking',
          'currency': 'USD',
        },
        'categoryId': 'cat-1',
        'name': 'Rent',
        'amount': 1200.0,
        'type': 'expense',
        'frequency': 'monthly',
        'startDate': '2026-01-01T00:00:00.000Z',
        'nextExecutionDate': '2026-04-01T00:00:00.000Z',
        'isActive': true,
        'description': 'Monthly rent payment',
      };

      final model = ScheduledPaymentModel.fromJson(json);

      expect(model.id, 'sp-1');
      expect(model.accountId, 'acc-1');
      expect(model.accountName, 'Checking');
      expect(model.name, 'Rent');
      expect(model.amount, 1200.0);
      expect(model.type, 'expense');
      expect(model.frequency, 'monthly');
      expect(model.isActive, true);
      expect(model.description, 'Monthly rent payment');
    });

    test('fromJson should fallback to flat accountId/accountName when no nested account', () {
      final json = {
        'id': 'sp-2',
        'accountId': 'acc-2',
        'accountName': 'Savings',
        'name': 'Subscription',
        'amount': 15.0,
        'type': 'expense',
        'frequency': 'monthly',
        'startDate': '2026-01-15T00:00:00.000Z',
        'nextExecutionDate': '2026-04-15T00:00:00.000Z',
      };

      final model = ScheduledPaymentModel.fromJson(json);

      expect(model.accountId, 'acc-2');
      expect(model.accountName, 'Savings');
    });

    test('fromJson should handle null optional fields', () {
      final json = {
        'id': 'sp-3',
        'accountId': 'acc-1',
        'name': 'Test',
        'amount': 50.0,
        'type': 'income',
        'frequency': 'weekly',
        'startDate': '2026-02-01T00:00:00.000Z',
        'nextExecutionDate': '2026-03-08T00:00:00.000Z',
      };

      final model = ScheduledPaymentModel.fromJson(json);

      expect(model.categoryId, isNull);
      expect(model.endDate, isNull);
      expect(model.lastExecutedAt, isNull);
      expect(model.description, isNull);
    });

    test('fromJson should parse endDate and lastExecutedAt', () {
      final json = {
        'id': 'sp-4',
        'accountId': 'acc-1',
        'name': 'Temp',
        'amount': 100.0,
        'type': 'expense',
        'frequency': 'daily',
        'startDate': '2026-01-01T00:00:00.000Z',
        'endDate': '2026-12-31T00:00:00.000Z',
        'nextExecutionDate': '2026-03-02T00:00:00.000Z',
        'lastExecutedAt': '2026-03-01T00:00:00.000Z',
      };

      final model = ScheduledPaymentModel.fromJson(json);

      expect(model.endDate, DateTime.parse('2026-12-31T00:00:00.000Z'));
      expect(model.lastExecutedAt, DateTime.parse('2026-03-01T00:00:00.000Z'));
    });

    test('toJson should produce correct map', () {
      final model = ScheduledPaymentModel(
        id: 'sp-1',
        accountId: 'acc-1',
        accountName: 'Checking',
        name: 'Rent',
        amount: 1200.0,
        type: 'expense',
        frequency: 'monthly',
        startDate: DateTime.parse('2026-01-01T00:00:00.000Z'),
        nextExecutionDate: DateTime.parse('2026-04-01T00:00:00.000Z'),
        isActive: true,
      );

      final json = model.toJson();

      expect(json['id'], 'sp-1');
      expect(json['accountId'], 'acc-1');
      expect(json['accountName'], 'Checking');
      expect(json['amount'], 1200.0);
      expect(json['frequency'], 'monthly');
    });

    test('should be a ScheduledPaymentEntity', () {
      final model = ScheduledPaymentModel(
        id: 'sp-1',
        accountId: 'acc-1',
        accountName: 'Checking',
        name: 'Test',
        amount: 10.0,
        type: 'expense',
        frequency: 'monthly',
        startDate: DateTime.now(),
        nextExecutionDate: DateTime.now(),
        isActive: true,
      );

      expect(model, isA<ScheduledPaymentEntity>());
    });
  });
}

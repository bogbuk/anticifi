import 'package:flutter_test/flutter_test.dart';
import 'package:anticifi/features/notifications/data/models/notification_model.dart';
import 'package:anticifi/features/notifications/domain/entities/notification_entity.dart';

void main() {
  group('NotificationModel', () {
    test('fromJson should create model with full data', () {
      final json = {
        'id': 'notif-1',
        'title': 'Payment Due',
        'body': 'Your rent payment of \$1200 is due tomorrow.',
        'type': 'payment_reminder',
        'isRead': false,
        'metadata': {'paymentId': 'sp-1'},
        'createdAt': '2026-03-01T08:00:00.000Z',
      };

      final model = NotificationModel.fromJson(json);

      expect(model.id, 'notif-1');
      expect(model.title, 'Payment Due');
      expect(model.body, contains('rent payment'));
      expect(model.type, 'payment_reminder');
      expect(model.isRead, false);
      expect(model.metadata, isNotNull);
      expect(model.metadata!['paymentId'], 'sp-1');
      expect(model.createdAt, DateTime.parse('2026-03-01T08:00:00.000Z'));
    });

    test('fromJson should handle missing optional fields with defaults', () {
      final json = {
        'id': 'notif-2',
      };

      final model = NotificationModel.fromJson(json);

      expect(model.id, 'notif-2');
      expect(model.title, '');
      expect(model.body, '');
      expect(model.type, 'system');
      expect(model.isRead, false);
      expect(model.metadata, isNull);
    });

    test('fromJson should parse isRead as true', () {
      final json = {
        'id': 'notif-3',
        'isRead': true,
        'createdAt': '2026-02-28T10:00:00.000Z',
      };

      final model = NotificationModel.fromJson(json);

      expect(model.isRead, true);
    });

    test('fromJson should parse createdAt correctly', () {
      final json = {
        'id': 'notif-4',
        'createdAt': '2026-06-15T14:30:00.000Z',
      };

      final model = NotificationModel.fromJson(json);

      expect(model.createdAt.year, 2026);
      expect(model.createdAt.month, 6);
      expect(model.createdAt.day, 15);
    });

    test('should be a NotificationEntity', () {
      final model = NotificationModel.fromJson(const {'id': 'notif-1'});
      expect(model, isA<NotificationEntity>());
    });
  });
}

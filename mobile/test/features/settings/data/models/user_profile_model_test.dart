import 'package:flutter_test/flutter_test.dart';
import 'package:anticifi/features/settings/data/models/user_profile_model.dart';
import 'package:anticifi/features/settings/domain/entities/user_profile_entity.dart';

void main() {
  group('UserProfileModel', () {
    test('fromJson should create model with full data', () {
      final json = {
        'id': 'user-1',
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'currency': 'EUR',
        'locale': 'de',
        'notificationsEnabled': false,
        'theme': 'dark',
        'createdAt': '2026-01-15T10:00:00.000Z',
      };

      final model = UserProfileModel.fromJson(json);

      expect(model.id, 'user-1');
      expect(model.email, 'test@example.com');
      expect(model.firstName, 'John');
      expect(model.lastName, 'Doe');
      expect(model.currency, 'EUR');
      expect(model.locale, 'de');
      expect(model.notificationsEnabled, false);
      expect(model.theme, 'dark');
      expect(model.createdAt, DateTime.parse('2026-01-15T10:00:00.000Z'));
    });

    test('fromJson should handle null/missing optional fields with defaults', () {
      final json = {
        'id': 'user-2',
      };

      final model = UserProfileModel.fromJson(json);

      expect(model.id, 'user-2');
      expect(model.email, '');
      expect(model.firstName, '');
      expect(model.lastName, '');
      expect(model.currency, 'USD');
      expect(model.locale, 'en');
      expect(model.notificationsEnabled, true);
      expect(model.theme, 'system');
    });

    test('fullName should return firstName + lastName combined', () {
      final json = {
        'id': 'user-3',
        'firstName': 'Jane',
        'lastName': 'Smith',
      };

      final model = UserProfileModel.fromJson(json);

      expect(model.fullName, 'Jane Smith');
    });

    test('fullName should return email when both names are empty', () {
      final json = {
        'id': 'user-4',
        'email': 'user@test.com',
        'firstName': '',
        'lastName': '',
      };

      final model = UserProfileModel.fromJson(json);

      expect(model.fullName, 'user@test.com');
    });

    test('fullName should handle only firstName', () {
      final json = {
        'id': 'user-5',
        'firstName': 'Alice',
        'lastName': '',
      };

      final model = UserProfileModel.fromJson(json);

      expect(model.fullName, 'Alice');
    });

    test('should be a UserProfileEntity', () {
      final model = UserProfileModel.fromJson(const {'id': 'user-1'});
      expect(model, isA<UserProfileEntity>());
    });
  });
}

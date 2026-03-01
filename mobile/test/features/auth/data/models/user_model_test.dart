import 'package:flutter_test/flutter_test.dart';
import 'package:anticifi/features/auth/data/models/user_model.dart';
import 'package:anticifi/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserModel', () {
    test('fromJson should create UserModel with full data (firstName + lastName)', () {
      final json = {
        'id': '1',
        'firstName': 'John',
        'lastName': 'Doe',
        'email': 'john@example.com',
      };

      final model = UserModel.fromJson(json);

      expect(model.id, '1');
      expect(model.name, 'John Doe');
      expect(model.email, 'john@example.com');
    });

    test('fromJson should create UserModel with only firstName (no lastName)', () {
      final json = {
        'id': '2',
        'firstName': 'Jane',
        'email': 'jane@example.com',
      };

      final model = UserModel.fromJson(json);

      expect(model.id, '2');
      expect(model.name, 'Jane');
      expect(model.email, 'jane@example.com');
    });

    test('fromJson should handle empty names (defaults to empty string)', () {
      final json = {
        'id': '3',
        'email': 'empty@example.com',
      };

      final model = UserModel.fromJson(json);

      expect(model.id, '3');
      expect(model.name, '');
      expect(model.email, 'empty@example.com');
    });

    test('toJson should produce correct map', () {
      const model = UserModel(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
      );

      final json = model.toJson();

      expect(json, {
        'id': '1',
        'name': 'John Doe',
        'email': 'john@example.com',
      });
    });

    test('UserModel should be a UserEntity', () {
      const model = UserModel(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
      );

      expect(model, isA<UserEntity>());
    });
  });
}

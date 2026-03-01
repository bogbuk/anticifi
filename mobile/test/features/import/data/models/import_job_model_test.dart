import 'package:flutter_test/flutter_test.dart';
import 'package:anticifi/features/import/data/models/import_job_model.dart';
import 'package:anticifi/features/import/domain/entities/import_job_entity.dart';

void main() {
  group('ImportJobModel', () {
    test('fromJson should create model with full data', () {
      final json = {
        'id': 'job-1',
        'accountId': 'acc-1',
        'status': 'completed',
        'format': 'csv',
        'importedCount': 150,
        'skippedCount': 5,
        'errorCount': 2,
        'createdAt': '2026-03-01T09:00:00.000Z',
        'completedAt': '2026-03-01T09:05:00.000Z',
      };

      final model = ImportJobModel.fromJson(json);

      expect(model.id, 'job-1');
      expect(model.accountId, 'acc-1');
      expect(model.status, 'completed');
      expect(model.format, 'csv');
      expect(model.importedCount, 150);
      expect(model.skippedCount, 5);
      expect(model.errorCount, 2);
      expect(model.createdAt, DateTime.parse('2026-03-01T09:00:00.000Z'));
      expect(model.completedAt, DateTime.parse('2026-03-01T09:05:00.000Z'));
    });

    test('fromJson should handle defaults for optional fields', () {
      final json = {
        'id': 'job-2',
        'accountId': 'acc-2',
        'createdAt': '2026-02-28T12:00:00.000Z',
      };

      final model = ImportJobModel.fromJson(json);

      expect(model.status, 'pending');
      expect(model.format, 'csv');
      expect(model.importedCount, 0);
      expect(model.skippedCount, 0);
      expect(model.errorCount, 0);
      expect(model.completedAt, isNull);
    });

    test('fromJson should handle processing status', () {
      final json = {
        'id': 'job-3',
        'accountId': 'acc-1',
        'status': 'processing',
        'format': 'ofx',
        'importedCount': 50,
        'skippedCount': 0,
        'errorCount': 0,
        'createdAt': '2026-03-01T10:00:00.000Z',
      };

      final model = ImportJobModel.fromJson(json);

      expect(model.status, 'processing');
      expect(model.format, 'ofx');
      expect(model.importedCount, 50);
    });

    test('should be an ImportJobEntity', () {
      final model = ImportJobModel.fromJson(const {
        'id': 'job-1',
        'accountId': 'acc-1',
        'createdAt': '2026-01-01T00:00:00.000Z',
      });
      expect(model, isA<ImportJobEntity>());
    });
  });
}

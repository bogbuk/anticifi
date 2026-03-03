import 'dart:io';

import '../entities/export_entity.dart';

abstract class ExportRepository {
  Future<File> exportData({
    required ExportFormat format,
    DateTime? startDate,
    DateTime? endDate,
    String? accountId,
    String? type,
  });
}

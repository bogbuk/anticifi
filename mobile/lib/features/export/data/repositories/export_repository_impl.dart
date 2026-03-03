import 'dart:io';

import '../../domain/entities/export_entity.dart';
import '../../domain/repositories/export_repository.dart';
import '../datasources/export_remote_datasource.dart';

class ExportRepositoryImpl implements ExportRepository {
  final ExportRemoteDataSource _dataSource;

  ExportRepositoryImpl(this._dataSource);

  @override
  Future<File> exportData({
    required ExportFormat format,
    DateTime? startDate,
    DateTime? endDate,
    String? accountId,
    String? type,
  }) {
    return _dataSource.exportData(
      format: format,
      startDate: startDate,
      endDate: endDate,
      accountId: accountId,
      type: type,
    );
  }
}

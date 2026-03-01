import '../../domain/entities/import_job_entity.dart';

class ImportJobModel extends ImportJobEntity {
  const ImportJobModel({
    required super.id,
    required super.accountId,
    required super.status,
    required super.format,
    required super.importedCount,
    required super.skippedCount,
    required super.errorCount,
    required super.createdAt,
    super.completedAt,
  });

  factory ImportJobModel.fromJson(Map<String, dynamic> json) {
    return ImportJobModel(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      status: json['status'] as String? ?? 'pending',
      format: json['format'] as String? ?? 'csv',
      importedCount: json['importedCount'] as int? ?? 0,
      skippedCount: json['skippedCount'] as int? ?? 0,
      errorCount: json['errorCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}

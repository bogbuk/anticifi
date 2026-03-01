import 'package:equatable/equatable.dart';

class ImportJobEntity extends Equatable {
  final String id;
  final String accountId;
  final String status;
  final String format;
  final int importedCount;
  final int skippedCount;
  final int errorCount;
  final DateTime createdAt;
  final DateTime? completedAt;

  const ImportJobEntity({
    required this.id,
    required this.accountId,
    required this.status,
    required this.format,
    required this.importedCount,
    required this.skippedCount,
    required this.errorCount,
    required this.createdAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        id,
        accountId,
        status,
        format,
        importedCount,
        skippedCount,
        errorCount,
        createdAt,
        completedAt,
      ];
}

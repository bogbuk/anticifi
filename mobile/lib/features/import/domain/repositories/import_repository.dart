import '../entities/import_job_entity.dart';

abstract class ImportRepository {
  Future<ImportJobEntity> uploadCsv({
    required String accountId,
    required String filePath,
    required String fileName,
  });
  Future<List<ImportJobEntity>> getJobs();
  Future<ImportJobEntity> getJob(String id);
}

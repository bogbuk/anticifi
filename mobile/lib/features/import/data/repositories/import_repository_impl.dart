import '../../domain/entities/import_job_entity.dart';
import '../../domain/repositories/import_repository.dart';
import '../datasources/import_remote_datasource.dart';

class ImportRepositoryImpl implements ImportRepository {
  final ImportRemoteDataSource _remoteDataSource;

  ImportRepositoryImpl(this._remoteDataSource);

  @override
  Future<ImportJobEntity> uploadCsv({
    required String accountId,
    required String filePath,
    required String fileName,
  }) async {
    return await _remoteDataSource.uploadCsv(
      accountId: accountId,
      filePath: filePath,
      fileName: fileName,
    );
  }

  @override
  Future<List<ImportJobEntity>> getJobs() async {
    return await _remoteDataSource.getJobs();
  }

  @override
  Future<ImportJobEntity> getJob(String id) async {
    return await _remoteDataSource.getJob(id);
  }
}

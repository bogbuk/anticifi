import '../../domain/entities/prediction_entity.dart';
import '../../domain/repositories/oracle_repository.dart';
import '../datasources/oracle_remote_datasource.dart';

class OracleRepositoryImpl implements OracleRepository {
  final OracleRemoteDataSource _remoteDataSource;

  OracleRepositoryImpl(this._remoteDataSource);

  @override
  Future<ChatResponse> askQuestion(String question) async {
    final model = await _remoteDataSource.askQuestion(question);
    return ChatResponse(
      answer: model.answer,
      predictions: model.predictions,
    );
  }

  @override
  Future<ForecastEntity> getForecast(
      String? accountId, int daysAhead) async {
    return await _remoteDataSource.getForecast(accountId, daysAhead);
  }
}

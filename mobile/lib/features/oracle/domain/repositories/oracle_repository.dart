import '../entities/prediction_entity.dart';

class ChatResponse {
  final String answer;
  final List<PredictionEntity>? predictions;

  const ChatResponse({
    required this.answer,
    this.predictions,
  });
}

abstract class OracleRepository {
  Future<ChatResponse> askQuestion(String question);
  Future<ForecastEntity> getForecast(String? accountId, int daysAhead);
}

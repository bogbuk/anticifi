import '../../domain/entities/prediction_entity.dart';

class PredictionModel extends PredictionEntity {
  const PredictionModel({
    required super.date,
    required super.predictedBalance,
    required super.lowerBound,
    required super.upperBound,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      date: DateTime.parse(json['date'] as String),
      predictedBalance:
          (json['predictedBalance'] as num?)?.toDouble() ?? 0.0,
      lowerBound: (json['lowerBound'] as num?)?.toDouble() ?? 0.0,
      upperBound: (json['upperBound'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ChatResponseModel {
  final String answer;
  final List<PredictionModel>? predictions;

  const ChatResponseModel({
    required this.answer,
    this.predictions,
  });

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    final predictionsJson = json['predictions'] as List<dynamic>?;
    final predictions = predictionsJson
        ?.map((e) => PredictionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return ChatResponseModel(
      answer: json['answer'] as String? ?? '',
      predictions: predictions,
    );
  }
}

class ForecastModel extends ForecastEntity {
  const ForecastModel({
    required super.predictions,
    required super.currentBalance,
    required super.confidence,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final predictionsJson = json['predictions'] as List<dynamic>? ?? [];
    final predictions = predictionsJson
        .map((e) => PredictionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return ForecastModel(
      predictions: predictions,
      currentBalance:
          (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

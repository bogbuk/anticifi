import '../../domain/entities/prediction_entity.dart';

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

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
      predictedBalance: _toDouble(json['predictedBalance']),
      lowerBound: _toDouble(json['lowerBound']),
      upperBound: _toDouble(json['upperBound']),
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
      currentBalance: _toDouble(json['currentBalance']),
      confidence: _toDouble(json['confidence']),
    );
  }
}

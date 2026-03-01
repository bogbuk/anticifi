import 'package:equatable/equatable.dart';

class PredictionEntity extends Equatable {
  final DateTime date;
  final double predictedBalance;
  final double lowerBound;
  final double upperBound;

  const PredictionEntity({
    required this.date,
    required this.predictedBalance,
    required this.lowerBound,
    required this.upperBound,
  });

  @override
  List<Object?> get props => [date, predictedBalance, lowerBound, upperBound];
}

class ChatMessage extends Equatable {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<PredictionEntity>? predictions;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.predictions,
  });

  @override
  List<Object?> get props => [id, content, isUser, timestamp, predictions];
}

class ForecastEntity extends Equatable {
  final List<PredictionEntity> predictions;
  final double currentBalance;
  final double confidence;

  const ForecastEntity({
    required this.predictions,
    required this.currentBalance,
    required this.confidence,
  });

  @override
  List<Object?> get props => [predictions, currentBalance, confidence];
}

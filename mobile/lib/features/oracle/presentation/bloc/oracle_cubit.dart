import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/prediction_entity.dart';
import '../../domain/repositories/oracle_repository.dart';
import 'oracle_state.dart';

class OracleCubit extends Cubit<OracleState> {
  final OracleRepository _repository;

  OracleCubit(this._repository) : super(const OracleState());

  Future<void> askQuestion(String question) async {
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: question,
      isUser: true,
      timestamp: DateTime.now(),
    );

    emit(state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    ));

    try {
      final response = await _repository.askQuestion(question);

      final botMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content: response.answer,
        isUser: false,
        timestamp: DateTime.now(),
        predictions: response.predictions,
      );

      emit(state.copyWith(
        messages: [...state.messages, botMessage],
        isLoading: false,
      ));
    } catch (e) {
      final errorMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        content:
            'Sorry, I encountered an error. Please try again later.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      emit(state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> getForecast(String? accountId,
      {int daysAhead = 30}) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final forecast =
          await _repository.getForecast(accountId, daysAhead);

      final botMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content:
            'Here\'s your $daysAhead-day forecast. Current balance: \$${forecast.currentBalance.toStringAsFixed(2)}. Confidence: ${(forecast.confidence * 100).toStringAsFixed(0)}%.',
        isUser: false,
        timestamp: DateTime.now(),
        predictions: forecast.predictions,
      );

      emit(state.copyWith(
        messages: [...state.messages, botMessage],
        isLoading: false,
      ));
    } catch (e) {
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content:
            'Sorry, I couldn\'t generate a forecast right now. Please try again later.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      emit(state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}

import 'package:equatable/equatable.dart';

import '../../domain/entities/prediction_entity.dart';

class OracleState extends Equatable {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  const OracleState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  OracleState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return OracleState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, error];
}

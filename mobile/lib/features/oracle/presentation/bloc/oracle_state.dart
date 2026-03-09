import 'package:equatable/equatable.dart';

import '../../domain/entities/prediction_entity.dart';

class OracleState extends Equatable {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final bool requiresPremium;

  const OracleState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.requiresPremium = false,
  });

  OracleState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    bool? requiresPremium,
  }) {
    return OracleState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      requiresPremium: requiresPremium ?? this.requiresPremium,
    );
  }

  @override
  List<Object?> get props => [messages, isLoading, error, requiresPremium];
}

import 'package:equatable/equatable.dart';

import '../../domain/entities/transaction_entity.dart';

abstract class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object?> get props => [];
}

class TransactionsInitial extends TransactionsState {
  const TransactionsInitial();
}

class TransactionsLoading extends TransactionsState {
  const TransactionsLoading();
}

class TransactionsLoaded extends TransactionsState {
  final List<TransactionEntity> transactions;
  final bool hasMore;
  final int currentPage;
  final int total;
  final bool isLoadingMore;
  final String? typeFilter;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const TransactionsLoaded({
    required this.transactions,
    required this.hasMore,
    required this.currentPage,
    required this.total,
    this.isLoadingMore = false,
    this.typeFilter,
    this.dateFrom,
    this.dateTo,
  });

  TransactionsLoaded copyWith({
    List<TransactionEntity>? transactions,
    bool? hasMore,
    int? currentPage,
    int? total,
    bool? isLoadingMore,
    String? typeFilter,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return TransactionsLoaded(
      transactions: transactions ?? this.transactions,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      typeFilter: typeFilter ?? this.typeFilter,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
    );
  }

  @override
  List<Object?> get props => [
        transactions,
        hasMore,
        currentPage,
        total,
        isLoadingMore,
        typeFilter,
        dateFrom,
        dateTo,
      ];
}

class TransactionsError extends TransactionsState {
  final String message;

  const TransactionsError(this.message);

  @override
  List<Object?> get props => [message];
}

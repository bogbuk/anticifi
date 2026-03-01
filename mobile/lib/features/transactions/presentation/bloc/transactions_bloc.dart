import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/transactions_repository.dart';
import 'transactions_event.dart';
import 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final TransactionsRepository _repository;

  TransactionsBloc(this._repository) : super(const TransactionsInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadMoreTransactions>(_onLoadMoreTransactions);
    on<CreateTransaction>(_onCreateTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(const TransactionsLoading());
    try {
      final response = await _repository.getTransactions(
        page: event.page,
        type: event.typeFilter,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      );
      emit(TransactionsLoaded(
        transactions: response.transactions,
        hasMore: response.hasMore,
        currentPage: event.page,
        total: response.total,
        typeFilter: event.typeFilter,
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      ));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactions event,
    Emitter<TransactionsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TransactionsLoaded || !currentState.hasMore) return;
    if (currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final response = await _repository.getTransactions(
        page: nextPage,
        type: currentState.typeFilter,
        dateFrom: currentState.dateFrom,
        dateTo: currentState.dateTo,
      );

      emit(TransactionsLoaded(
        transactions: [
          ...currentState.transactions,
          ...response.transactions,
        ],
        hasMore: response.hasMore,
        currentPage: nextPage,
        total: response.total,
        typeFilter: currentState.typeFilter,
        dateFrom: currentState.dateFrom,
        dateTo: currentState.dateTo,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onCreateTransaction(
    CreateTransaction event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      await _repository.createTransaction(event.params);
      // Reload from first page
      add(const LoadTransactions());
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      await _repository.updateTransaction(event.id, event.params);
      add(const LoadTransactions());
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      await _repository.deleteTransaction(event.id);
      add(const LoadTransactions());
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }
}

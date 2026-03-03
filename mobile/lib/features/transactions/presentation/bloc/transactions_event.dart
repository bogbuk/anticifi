import 'package:equatable/equatable.dart';

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionsEvent {
  final int page;
  final String? typeFilter;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const LoadTransactions({
    this.page = 1,
    this.typeFilter,
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props => [page, typeFilter, dateFrom, dateTo];
}

class LoadMoreTransactions extends TransactionsEvent {
  const LoadMoreTransactions();
}

class CreateTransaction extends TransactionsEvent {
  final Map<String, dynamic> params;

  const CreateTransaction(this.params);

  @override
  List<Object?> get props => [params];
}

class UpdateTransaction extends TransactionsEvent {
  final String id;
  final Map<String, dynamic> params;

  const UpdateTransaction(this.id, this.params);

  @override
  List<Object?> get props => [id, params];
}

class DeleteTransaction extends TransactionsEvent {
  final String id;

  const DeleteTransaction(this.id);

  @override
  List<Object?> get props => [id];
}

class SuggestCategory extends TransactionsEvent {
  final String description;
  final String? type;
  final double? amount;

  const SuggestCategory({
    required this.description,
    this.type,
    this.amount,
  });

  @override
  List<Object?> get props => [description, type, amount];
}

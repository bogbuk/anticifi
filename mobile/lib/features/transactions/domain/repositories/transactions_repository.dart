import '../entities/transaction_entity.dart';

class TransactionsResponse {
  final List<TransactionEntity> transactions;
  final int total;
  final bool hasMore;

  const TransactionsResponse({
    required this.transactions,
    required this.total,
    required this.hasMore,
  });
}

abstract class TransactionsRepository {
  Future<TransactionsResponse> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
    DateTime? dateFrom,
    DateTime? dateTo,
  });
  Future<TransactionEntity> getTransaction(String id);
  Future<TransactionEntity> createTransaction(Map<String, dynamic> params);
  Future<TransactionEntity> updateTransaction(
      String id, Map<String, dynamic> params);
  Future<void> deleteTransaction(String id);
}

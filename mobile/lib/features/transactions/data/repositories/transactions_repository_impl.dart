import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../datasources/transactions_remote_datasource.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  final TransactionsRemoteDataSource _remoteDataSource;

  TransactionsRepositoryImpl(this._remoteDataSource);

  @override
  Future<TransactionsResponse> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    return await _remoteDataSource.getTransactions(
      page: page,
      limit: limit,
      type: type,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }

  @override
  Future<TransactionEntity> getTransaction(String id) async {
    return await _remoteDataSource.getTransaction(id);
  }

  @override
  Future<TransactionEntity> createTransaction(
      Map<String, dynamic> params) async {
    return await _remoteDataSource.createTransaction(params);
  }

  @override
  Future<TransactionEntity> updateTransaction(
      String id, Map<String, dynamic> params) async {
    return await _remoteDataSource.updateTransaction(id, params);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _remoteDataSource.deleteTransaction(id);
  }
}

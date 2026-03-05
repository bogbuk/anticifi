import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../datasources/transactions_remote_datasource.dart';
import '../models/transaction_model.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  final TransactionsRemoteDataSource _remoteDataSource;
  final TransactionLocalDatasource _localDataSource;
  final ConnectivityService _connectivityService;
  final SyncService _syncService;

  TransactionsRepositoryImpl(
    this._remoteDataSource, {
    required TransactionLocalDatasource localDataSource,
    required ConnectivityService connectivityService,
    required SyncService syncService,
  })  : _localDataSource = localDataSource,
        _connectivityService = connectivityService,
        _syncService = syncService;

  @override
  Future<TransactionsResponse> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final online = await _connectivityService.isOnline();

    if (online) {
      try {
        final response = await _remoteDataSource.getTransactions(
          page: page,
          limit: limit,
          type: type,
          dateFrom: dateFrom,
          dateTo: dateTo,
        );
        if (page == 1) {
          final models = response.transactions
              .map((e) => e is TransactionModel
                  ? e
                  : TransactionModel(
                      id: e.id,
                      accountId: e.accountId,
                      amount: e.amount,
                      type: e.type,
                      description: e.description,
                      categoryId: e.categoryId,
                      categoryName: e.categoryName,
                      date: e.date,
                    ))
              .toList();
          await _localDataSource.saveAll(models);
        }
        return response;
      } catch (_) {
        return _getFromLocal();
      }
    }

    return _getFromLocal();
  }

  Future<TransactionsResponse> _getFromLocal() async {
    final local = await _localDataSource.getAll();
    return TransactionsResponse(
      transactions: local,
      total: local.length,
      hasMore: false,
    );
  }

  @override
  Future<TransactionEntity> getTransaction(String id) async {
    final online = await _connectivityService.isOnline();

    if (online) {
      try {
        final result = await _remoteDataSource.getTransaction(id);
        await _localDataSource.save(result);
        return result;
      } catch (_) {
        final local = await _localDataSource.getById(id);
        if (local != null) return local;
        rethrow;
      }
    }

    final local = await _localDataSource.getById(id);
    if (local != null) return local;
    throw Exception('Transaction not found offline');
  }

  @override
  Future<TransactionEntity> createTransaction(
      Map<String, dynamic> params) async {
    final online = await _connectivityService.isOnline();

    if (online) {
      try {
        final result = await _remoteDataSource.createTransaction(params);
        await _localDataSource.save(result);
        return result;
      } catch (_) {
        return _createLocally(params);
      }
    }

    return _createLocally(params);
  }

  Future<TransactionEntity> _createLocally(
      Map<String, dynamic> params) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final model = TransactionModel(
      id: params['id'] as String? ?? tempId,
      accountId: params['accountId'] as String? ?? '',
      amount: (params['amount'] as num?)?.toDouble() ?? 0.0,
      type: params['type'] as String? ?? 'expense',
      description: params['description'] as String?,
      categoryId: params['categoryId'] as String?,
      categoryName: params['categoryName'] as String?,
      date: params['date'] != null
          ? DateTime.parse(params['date'] as String)
          : DateTime.now(),
    );
    await _localDataSource.save(model);
    await _syncService.enqueueAction(
      entityType: 'transactions',
      entityId: model.id,
      action: 'create',
      payload: params,
    );
    return model;
  }

  @override
  Future<TransactionEntity> updateTransaction(
      String id, Map<String, dynamic> params) async {
    final online = await _connectivityService.isOnline();

    if (online) {
      try {
        final result = await _remoteDataSource.updateTransaction(id, params);
        await _localDataSource.save(result);
        return result;
      } catch (_) {
        return _updateLocally(id, params);
      }
    }

    return _updateLocally(id, params);
  }

  Future<TransactionEntity> _updateLocally(
      String id, Map<String, dynamic> params) async {
    final existing = await _localDataSource.getById(id);
    final model = TransactionModel(
      id: id,
      accountId: params['accountId'] as String? ?? existing?.accountId ?? '',
      amount: (params['amount'] as num?)?.toDouble() ?? existing?.amount ?? 0.0,
      type: params['type'] as String? ?? existing?.type ?? 'expense',
      description:
          params['description'] as String? ?? existing?.description,
      categoryId:
          params['categoryId'] as String? ?? existing?.categoryId,
      categoryName:
          params['categoryName'] as String? ?? existing?.categoryName,
      date: params['date'] != null
          ? DateTime.parse(params['date'] as String)
          : existing?.date ?? DateTime.now(),
    );
    await _localDataSource.save(model);
    await _syncService.enqueueAction(
      entityType: 'transactions',
      entityId: id,
      action: 'update',
      payload: params,
    );
    return model;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final online = await _connectivityService.isOnline();

    if (online) {
      try {
        await _remoteDataSource.deleteTransaction(id);
        await _localDataSource.delete(id);
        return;
      } catch (_) {
        // fall through to offline delete
      }
    }

    await _localDataSource.delete(id);
    await _syncService.enqueueAction(
      entityType: 'transactions',
      entityId: id,
      action: 'delete',
    );
  }

  @override
  Future<List<Map<String, dynamic>>> suggestCategory({
    required String description,
    String? type,
    double? amount,
  }) async {
    return await _remoteDataSource.suggestCategory(
      description: description,
      type: type,
      amount: amount,
    );
  }
}

import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/accounts_repository.dart';
import '../datasources/account_local_datasource.dart';
import '../datasources/accounts_remote_datasource.dart';
import '../models/account_model.dart';

class AccountsRepositoryImpl implements AccountsRepository {
  final AccountsRemoteDataSource _remoteDataSource;
  final AccountLocalDatasource _localDataSource;
  final ConnectivityService _connectivityService;
  final SyncService _syncService;

  AccountsRepositoryImpl(
    this._remoteDataSource, {
    required AccountLocalDatasource localDataSource,
    required ConnectivityService connectivityService,
    required SyncService syncService,
  })  : _localDataSource = localDataSource,
        _connectivityService = connectivityService,
        _syncService = syncService;

  @override
  Future<List<AccountEntity>> getAccounts() async {
    final online = await _connectivityService.isOnline();

    if (online) {
      try {
        final results = await _remoteDataSource.getAccounts();
        await _localDataSource.saveAll(results);
        return results;
      } catch (_) {
        return await _localDataSource.getAll();
      }
    }

    return await _localDataSource.getAll();
  }

  @override
  Future<AccountEntity> getAccount(String id) async {
    final online = await _connectivityService.isOnline();

    if (online) {
      try {
        final result = await _remoteDataSource.getAccount(id);
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
    throw Exception('Account not found offline');
  }

  @override
  Future<AccountEntity> createAccount(Map<String, dynamic> params) async {
    final online = await _connectivityService.isOnline();

    if (online) {
      try {
        final result = await _remoteDataSource.createAccount(params);
        await _localDataSource.save(result);
        return result;
      } catch (_) {
        return _createLocally(params);
      }
    }

    return _createLocally(params);
  }

  Future<AccountEntity> _createLocally(Map<String, dynamic> params) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final model = AccountModel(
      id: params['id'] as String? ?? tempId,
      userId: params['userId'] as String? ?? '',
      name: params['name'] as String? ?? '',
      type: params['type'] as String? ?? 'checking',
      bank: params['bank'] as String?,
      currency: params['currency'] as String? ?? 'USD',
      balance: (params['balance'] as num?)?.toDouble() ?? 0.0,
      initialBalance: (params['initialBalance'] as num?)?.toDouble() ?? 0.0,
      connectionType: params['connectionType'] as String? ?? 'manual',
      plaidAccountId: params['plaidAccountId'] as String?,
      mask: params['mask'] as String?,
      institutionName: params['institutionName'] as String?,
    );
    await _localDataSource.save(model);
    await _syncService.enqueueAction(
      entityType: 'accounts',
      entityId: model.id,
      action: 'create',
      payload: params,
    );
    return model;
  }

  @override
  Future<AccountEntity> updateAccount(
      String id, Map<String, dynamic> params) async {
    final online = await _connectivityService.isOnline();

    if (online) {
      try {
        final result = await _remoteDataSource.updateAccount(id, params);
        await _localDataSource.save(result);
        return result;
      } catch (_) {
        return _updateLocally(id, params);
      }
    }

    return _updateLocally(id, params);
  }

  Future<AccountEntity> _updateLocally(
      String id, Map<String, dynamic> params) async {
    final existing = await _localDataSource.getById(id);
    final model = AccountModel(
      id: id,
      userId: params['userId'] as String? ?? existing?.userId ?? '',
      name: params['name'] as String? ?? existing?.name ?? '',
      type: params['type'] as String? ?? existing?.type ?? 'checking',
      bank: params['bank'] as String? ?? existing?.bank,
      currency: params['currency'] as String? ?? existing?.currency ?? 'USD',
      balance:
          (params['balance'] as num?)?.toDouble() ?? existing?.balance ?? 0.0,
      initialBalance: (params['initialBalance'] as num?)?.toDouble() ??
          existing?.initialBalance ??
          0.0,
      connectionType: params['connectionType'] as String? ??
          existing?.connectionType ??
          'manual',
    );
    await _localDataSource.save(model);
    await _syncService.enqueueAction(
      entityType: 'accounts',
      entityId: id,
      action: 'update',
      payload: params,
    );
    return model;
  }

  @override
  Future<void> deleteAccount(String id) async {
    final online = await _connectivityService.isOnline();

    if (online) {
      try {
        await _remoteDataSource.deleteAccount(id);
        await _localDataSource.delete(id);
        return;
      } catch (_) {
        // fall through to offline delete
      }
    }

    await _localDataSource.delete(id);
    await _syncService.enqueueAction(
      entityType: 'accounts',
      entityId: id,
      action: 'delete',
    );
  }
}

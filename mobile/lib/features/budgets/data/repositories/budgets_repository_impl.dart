import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budgets_repository.dart';
import '../datasources/budget_local_datasource.dart';
import '../datasources/budgets_remote_datasource.dart';
import '../models/budget_model.dart';

class BudgetsRepositoryImpl implements BudgetsRepository {
  final BudgetsRemoteDataSource _remoteDataSource;
  final BudgetLocalDatasource _localDataSource;
  final ConnectivityService _connectivityService;
  final SyncService _syncService;

  BudgetsRepositoryImpl(
    this._remoteDataSource, {
    required BudgetLocalDatasource localDataSource,
    required ConnectivityService connectivityService,
    required SyncService syncService,
  })  : _localDataSource = localDataSource,
        _connectivityService = connectivityService,
        _syncService = syncService;

  @override
  Future<List<BudgetEntity>> getBudgets() async {
    final online = await _connectivityService.isOnline();

    if (online) {
      try {
        final results = await _remoteDataSource.getBudgets();
        await _localDataSource.saveAll(results);
        return results;
      } catch (_) {
        return await _localDataSource.getAll();
      }
    }

    return await _localDataSource.getAll();
  }

  @override
  Future<BudgetEntity> getBudget(String id) async {
    final online = await _connectivityService.isOnline();

    if (online) {
      try {
        final result = await _remoteDataSource.getBudget(id);
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
    throw Exception('Budget not found offline');
  }

  @override
  Future<BudgetEntity> createBudget(Map<String, dynamic> params) async {
    final online = await _connectivityService.isOnline();

    if (online) {
      try {
        final result = await _remoteDataSource.createBudget(params);
        await _localDataSource.save(result);
        return result;
      } catch (_) {
        return _createLocally(params);
      }
    }

    return _createLocally(params);
  }

  Future<BudgetEntity> _createLocally(Map<String, dynamic> params) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final model = BudgetModel(
      id: params['id'] as String? ?? tempId,
      name: params['name'] as String? ?? '',
      amount: (params['amount'] as num?)?.toDouble() ?? 0.0,
      spentAmount: 0.0,
      period: params['period'] as String? ?? 'monthly',
      categoryId: params['categoryId'] as String?,
      startDate: params['startDate'] != null
          ? DateTime.parse(params['startDate'] as String)
          : DateTime.now(),
      endDate: params['endDate'] != null
          ? DateTime.parse(params['endDate'] as String)
          : null,
      isActive: params['isActive'] as bool? ?? true,
    );
    await _localDataSource.save(model);
    await _syncService.enqueueAction(
      entityType: 'budgets',
      entityId: model.id,
      action: 'create',
      payload: params,
    );
    return model;
  }

  @override
  Future<BudgetEntity> updateBudget(
      String id, Map<String, dynamic> params) async {
    final online = await _connectivityService.isOnline();

    if (online) {
      try {
        final result = await _remoteDataSource.updateBudget(id, params);
        await _localDataSource.save(result);
        return result;
      } catch (_) {
        return _updateLocally(id, params);
      }
    }

    return _updateLocally(id, params);
  }

  Future<BudgetEntity> _updateLocally(
      String id, Map<String, dynamic> params) async {
    final existing = await _localDataSource.getById(id);
    final model = BudgetModel(
      id: id,
      name: params['name'] as String? ?? existing?.name ?? '',
      amount:
          (params['amount'] as num?)?.toDouble() ?? existing?.amount ?? 0.0,
      spentAmount: existing?.spentAmount ?? 0.0,
      period: params['period'] as String? ?? existing?.period ?? 'monthly',
      categoryId: params['categoryId'] as String? ?? existing?.categoryId,
      categoryName: existing?.categoryName,
      categoryIcon: existing?.categoryIcon,
      categoryColor: existing?.categoryColor,
      startDate: params['startDate'] != null
          ? DateTime.parse(params['startDate'] as String)
          : existing?.startDate ?? DateTime.now(),
      endDate: params['endDate'] != null
          ? DateTime.parse(params['endDate'] as String)
          : existing?.endDate,
      isActive: params['isActive'] as bool? ?? existing?.isActive ?? true,
    );
    await _localDataSource.save(model);
    await _syncService.enqueueAction(
      entityType: 'budgets',
      entityId: id,
      action: 'update',
      payload: params,
    );
    return model;
  }

  @override
  Future<void> deleteBudget(String id) async {
    final online = await _connectivityService.isOnline();

    if (online) {
      try {
        await _remoteDataSource.deleteBudget(id);
        await _localDataSource.delete(id);
        return;
      } catch (_) {
        // fall through to offline delete
      }
    }

    await _localDataSource.delete(id);
    await _syncService.enqueueAction(
      entityType: 'budgets',
      entityId: id,
      action: 'delete',
    );
  }

  @override
  Future<List<BudgetEntity>> getBudgetsSummary() async {
    final online = await _connectivityService.isOnline();

    if (online) {
      try {
        final results = await _remoteDataSource.getBudgetsSummary();
        await _localDataSource.saveAll(results);
        return results;
      } catch (_) {
        return await _localDataSource.getAll();
      }
    }

    return await _localDataSource.getAll();
  }
}

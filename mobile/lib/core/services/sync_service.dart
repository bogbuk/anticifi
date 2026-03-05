import 'dart:async';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../database/local_database.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import 'connectivity_service.dart';

class SyncService {
  final LocalDatabase _localDatabase;
  final DioClient _dioClient;
  final ConnectivityService _connectivityService;
  StreamSubscription<bool>? _subscription;
  bool _isSyncing = false;

  SyncService({
    required LocalDatabase localDatabase,
    required DioClient dioClient,
    required ConnectivityService connectivityService,
  })  : _localDatabase = localDatabase,
        _dioClient = dioClient,
        _connectivityService = connectivityService;

  void startListening() {
    _subscription = _connectivityService.onStatusChange.listen((online) {
      if (online) {
        processQueue();
      }
    });
  }

  Future<void> enqueueAction({
    required String entityType,
    required String entityId,
    required String action,
    Map<String, dynamic>? payload,
  }) async {
    final db = await _localDatabase.database;
    await db.insert('sync_queue', {
      'entity_type': entityType,
      'entity_id': entityId,
      'action': action,
      'payload': payload != null ? jsonEncode(payload) : null,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> processQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final online = await _connectivityService.isOnline();
      if (!online) return;

      final db = await _localDatabase.database;
      final items = await db.query('sync_queue', orderBy: 'id ASC');

      for (final item in items) {
        try {
          await _processSyncItem(item);
          await db.delete(
            'sync_queue',
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } catch (_) {
          break;
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _processSyncItem(Map<String, dynamic> item) async {
    final entityType = item['entity_type'] as String;
    final entityId = item['entity_id'] as String;
    final action = item['action'] as String;
    final payloadStr = item['payload'] as String?;
    final payload = payloadStr != null
        ? jsonDecode(payloadStr) as Map<String, dynamic>
        : null;

    final endpoint = _getEndpoint(entityType);
    if (endpoint == null) return;

    switch (action) {
      case 'create':
        await _dioClient.dio.post(endpoint, data: payload);
        break;
      case 'update':
        await _dioClient.dio.patch('$endpoint/$entityId', data: payload);
        break;
      case 'delete':
        await _dioClient.dio.delete('$endpoint/$entityId');
        break;
    }
  }

  String? _getEndpoint(String entityType) {
    switch (entityType) {
      case 'accounts':
        return ApiEndpoints.accounts;
      case 'transactions':
        return ApiEndpoints.transactions;
      case 'budgets':
        return ApiEndpoints.budgets;
      default:
        return null;
    }
  }

  Future<void> syncAll() async {
    await processQueue();

    final online = await _connectivityService.isOnline();
    if (!online) return;

    final db = await _localDatabase.database;
    final now = DateTime.now().toIso8601String();

    for (final entityType in ['accounts', 'transactions', 'budgets']) {
      try {
        await _pullRemoteData(db, entityType);
        await db.insert(
          'sync_metadata',
          {'entity_type': entityType, 'last_synced_at': now},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (_) {
        // skip failed entity sync
      }
    }
  }

  Future<void> _pullRemoteData(Database db, String entityType) async {
    switch (entityType) {
      case 'accounts':
        final response = await _dioClient.dio.get(ApiEndpoints.accounts);
        final list = response.data as List<dynamic>;
        await db.delete('accounts');
        for (final item in list) {
          final map = item as Map<String, dynamic>;
          await db.insert('accounts', _mapAccountToRow(map),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
        break;
      case 'transactions':
        final response = await _dioClient.dio.get(
          ApiEndpoints.transactions,
          queryParameters: {'page': 1, 'limit': 200},
        );
        final data = response.data as Map<String, dynamic>;
        final list = (data['data'] as List<dynamic>?) ?? [];
        await db.delete('transactions');
        for (final item in list) {
          final map = item as Map<String, dynamic>;
          await db.insert('transactions', _mapTransactionToRow(map),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
        break;
      case 'budgets':
        final response = await _dioClient.dio.get(ApiEndpoints.budgets);
        final data = response.data as Map<String, dynamic>;
        final list = (data['data'] as List<dynamic>?) ?? [];
        await db.delete('budgets');
        for (final item in list) {
          final map = item as Map<String, dynamic>;
          await db.insert('budgets', _mapBudgetToRow(map),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
        break;
    }
  }

  Map<String, dynamic> _mapAccountToRow(Map<String, dynamic> json) {
    return {
      'id': json['id'],
      'user_id': json['userId'] ?? '',
      'name': json['name'],
      'type': json['type'],
      'bank': json['bank'],
      'currency': json['currency'] ?? 'USD',
      'balance': _toDouble(json['balance']),
      'initial_balance': _toDouble(json['initialBalance']),
      'connection_type': json['connectionType'] ?? 'manual',
      'plaid_account_id': json['plaidAccountId'],
      'mask': json['mask'],
      'institution_name': json['institutionName'] ?? json['bank'],
    };
  }

  Map<String, dynamic> _mapTransactionToRow(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    return {
      'id': json['id'],
      'account_id': json['accountId'] ?? '',
      'amount': _toDouble(json['amount']),
      'type': json['type'],
      'description': json['description'],
      'category_id':
          json['categoryId'] ?? category?['id'],
      'category_name':
          json['categoryName'] ?? category?['name'],
      'date': json['date'],
    };
  }

  Map<String, dynamic> _mapBudgetToRow(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    return {
      'id': json['id'],
      'name': json['name'],
      'amount': _toDouble(json['amount']),
      'spent_amount': _toDouble(json['spent']),
      'period': json['period'],
      'category_id': json['categoryId'] ?? category?['id'],
      'category_name': json['categoryName'] ?? category?['name'],
      'category_icon': json['categoryIcon'] ?? category?['icon'],
      'category_color': json['categoryColor'] ?? category?['color'],
      'start_date': json['startDate'],
      'end_date': json['endDate'],
      'is_active': (json['isActive'] ?? true) ? 1 : 0,
    };
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  void dispose() {
    _subscription?.cancel();
  }
}

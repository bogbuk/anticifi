import 'package:sqflite/sqflite.dart';

import '../../../../core/database/local_database.dart';
import '../models/account_model.dart';

class AccountLocalDatasource {
  final LocalDatabase _localDatabase;

  AccountLocalDatasource({required LocalDatabase localDatabase})
      : _localDatabase = localDatabase;

  Future<List<AccountModel>> getAll() async {
    final db = await _localDatabase.database;
    final rows = await db.query('accounts');
    return rows.map(_fromRow).toList();
  }

  Future<AccountModel?> getById(String id) async {
    final db = await _localDatabase.database;
    final rows = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  Future<void> save(AccountModel model) async {
    final db = await _localDatabase.database;
    await db.insert(
      'accounts',
      _toRow(model),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveAll(List<AccountModel> models) async {
    final db = await _localDatabase.database;
    final batch = db.batch();
    for (final model in models) {
      batch.insert(
        'accounts',
        _toRow(model),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> delete(String id) async {
    final db = await _localDatabase.database;
    await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear() async {
    final db = await _localDatabase.database;
    await db.delete('accounts');
  }

  AccountModel _fromRow(Map<String, dynamic> row) {
    return AccountModel(
      id: row['id'] as String,
      userId: row['user_id'] as String? ?? '',
      name: row['name'] as String,
      type: row['type'] as String,
      bank: row['bank'] as String?,
      currency: row['currency'] as String? ?? 'USD',
      balance: (row['balance'] as num?)?.toDouble() ?? 0.0,
      initialBalance: (row['initial_balance'] as num?)?.toDouble() ?? 0.0,
      connectionType: row['connection_type'] as String? ?? 'manual',
      plaidAccountId: row['plaid_account_id'] as String?,
      mask: row['mask'] as String?,
      institutionName: row['institution_name'] as String?,
    );
  }

  Map<String, dynamic> _toRow(AccountModel model) {
    return {
      'id': model.id,
      'user_id': model.userId,
      'name': model.name,
      'type': model.type,
      'bank': model.bank,
      'currency': model.currency,
      'balance': model.balance,
      'initial_balance': model.initialBalance,
      'connection_type': model.connectionType,
      'plaid_account_id': model.plaidAccountId,
      'mask': model.mask,
      'institution_name': model.institutionName,
    };
  }
}

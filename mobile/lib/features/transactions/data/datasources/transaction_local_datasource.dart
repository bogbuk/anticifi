import 'package:sqflite/sqflite.dart';

import '../../../../core/database/local_database.dart';
import '../models/transaction_model.dart';

class TransactionLocalDatasource {
  final LocalDatabase _localDatabase;

  TransactionLocalDatasource({required LocalDatabase localDatabase})
      : _localDatabase = localDatabase;

  Future<List<TransactionModel>> getAll() async {
    final db = await _localDatabase.database;
    final rows = await db.query('transactions', orderBy: 'date DESC');
    return rows.map(_fromRow).toList();
  }

  Future<TransactionModel?> getById(String id) async {
    final db = await _localDatabase.database;
    final rows = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  Future<void> save(TransactionModel model) async {
    final db = await _localDatabase.database;
    await db.insert(
      'transactions',
      _toRow(model),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveAll(List<TransactionModel> models) async {
    final db = await _localDatabase.database;
    final batch = db.batch();
    for (final model in models) {
      batch.insert(
        'transactions',
        _toRow(model),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> delete(String id) async {
    final db = await _localDatabase.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear() async {
    final db = await _localDatabase.database;
    await db.delete('transactions');
  }

  TransactionModel _fromRow(Map<String, dynamic> row) {
    return TransactionModel(
      id: row['id'] as String,
      accountId: row['account_id'] as String? ?? '',
      amount: (row['amount'] as num?)?.toDouble() ?? 0.0,
      type: row['type'] as String,
      description: row['description'] as String?,
      categoryId: row['category_id'] as String?,
      categoryName: row['category_name'] as String?,
      date: DateTime.parse(row['date'] as String),
    );
  }

  Map<String, dynamic> _toRow(TransactionModel model) {
    return {
      'id': model.id,
      'account_id': model.accountId,
      'amount': model.amount,
      'type': model.type,
      'description': model.description,
      'category_id': model.categoryId,
      'category_name': model.categoryName,
      'date': model.date.toIso8601String(),
    };
  }
}

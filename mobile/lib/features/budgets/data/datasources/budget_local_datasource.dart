import 'package:sqflite/sqflite.dart';

import '../../../../core/database/local_database.dart';
import '../models/budget_model.dart';

class BudgetLocalDatasource {
  final LocalDatabase _localDatabase;

  BudgetLocalDatasource({required LocalDatabase localDatabase})
      : _localDatabase = localDatabase;

  Future<List<BudgetModel>> getAll() async {
    final db = await _localDatabase.database;
    final rows = await db.query('budgets');
    return rows.map(_fromRow).toList();
  }

  Future<BudgetModel?> getById(String id) async {
    final db = await _localDatabase.database;
    final rows = await db.query(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  Future<void> save(BudgetModel model) async {
    final db = await _localDatabase.database;
    await db.insert(
      'budgets',
      _toRow(model),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveAll(List<BudgetModel> models) async {
    final db = await _localDatabase.database;
    final batch = db.batch();
    for (final model in models) {
      batch.insert(
        'budgets',
        _toRow(model),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> delete(String id) async {
    final db = await _localDatabase.database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear() async {
    final db = await _localDatabase.database;
    await db.delete('budgets');
  }

  BudgetModel _fromRow(Map<String, dynamic> row) {
    return BudgetModel(
      id: row['id'] as String,
      name: row['name'] as String,
      amount: (row['amount'] as num?)?.toDouble() ?? 0.0,
      spentAmount: (row['spent_amount'] as num?)?.toDouble() ?? 0.0,
      period: row['period'] as String,
      categoryId: row['category_id'] as String?,
      categoryName: row['category_name'] as String?,
      categoryIcon: row['category_icon'] as String?,
      categoryColor: row['category_color'] as String?,
      startDate: DateTime.parse(row['start_date'] as String),
      endDate: row['end_date'] != null
          ? DateTime.parse(row['end_date'] as String)
          : null,
      isActive: (row['is_active'] as int?) == 1,
    );
  }

  Map<String, dynamic> _toRow(BudgetModel model) {
    return {
      'id': model.id,
      'name': model.name,
      'amount': model.amount,
      'spent_amount': model.spentAmount,
      'period': model.period,
      'category_id': model.categoryId,
      'category_name': model.categoryName,
      'category_icon': model.categoryIcon,
      'category_color': model.categoryColor,
      'start_date': model.startDate.toIso8601String(),
      'end_date': model.endDate?.toIso8601String(),
      'is_active': model.isActive ? 1 : 0,
    };
  }
}

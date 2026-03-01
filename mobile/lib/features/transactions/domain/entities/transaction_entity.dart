import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String accountId;
  final double amount;
  final String type; // income, expense
  final String? description;
  final String? categoryId;
  final String? categoryName;
  final DateTime date;

  const TransactionEntity({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.type,
    this.description,
    this.categoryId,
    this.categoryName,
    required this.date,
  });

  @override
  List<Object?> get props => [
        id,
        accountId,
        amount,
        type,
        description,
        categoryId,
        categoryName,
        date,
      ];
}

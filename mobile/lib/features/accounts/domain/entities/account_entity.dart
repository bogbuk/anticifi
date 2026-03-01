import 'package:equatable/equatable.dart';

class AccountEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String type; // checking, savings, credit, cash
  final String? bank;
  final String currency;
  final double balance;
  final double initialBalance;

  const AccountEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.bank,
    required this.currency,
    required this.balance,
    required this.initialBalance,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        type,
        bank,
        currency,
        balance,
        initialBalance,
      ];
}

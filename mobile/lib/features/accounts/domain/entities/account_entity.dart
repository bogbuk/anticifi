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
  final String connectionType; // manual, plaid
  final String? plaidAccountId;
  final String? mask;
  final String? institutionName;

  const AccountEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.bank,
    required this.currency,
    required this.balance,
    required this.initialBalance,
    this.connectionType = 'manual',
    this.plaidAccountId,
    this.mask,
    this.institutionName,
  });

  bool get isLinked => connectionType == 'plaid';

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
        connectionType,
        plaidAccountId,
        mask,
        institutionName,
      ];
}

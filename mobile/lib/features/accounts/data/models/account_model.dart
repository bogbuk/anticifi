import '../../domain/entities/account_entity.dart';

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

class AccountModel extends AccountEntity {
  const AccountModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.type,
    super.bank,
    required super.currency,
    required super.balance,
    required super.initialBalance,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String,
      type: json['type'] as String,
      bank: json['bank'] as String?,
      currency: json['currency'] as String? ?? 'USD',
      balance: _toDouble(json['balance']),
      initialBalance: _toDouble(json['initialBalance']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type,
      'bank': bank,
      'currency': currency,
      'balance': balance,
      'initialBalance': initialBalance,
    };
  }
}

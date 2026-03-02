import 'package:equatable/equatable.dart';

class DebtPaymentEntity extends Equatable {
  final String id;
  final String debtId;
  final double amount;
  final DateTime paymentDate;
  final String? notes;

  const DebtPaymentEntity({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.paymentDate,
    this.notes,
  });

  @override
  List<Object?> get props => [id, debtId, amount, paymentDate, notes];
}

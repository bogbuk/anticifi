import 'package:equatable/equatable.dart';

class DebtSummaryEntity extends Equatable {
  final int totalDebts;
  final int activeDebts;
  final int paidOffDebts;
  final double totalOriginalAmount;
  final double totalCurrentBalance;
  final double totalPaid;
  final double overallProgress;

  const DebtSummaryEntity({
    required this.totalDebts,
    required this.activeDebts,
    required this.paidOffDebts,
    required this.totalOriginalAmount,
    required this.totalCurrentBalance,
    required this.totalPaid,
    required this.overallProgress,
  });

  @override
  List<Object?> get props => [
        totalDebts, activeDebts, paidOffDebts,
        totalOriginalAmount, totalCurrentBalance, totalPaid, overallProgress,
      ];
}

import 'package:equatable/equatable.dart';

class DebtEntity extends Equatable {
  final String id;
  final String name;
  final String type;
  final double originalAmount;
  final double currentBalance;
  final double interestRate;
  final double minimumPayment;
  final int? dueDay;
  final DateTime startDate;
  final DateTime? expectedPayoffDate;
  final String? creditorName;
  final String? notes;
  final bool isActive;
  final bool isPaidOff;
  final double totalPaid;
  final double progressPercent;

  const DebtEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.originalAmount,
    required this.currentBalance,
    required this.interestRate,
    required this.minimumPayment,
    this.dueDay,
    required this.startDate,
    this.expectedPayoffDate,
    this.creditorName,
    this.notes,
    required this.isActive,
    required this.isPaidOff,
    required this.totalPaid,
    required this.progressPercent,
  });

  double get remainingAmount => currentBalance;

  String get typeLabel {
    switch (type) {
      case 'credit_card': return 'Credit Card';
      case 'personal_loan': return 'Personal Loan';
      case 'mortgage': return 'Mortgage';
      case 'auto_loan': return 'Auto Loan';
      case 'student_loan': return 'Student Loan';
      case 'personal': return 'Personal';
      default: return 'Other';
    }
  }

  @override
  List<Object?> get props => [
        id, name, type, originalAmount, currentBalance, interestRate,
        minimumPayment, dueDay, startDate, expectedPayoffDate,
        creditorName, notes, isActive, isPaidOff, totalPaid, progressPercent,
      ];
}

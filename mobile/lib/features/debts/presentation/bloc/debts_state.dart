import 'package:equatable/equatable.dart';

import '../../domain/entities/debt_entity.dart';
import '../../domain/entities/debt_payment_entity.dart';
import '../../domain/entities/debt_summary_entity.dart';

abstract class DebtsState extends Equatable {
  const DebtsState();

  @override
  List<Object?> get props => [];
}

class DebtsInitial extends DebtsState {
  const DebtsInitial();
}

class DebtsLoading extends DebtsState {
  const DebtsLoading();
}

class DebtsLoaded extends DebtsState {
  final List<DebtEntity> debts;
  final DebtSummaryEntity summary;

  const DebtsLoaded(this.debts, this.summary);

  @override
  List<Object?> get props => [debts, summary];
}

class DebtDetailLoaded extends DebtsState {
  final DebtEntity debt;
  final List<DebtPaymentEntity> payments;

  const DebtDetailLoaded(this.debt, this.payments);

  @override
  List<Object?> get props => [debt, payments];
}

class DebtsError extends DebtsState {
  final String message;

  const DebtsError(this.message);

  @override
  List<Object?> get props => [message];
}

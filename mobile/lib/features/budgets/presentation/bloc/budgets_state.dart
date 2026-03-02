import 'package:equatable/equatable.dart';

import '../../domain/entities/budget_entity.dart';

abstract class BudgetsState extends Equatable {
  const BudgetsState();

  @override
  List<Object?> get props => [];
}

class BudgetsInitial extends BudgetsState {
  const BudgetsInitial();
}

class BudgetsLoading extends BudgetsState {
  const BudgetsLoading();
}

class BudgetsLoaded extends BudgetsState {
  final List<BudgetEntity> budgets;

  const BudgetsLoaded(this.budgets);

  @override
  List<Object?> get props => [budgets];
}

class BudgetsError extends BudgetsState {
  final String message;

  const BudgetsError(this.message);

  @override
  List<Object?> get props => [message];
}

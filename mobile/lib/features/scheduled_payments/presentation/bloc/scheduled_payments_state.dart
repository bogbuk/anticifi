import 'package:equatable/equatable.dart';

import '../../domain/entities/scheduled_payment_entity.dart';

abstract class ScheduledPaymentsState extends Equatable {
  const ScheduledPaymentsState();

  @override
  List<Object?> get props => [];
}

class ScheduledPaymentsInitial extends ScheduledPaymentsState {
  const ScheduledPaymentsInitial();
}

class ScheduledPaymentsLoading extends ScheduledPaymentsState {
  const ScheduledPaymentsLoading();
}

class ScheduledPaymentsLoaded extends ScheduledPaymentsState {
  final List<ScheduledPaymentEntity> payments;

  const ScheduledPaymentsLoaded(this.payments);

  @override
  List<Object?> get props => [payments];
}

class ScheduledPaymentsError extends ScheduledPaymentsState {
  final String message;

  const ScheduledPaymentsError(this.message);

  @override
  List<Object?> get props => [message];
}

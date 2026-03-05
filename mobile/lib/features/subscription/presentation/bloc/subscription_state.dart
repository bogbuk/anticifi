import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../domain/entities/subscription_entity.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

class SubscriptionLoaded extends SubscriptionState {
  final SubscriptionEntity subscription;
  final List<Package> packages;

  const SubscriptionLoaded({required this.subscription, this.packages = const []});

  @override
  List<Object?> get props => [subscription, packages];
}

class SubscriptionPurchasing extends SubscriptionState {
  const SubscriptionPurchasing();
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}

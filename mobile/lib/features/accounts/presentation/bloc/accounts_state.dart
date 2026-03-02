import 'package:equatable/equatable.dart';

import '../../domain/entities/account_entity.dart';

abstract class AccountsState extends Equatable {
  const AccountsState();

  @override
  List<Object?> get props => [];
}

class AccountsInitial extends AccountsState {
  const AccountsInitial();
}

class AccountsLoading extends AccountsState {
  const AccountsLoading();
}

class AccountsLoaded extends AccountsState {
  final List<AccountEntity> accounts;

  const AccountsLoaded(this.accounts);

  @override
  List<Object?> get props => [accounts];
}

class AccountsError extends AccountsState {
  final String message;

  const AccountsError(this.message);

  @override
  List<Object?> get props => [message];
}

class PlaidLinkLoading extends AccountsState {
  const PlaidLinkLoading();
}

class PlaidLinkSuccess extends AccountsState {
  final List<AccountEntity> linkedAccounts;

  const PlaidLinkSuccess(this.linkedAccounts);

  @override
  List<Object?> get props => [linkedAccounts];
}

class PlaidLinkError extends AccountsState {
  final String message;

  const PlaidLinkError(this.message);

  @override
  List<Object?> get props => [message];
}

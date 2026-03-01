import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/accounts_repository.dart';
import 'accounts_state.dart';

class AccountsCubit extends Cubit<AccountsState> {
  final AccountsRepository _repository;

  AccountsCubit(this._repository) : super(const AccountsInitial());

  Future<void> loadAccounts() async {
    emit(const AccountsLoading());
    try {
      final accounts = await _repository.getAccounts();
      emit(AccountsLoaded(accounts));
    } catch (e) {
      emit(AccountsError(e.toString()));
    }
  }

  Future<void> createAccount(Map<String, dynamic> params) async {
    try {
      await _repository.createAccount(params);
      await loadAccounts();
    } catch (e) {
      emit(AccountsError(e.toString()));
    }
  }

  Future<void> updateAccount(String id, Map<String, dynamic> params) async {
    try {
      await _repository.updateAccount(id, params);
      await loadAccounts();
    } catch (e) {
      emit(AccountsError(e.toString()));
    }
  }

  Future<void> deleteAccount(String id) async {
    try {
      await _repository.deleteAccount(id);
      await loadAccounts();
    } catch (e) {
      emit(AccountsError(e.toString()));
    }
  }
}

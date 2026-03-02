import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/plaid_remote_datasource.dart';
import '../../data/models/account_model.dart';
import '../../domain/repositories/accounts_repository.dart';
import 'accounts_state.dart';

class AccountsCubit extends Cubit<AccountsState> {
  final AccountsRepository _repository;
  final PlaidRemoteDataSource _plaidDataSource;

  AccountsCubit(this._repository, this._plaidDataSource)
      : super(const AccountsInitial());

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

  Future<String> getLinkToken() async {
    emit(const PlaidLinkLoading());
    try {
      final token = await _plaidDataSource.createLinkToken();
      return token;
    } catch (e) {
      emit(PlaidLinkError(e.toString()));
      rethrow;
    }
  }

  Future<void> exchangePlaidToken({
    required String publicToken,
    String? institutionId,
    String? institutionName,
  }) async {
    emit(const PlaidLinkLoading());
    try {
      final result = await _plaidDataSource.exchangePublicToken(
        publicToken: publicToken,
        institutionId: institutionId,
        institutionName: institutionName,
      );

      final accountsList = result['accounts'] as List<dynamic>? ?? [];
      final linkedAccounts = accountsList
          .map((e) => AccountModel.fromJson(e as Map<String, dynamic>))
          .toList();

      emit(PlaidLinkSuccess(linkedAccounts));
      await loadAccounts();
    } catch (e) {
      emit(PlaidLinkError(e.toString()));
    }
  }

  Future<void> disconnectBank(String itemId) async {
    try {
      await _plaidDataSource.removePlaidItem(itemId);
      await loadAccounts();
    } catch (e) {
      emit(AccountsError(e.toString()));
    }
  }
}

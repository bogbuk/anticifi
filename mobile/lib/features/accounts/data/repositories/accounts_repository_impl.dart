import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/accounts_repository.dart';
import '../datasources/accounts_remote_datasource.dart';

class AccountsRepositoryImpl implements AccountsRepository {
  final AccountsRemoteDataSource _remoteDataSource;

  AccountsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AccountEntity>> getAccounts() async {
    return await _remoteDataSource.getAccounts();
  }

  @override
  Future<AccountEntity> getAccount(String id) async {
    return await _remoteDataSource.getAccount(id);
  }

  @override
  Future<AccountEntity> createAccount(Map<String, dynamic> params) async {
    return await _remoteDataSource.createAccount(params);
  }

  @override
  Future<AccountEntity> updateAccount(
      String id, Map<String, dynamic> params) async {
    return await _remoteDataSource.updateAccount(id, params);
  }

  @override
  Future<void> deleteAccount(String id) async {
    await _remoteDataSource.deleteAccount(id);
  }
}

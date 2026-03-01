import '../entities/account_entity.dart';

abstract class AccountsRepository {
  Future<List<AccountEntity>> getAccounts();
  Future<AccountEntity> getAccount(String id);
  Future<AccountEntity> createAccount(Map<String, dynamic> params);
  Future<AccountEntity> updateAccount(String id, Map<String, dynamic> params);
  Future<void> deleteAccount(String id);
}

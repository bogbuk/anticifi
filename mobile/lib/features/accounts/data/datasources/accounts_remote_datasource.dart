import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/account_model.dart';

class AccountsRemoteDataSource {
  final DioClient dioClient;

  AccountsRemoteDataSource({required this.dioClient});

  Future<List<AccountModel>> getAccounts() async {
    final response = await dioClient.dio.get(ApiEndpoints.accounts);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => AccountModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AccountModel> getAccount(String id) async {
    final response = await dioClient.dio.get('${ApiEndpoints.accounts}/$id');
    final data = response.data as Map<String, dynamic>;
    return AccountModel.fromJson(data);
  }

  Future<AccountModel> createAccount(Map<String, dynamic> params) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.accounts,
      data: params,
    );
    final data = response.data as Map<String, dynamic>;
    return AccountModel.fromJson(data);
  }

  Future<AccountModel> updateAccount(
      String id, Map<String, dynamic> params) async {
    final response = await dioClient.dio.put(
      '${ApiEndpoints.accounts}/$id',
      data: params,
    );
    final data = response.data as Map<String, dynamic>;
    return AccountModel.fromJson(data);
  }

  Future<void> deleteAccount(String id) async {
    await dioClient.dio.delete('${ApiEndpoints.accounts}/$id');
  }
}

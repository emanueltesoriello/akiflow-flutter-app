import 'package:mobile/repository/database_repository.dart';

class AccountsRepository extends DatabaseRepository {
  static const table = 'accounts';

  AccountsRepository({
    required Function(Map<String, dynamic>) fromSql,
  }) : super(tableName: table, fromSql: fromSql);

  @override
  Future<List<Account>> get<Account>() async {
    return await super.get<Account>();
  }

  @override
  Future<void> add<Account>(List<Account> items) async {
    await super.add<Account>(items);
  }

  @override
  Future<void> updateById<Account>(String? id, {required Account data}) async {
    await super.updateById<Account>(id, data: data);
  }

  @override
  Future<List<Account>> unsynced<Account>() async {
    return await super.unsynced<Account>();
  }

  @override
  Future<Account> byId<Account>(String id) async {
    return await super.byId<Account>(id);
  }
}

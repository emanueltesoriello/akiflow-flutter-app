import 'package:mobile/repository/database_repository.dart';

class AccountsRepository extends DatabaseRepository {
  static const table = 'accounts';

  AccountsRepository({
    required Function(Map<String, dynamic>) fromSql,
  }) : super(tableName: table, fromSql: fromSql);
}

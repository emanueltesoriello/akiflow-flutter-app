import 'package:mobile/core/locator.dart';
import 'package:mobile/exceptions/database_exception.dart';
import 'package:mobile/repository/database_repository.dart';
import 'package:mobile/services/database_service.dart';
import 'package:models/account/account.dart';

class AccountsRepository extends DatabaseRepository {
  final DatabaseService _databaseService = locator<DatabaseService>();

  static const table = 'accounts';

  AccountsRepository({
    required Function(Map<String, dynamic>) fromSql,
  }) : super(tableName: table, fromSql: fromSql);

  Future<Account?> getByAccountId(String? accountId) async {
    var result = await _databaseService.database!.query(
      tableName,
      where: 'account_id = ?',
      whereArgs: [accountId],
    );

    if (result.isEmpty) {
      throw DatabaseItemNotFoundException('No item found with accountId $accountId');
    }

    return fromSql(result.first);
  }
}

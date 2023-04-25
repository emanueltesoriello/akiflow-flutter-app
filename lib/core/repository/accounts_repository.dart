import 'package:flutter/foundation.dart';
import 'package:mobile/common/utils/converters_isolate.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/exceptions/database_exception.dart';
import 'package:mobile/core/repository/database_repository.dart';
import 'package:mobile/core/services/database_service.dart';
import 'package:models/account/account.dart';

class AccountsRepository extends DatabaseRepository {
  final DatabaseService _databaseService = locator<DatabaseService>();

  static const table = 'accounts';

  AccountsRepository({
    required Function(Map<String, dynamic>) fromSql,
  }) : super(tableName: table, fromSql: fromSql);

  Future<Account?> getByAccountId(String? accountId) async {
    List<Map<String, Object?>> items;
    try {
      items = await _databaseService.database!.transaction((txn) async {
        return await txn.query(
          tableName,
          where: 'account_id = ?',
          whereArgs: [accountId],
        );
      });
    } catch (e) {
      print('Error retrieving account by accountId: $e');
      return null;
    }

    if (items.isEmpty) {
      throw DatabaseItemNotFoundException('No item found with accountId $accountId');
    }

    return fromSql(items.first);
  }

  Future<List<Account>> getAccounts<Account>() async {
    List<Map<String, Object?>> items;
    try {
      items = await _databaseService.database!.transaction((txn) async {
        return await txn.query(table);
      });
    } catch (e) {
      print('Error retrieving accounts: $e');
      return [];
    }

    List<Account> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }
}

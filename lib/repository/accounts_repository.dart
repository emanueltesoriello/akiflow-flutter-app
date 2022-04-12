import 'package:models/account/account.dart';
import 'package:sqflite/sqflite.dart';

class AccountsRepository {
  static const tableName = 'accounts';

  final Database _database;

  AccountsRepository(this._database);

  Future<List<Account>> all() async {
    List<Map<String, Object?>> result = await _database.query(
      tableName,
      where: 'deleted_at IS NULL',
    );

    return result.map((item) => Account.fromSql(item)).toList();
  }

  Future<void> add(List<Account> tasks) async {
    var batch = _database.batch();

    for (Account task in tasks) {
      batch.insert(tableName, task.toSql());
    }

    var results = await batch.commit();

    print(results);
  }

  // TODO better use `INSERT OR REPLACE INTO` ?
  Future<void> updateById(String? id, {required Account data}) {
    return _database.update(
      tableName,
      data.toSql(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Account>> unsynced() async {
    const withoutRemoteUpdatedAt = 'remote_updated_at IS NULL';
    const deletedAtLaterThanRemoteUpdatedAt = 'deleted_at > remote_updated_at';
    const updatedAtLaterThanRemoteUpdatedAt = 'updated_at > remote_updated_at';

    var result = await _database.query(
      tableName,
      where:
          '$withoutRemoteUpdatedAt OR $deletedAtLaterThanRemoteUpdatedAt OR $updatedAtLaterThanRemoteUpdatedAt',
    );

    return result.map((item) => Account.fromSql(item)).toList();
  }

  Future<Account> byId(String id) async {
    var result = await _database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    return Account.fromSql(result.first);
  }
}

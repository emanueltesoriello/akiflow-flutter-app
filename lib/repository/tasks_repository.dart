import 'package:models/task/task.dart';
import 'package:sqflite/sqflite.dart';

class TasksRepository {
  static const tableName = 'tasks';

  final Database _database;

  TasksRepository(this._database);

  Future<List<Task>> tasks() async {
    List<Map<String, Object?>> result = await _database.query(
      tableName,
      orderBy: 'sorting DESC',
    );

    return result.map((item) => Task.fromSql(item)).toList();
  }

  Future<void> add(List<Task> tasks) async {
    var batch = _database.batch();

    for (Task task in tasks) {
      batch.insert(tableName, task.toSql());
    }

    var results = await batch.commit();

    print(results);
  }

  // TODO better use `INSERT OR REPLACE INTO` ?
  Future<void> updateById(String? id, {required Task data}) {
    return _database.update(
      tableName,
      data.toSql(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Task>> unsynced() async {
    const withoutRemoteUpdatedAt = '`remote_updated_at` IS NULL';
    const deletedAtLaterThanRemoteUpdatedAt =
        '`deleted_at` > `remote_updated_at`';
    const updatedAtLaterThanRemoteUpdatedAt =
        '`updated_at` > `remote_updated_at`';

    var result = await _database.query(
      tableName,
      where:
          '$withoutRemoteUpdatedAt OR $deletedAtLaterThanRemoteUpdatedAt OR $updatedAtLaterThanRemoteUpdatedAt',
    );

    return result.map((item) => Task.fromSql(item)).toList();
  }
}

import 'package:mobile/utils/task_extension.dart';
import 'package:models/task/task.dart';
import 'package:sqflite/sqflite.dart';

class TasksRepository {
  static const tableName = 'tasks';

  final Database _database;

  TasksRepository(this._database);

  Future<List<Task>> inboxTasks() async {
    List<Map<String, Object?>> result = await _database.query(
      tableName,
      where: 'status = ? AND done = 0 AND deletedAt IS NULL',
      whereArgs: [
        TaskStatusType.inbox.id.toString(),
      ],
      orderBy: 'sorting DESC',
    );

    print(result);

    return result.map((item) => Task.fromMap(item)).toList();
  }
}

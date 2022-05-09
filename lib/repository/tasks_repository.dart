import 'package:flutter/foundation.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/repository/database_repository.dart';
import 'package:mobile/services/database_service.dart';
import 'package:mobile/utils/converters_isolate.dart';

class TasksRepository extends DatabaseRepository {
  final DatabaseService _databaseService = locator<DatabaseService>();

  static const table = 'tasks';

  TasksRepository({
    required Function(Map<String, dynamic>) fromSql,
  }) : super(tableName: table, fromSql: fromSql);

  Future<List<Task>> getUndone<Task>() async {
    List<Map<String, Object?>> items =
        await _databaseService.database!.rawQuery("""
SELECT * FROM tasks
WHERE tasks.done IS NULL
OR tasks.done = 0
AND tasks.deleted_at IS NULL
ORDER BY sorting DESC
""");

    List<Task> result = await compute(
        convertToObjList, RawListConvert(items: items, converter: fromSql));

    return result;
  }
}

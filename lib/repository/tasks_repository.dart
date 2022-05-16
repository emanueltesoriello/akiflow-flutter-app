import 'package:flutter/foundation.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/repository/database_repository.dart';
import 'package:mobile/services/database_service.dart';
import 'package:mobile/utils/converters_isolate.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/task/task.dart';

class TasksRepository extends DatabaseRepository {
  final DatabaseService _databaseService = locator<DatabaseService>();

  static const table = 'tasks';

  TasksRepository({
    required Function(Map<String, dynamic>) fromSql,
  }) : super(tableName: table, fromSql: fromSql);

  Future<List<Task>> getUndone<Task>() async {
    List<Map<String, Object?>> items = await _databaseService.database!.rawQuery("""
        SELECT * FROM tasks
        WHERE tasks.done IS NULL
        OR tasks.done = 0
        AND tasks.deleted_at IS NULL
        ORDER BY sorting DESC
""");

    List<Task> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }

  Future<List<Task>> getTodayTasks<Task>({required DateTime date}) async {
    DateTime startTime = DateTime(date.year, date.month, date.day, 0, 0, 0);
    DateTime endTime = startTime.add(const Duration(days: 1));

    List<Map<String, Object?>> items;

    if (date.day == DateTime.now().day && date.month == DateTime.now().month && date.year == DateTime.now().year) {
      items = await _databaseService.database!.rawQuery(
        """
        SELECT * FROM tasks
        WHERE deleted_at IS NULL
        AND status = '${TaskStatusType.planned.id}'
        AND (date <= ? OR datetime < ?)
        ORDER BY
          CASE
            WHEN datetime IS NOT NULL AND datetime >= ? AND (datetime + (duration * 1000) + ${60 * 216000}) >= ?
              THEN datetime
            ELSE
              sorting
          END
""",
        [
          date.toUtc().toIso8601String(),
          endTime.toUtc().toIso8601String(),
          DateTime.now().toUtc().toIso8601String(),
          DateTime.now().toUtc().toIso8601String(),
        ],
      );
    } else {
      items = await _databaseService.database!.rawQuery(
        """
        SELECT * FROM tasks
        WHERE deleted_at IS NULL
        AND status = '${TaskStatusType.planned.id}'
        AND ((date > ? AND date < ?) OR (datetime > ? AND datetime < ?))
        ORDER BY
          CASE
            WHEN datetime IS NOT NULL AND datetime >= ? AND (datetime + (duration * 1000) + ${60 * 216000}) >= ?
              THEN datetime
            ELSE
              sorting
          END
""",
        [
          startTime.toUtc().toIso8601String(),
          endTime.toUtc().toIso8601String(),
          startTime.toUtc().toIso8601String(),
          endTime.toUtc().toIso8601String(),
          DateTime.now().toUtc().toIso8601String(),
          DateTime.now().toUtc().toIso8601String(),
        ],
      );
    }

    List<Task> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }

  Future<List<Task>> getSomeday() async {
    List<Map<String, Object?>> items = await _databaseService.database!.rawQuery("""
      SELECT *
      FROM tasks
      WHERE status = ${TaskStatusType.someday.id}
        AND done = 0
        AND deletedAt IS NULL
""");

    List<Task> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }
}

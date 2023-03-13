import 'package:flutter/foundation.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/repository/database_repository.dart';
import 'package:mobile/core/services/database_service.dart';
import 'package:mobile/common/utils/converters_isolate.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';

import '../../extensions/task_extension.dart';

class TasksRepository extends DatabaseRepository {
  final DatabaseService _databaseService = locator<DatabaseService>();

  static const table = 'tasks';

  TasksRepository({
    required Function(Map<String, dynamic>) fromSql,
  }) : super(tableName: table, fromSql: fromSql);

  /*Future<List<Task>> getInbox<Task>() async {
    List<Map<String, Object?>> items = await _databaseService.database!.rawQuery("""
          SELECT *
          FROM tasks
          WHERE status = ?
            AND done = 0
            AND deleted_at IS NULL
            AND trashed_at IS NULL
          ORDER BY
            sorting DESC
""", [TaskStatusType.inbox.id]);

    List<Task> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }*/

  Future<List<Task>> getInbox<Task>() async {
    List<Map<String, Object?>> items = [];
    try {
      await _databaseService.database!.transaction((txn) async {
        items = await txn.rawQuery("""
          SELECT *
          FROM tasks
          WHERE status = ?
            AND done = 0
            AND deleted_at IS NULL
            AND trashed_at IS NULL
          ORDER BY
            sorting DESC
""", [TaskStatusType.inbox.id]);
      });
    } catch (e) {
      print('Error retrieving inbox tasks: $e');
      return [];
    }

    List<Task> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }

  Future<List<Task>> getAllDocs<Task>() async {
    List<Map<String, Object?>> items = [];
    try {
      await _databaseService.database!.transaction((txn) async {
        items = await txn.rawQuery('''
        SELECT *
        FROM tasks
        WHERE doc IS NOT NULL
        ORDER BY sorting DESC
      ''');
      });
    } catch (e) {
      print('Error retrieving documents: $e');
      return [];
    }

    List<Task> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }

  Future<List<Task>> getTodayTasks<Task>({required DateTime date}) async {
    DateTime startTime = DateTime(date.year, date.month, date.day, 0, 0, 0);
    DateTime endTime = startTime.add(const Duration(days: 1));

    List<Map<String, Object?>> items;

    try {
      if (date.day == DateTime.now().day && date.month == DateTime.now().month && date.year == DateTime.now().year) {
        items = await _databaseService.database!.transaction((txn) async {
          return await txn.rawQuery(
            """
        SELECT * FROM tasks
        WHERE deleted_at IS NULL
        AND trashed_at IS NULL
        AND status = '${TaskStatusType.planned.id}'
        AND (date <= ? OR datetime < ?)
        ORDER BY
          CASE
            WHEN datetime IS NOT NULL AND datetime >= ? AND (datetime + (duration * 1000) + ${60 * 60000}) >= ?
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
        });
      } else {
        items = await _databaseService.database!.transaction((txn) async {
          return await txn.rawQuery(
            """
        SELECT * FROM tasks
        WHERE deleted_at IS NULL
        AND trashed_at IS NULL
        AND status = '${TaskStatusType.planned.id}'
        AND ((date > ? AND date < ?) OR (datetime > ? AND datetime < ?))
        ORDER BY
          CASE
            WHEN datetime IS NOT NULL AND datetime >= ? AND (datetime + (duration * 1000) + ${60 * 60000}) >= ?
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
        });
      }
    } catch (e) {
      print('Error retrieving today\'s tasks: $e');
      return [];
    }

    List<Task> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }

  Future<List<Task>> getTasksForScheduledNotifications<Task>() async {
    DateTime date = DateTime.now().toUtc();
    DateTime endTime = date.add(const Duration(days: 30));

    List<Map<String, Object?>> items;

    try {
      items = await _databaseService.database!.transaction((txn) async {
        return await txn.rawQuery(
          """
        SELECT * FROM tasks
        WHERE deleted_at IS NULL
        AND trashed_at IS NULL
        AND datetime IS NOT NULL
        AND status = '${TaskStatusType.planned.id}'
        AND (datetime >= ? AND datetime <= ?)
        ORDER BY
          CASE
            WHEN datetime IS NOT NULL AND datetime >= ? AND (datetime + (duration * 1000) + ${60 * 60000}) >= ?
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
      });
    } catch (e) {
      print('Error retrieving tasks for scheduled notifications: $e');
      return [];
    }

    List<Task> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }

  Future<List<Task>> getSomeday() async {
    List<Map<String, Object?>> items;
    try {
      items = await _databaseService.database!.transaction((txn) async {
        return await txn.rawQuery("""
      SELECT *
      FROM tasks
      WHERE status = ${TaskStatusType.someday.id}
        AND done = 0
        AND deleted_at IS NULL
        AND trashed_at IS NULL
""");
      });
    } catch (e) {
      print('Error retrieving someday tasks: $e');
      return [];
    }

    List<Task> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }

  Future<List<Task>> getByRecurringId(String recurringId) async {
    List<Map<String, Object?>> items;
    try {
      items = await _databaseService.database!.transaction((txn) async {
        return await txn.rawQuery("""
      SELECT *
      FROM tasks
      WHERE recurring_id = ?
        AND deleted_at IS NULL
        AND trashed_at IS NULL
""", [recurringId]);
      });
    } catch (e) {
      print('Error retrieving tasks by recurring id: $e');
      return [];
    }

    List<Task> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }

  Future<List<Task>> getLabelTasks(Label label) async {
    String query = """
      SELECT *
      FROM tasks
      WHERE list_id = ?
      AND deleted_at IS NULL
      AND trashed_at IS NULL
      GROUP BY IFNULL(`recurring_id`, `id`)
      ORDER BY
          sorting_label is null, sorting_label,
          done ASC,
          status ASC;
""";

    List<Map<String, Object?>> items;
    try {
      items = await _databaseService.database!.transaction((txn) async {
        return await txn.rawQuery(query, [label.id!]);
      });
    } catch (e) {
      print('Error retrieving label tasks: $e');
      return [];
    }

    List<Task> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }

  Future<List<Task>> getCalendarTasks() async {
    List<Map<String, Object?>> items;
    try {
      items = await _databaseService.database!.transaction((txn) async {
        return await txn.rawQuery("""
          SELECT *
          FROM tasks
          WHERE status = '${TaskStatusType.planned.id}'
            AND deleted_at IS NULL
            AND trashed_at IS NULL
            AND datetime IS NOT NULL
            AND duration IS NOT NULL
""");
      });
    } catch (e) {
      print('Error retrieving calendar tasks: $e');
      return [];
    }

    List<Task> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }

  Future<List<Task>> getTasksBetweenDates(String startDate, String endDate) async {
    List<Map<String, Object?>> items;
    try {
      items = await _databaseService.database!.transaction((txn) async {
        return await txn.rawQuery("""
          SELECT *
          FROM tasks
          WHERE status = '${TaskStatusType.planned.id}'
            AND deleted_at IS NULL
            AND trashed_at IS NULL
            AND datetime IS NOT NULL
            AND duration IS NOT NULL
            AND (datetime >= ? AND datetime <= ?)
""", [startDate, endDate]);
      });
    } catch (e) {
      print('Error retrieving tasks between dates: $e');
      return [];
    }

    List<Task> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }

  Future<List<T>> getByRecurringIds<T>(List<dynamic> ids) async {
    List<T> items = [];

    if (ids.length > DatabaseRepository.sqlMaxVariableNumber) {
      List<List<dynamic>> chunks = [];

      for (var i = 0; i < ids.length; i += DatabaseRepository.sqlMaxVariableNumber) {
        List<dynamic> sublistWithMaxVariables = ids.sublist(
            i,
            i + DatabaseRepository.sqlMaxVariableNumber > ids.length
                ? ids.length
                : i + DatabaseRepository.sqlMaxVariableNumber);
        chunks.add(sublistWithMaxVariables);
      }

      for (var chunk in chunks) {
        List<T> existingModelsChunk = await _getByRecurringIds(chunk);
        items.addAll(existingModelsChunk);
      }
    } else {
      items = await _getByRecurringIds(ids);
    }

    return items;
  }

  Future<List<T>> _getByRecurringIds<T>(List<dynamic> ids) async {
    String ins = ids.map((el) => '?').join(',');
    List<Map<String, Object?>> items;
    try {
      items = await _databaseService.database!.transaction((txn) async {
        return await txn.rawQuery("SELECT * FROM $tableName WHERE recurring_id in ($ins) ", ids);
      });
    } catch (e) {
      print('Error retrieving objects by recurring ids: $e');
      return [];
    }

    return await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
  }
}

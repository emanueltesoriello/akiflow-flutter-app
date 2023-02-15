import 'package:flutter/foundation.dart';
import 'package:mobile/common/utils/converters_isolate.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/repository/database_repository.dart';
import 'package:mobile/core/services/database_service.dart';

class EventsRepository extends DatabaseRepository {
  final DatabaseService _databaseService = locator<DatabaseService>();
  static const table = 'events';

  EventsRepository({
    required Function(Map<String, dynamic>) fromSql,
  }) : super(tableName: table, fromSql: fromSql);

  Future<List<Event>> getEvents<Event>() async {
    List<Map<String, Object?>> items = await _databaseService.database!.rawQuery("""
          SELECT *
          FROM events
          WHERE task_id IS NULL
""");

    List<Event> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }

  Future<List<Event>> getEventsBetweenDates<Event>(DateTime startTime, DateTime? endTime) async {
    endTime ??= startTime.add(const Duration(days: 1));
    String start = startTime.toUtc().toIso8601String();
    String end = endTime.toUtc().toIso8601String();

    List<Map<String, Object?>> items = await _databaseService.database!.rawQuery("""
          SELECT *
          FROM events
          WHERE task_id IS NULL         
          AND ( 
              (recurring_id IS NULL OR recurrence_exception = 1)
              AND ((start_time >= ? AND end_time <= ?) OR (start_date >= ? AND end_date <= ?))
              OR (id = recurring_id AND (start_time < ? OR start_date <= ?) AND (until_date_time IS NULL OR until_date_time >= ?))             
              )    

""", [start, end, start, end, end, end, start]);

    List<Event> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }

  Future<List<Event>> getAllDayEventsBetweenDates<Event>(DateTime startTime, DateTime? endTime) async {
    endTime ??= startTime.add(const Duration(days: 1));
    String start = startTime.toUtc().toIso8601String();
    String end = endTime.toUtc().toIso8601String();

    List<Map<String, Object?>> items = await _databaseService.database!.rawQuery("""
          SELECT *
          FROM events
          WHERE task_id IS NULL
          AND (
            (recurring_id IS NULL OR recurrence_exception = 1)
            AND (recurrence_exception = 1 OR 
                   (start_time >= ? AND start_time <= ?) 
                OR (start_time < ? AND end_time >= ?) 
                OR (start_date >= ? AND start_date <= ?) 
                OR (start_date < ? AND end_date >= ?)
                )
          OR (id = recurring_id AND (start_time < ? OR start_date <= ?) AND (until_date_time IS NULL OR until_date_time >= ?))          
        )
""", [start, end, start, start, start, end, start, start, end, end, start]);

    List<Event> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }
}

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
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
    List<Map<String, Object?>> items;
    try {
      items = await _databaseService.database!.transaction((txn) async {
        return await txn.rawQuery("""
        SELECT *
        FROM events
        WHERE task_id IS NULL
      """);
      });
    } catch (e) {
      print('Error retrieving events: $e');
      return [];
    }

    List<Event> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }

  Future<List<Event>> getEventsBetweenDates<Event>(DateTime start, DateTime end) async {
    String startTime = start.toIso8601String();
    String endTime = end.toIso8601String();
    String startDate = DateFormat("y-MM-dd").format(start);
    String endDate = DateFormat("y-MM-dd").format(end);
    List<Map<String, Object?>> items;
    try {
      items = await _databaseService.database!.transaction((txn) async {
        return await txn.rawQuery("""
        SELECT *
        FROM events
        WHERE task_id IS NULL         
        AND ( 
          (recurring_id IS NULL
          AND ((start_time >= ? AND end_time <= ?) 
          OR (start_date >= ? AND start_date <= ?) OR (start_date <= ? AND end_date >= ?)))
          OR (recurring_id IS NOT NULL 
              AND (start_time <= ? OR (original_start_time >= ? AND original_start_time <= ?)) 
              AND (until_datetime IS NULL OR until_datetime >= ?)) 
        )    
      """, [
          startTime,
          endTime,
          startDate,
          endDate,
          startDate,
          startDate,
          endTime,
          startTime,
          endTime,
          startTime,
        ]);
      });
    } catch (e) {
      print('Error retrieving events between dates: $e');
      return [];
    }

    List<Event> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }

  Future<List<Event>> getExceptionsByRecurringId<Event>(String recurringId) async {
    List<Map<String, Object?>> items;
    try {
      items = await _databaseService.database!.transaction((txn) async {
        return await txn.rawQuery("""
        SELECT *
        FROM events
        WHERE recurring_id = ?
        AND deleted_at IS NULL
        AND organizer_id IS NOT NULL
        AND id != recurring_id 
      """, [recurringId]);
      });
    } catch (e) {
      print('Error retrieving events: $e');
      return [];
    }

    List<Event> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }
}

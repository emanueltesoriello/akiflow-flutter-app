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

  Future<List<Event>> getEventsBetweenDates<Event>(String startDate, String endDate) async {
    List<Map<String, Object?>> items = await _databaseService.database!.rawQuery("""
          SELECT *
          FROM events
          WHERE task_id IS NULL         
          AND ( 
              (recurring_id IS NULL
              AND ((start_time >= ? AND end_time <= ?) OR (start_date >= ? AND end_date <= ?)))
              OR (recurring_id IS NOT NULL AND (until_datetime IS NULL OR until_datetime >= ?)) 
              )    
""", [
      startDate,
      endDate,
      startDate,
      endDate,
      startDate,
    ]);

    List<Event> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }
}

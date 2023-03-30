import 'package:flutter/foundation.dart';
import 'package:mobile/common/utils/converters_isolate.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/repository/database_repository.dart';
import 'package:mobile/core/services/database_service.dart';
import 'package:models/calendar/calendar.dart';

class CalendarsRepository extends DatabaseRepository {
  CalendarsRepository({
    required Function(Map<String, dynamic>) fromSql,
  }) : super(tableName: table, fromSql: fromSql);

  final DatabaseService _databaseService = locator<DatabaseService>();
  static const table = 'calendars';

  Future<List<Calendar>> getCalendars() async {
    List<Map<String, Object?>> items;
    try {
      items = await _databaseService.database!.transaction((txn) async {
        return await txn.rawQuery("""
          SELECT *
          FROM calendars
          WHERE deleted_at IS NULL
""");
      });
    } catch (e) {
      print('Error retrieving calendars: $e');
      return [];
    }

    List<Calendar> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }
}

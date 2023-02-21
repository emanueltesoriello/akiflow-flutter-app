import 'package:flutter/foundation.dart';
import 'package:mobile/common/utils/converters_isolate.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/repository/database_repository.dart';
import 'package:mobile/core/services/database_service.dart';

class EventModifiersRepository extends DatabaseRepository {
  final DatabaseService _databaseService = locator<DatabaseService>();
  static const table = 'event_modifiers';

  EventModifiersRepository({
    required Function(Map<String, dynamic>) fromSql,
  }) : super(tableName: table, fromSql: fromSql);

  Future<List<EventModifier>> getUnprocessedEventModifiersByEventId<EventModifier>(String eventId) async {
    List<Map<String, Object?>> items = await _databaseService.database!.rawQuery("""
          SELECT *
          FROM event_modifiers
          WHERE deleted_at IS NULL
          AND processed_at IS NULL
          AND event_id IS ?
          ORDER BY created_at DESC
""", [eventId]);

    List<EventModifier> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }
}

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

  Future<List<EventModifier>> getUnprocessedEventModifiers<EventModifier>() async {
    List<Map<String, Object?>> items;
    try {
      items = await _databaseService.database!.transaction((txn) async {
        return await txn.rawQuery("""
        SELECT *
        FROM event_modifiers
        WHERE deleted_at IS NULL
        AND processed_at IS NULL
      """);
      });
    } catch (e) {
      print('Error retrieving unprocessed event modifiers: $e');
      return [];
    }

    List<EventModifier> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }
}

import 'package:flutter/foundation.dart';
import 'package:mobile/core/services/database_service.dart';
import 'package:models/task/availability_config.dart';

import '../../common/utils/converters_isolate.dart';
import 'database_repository.dart';

class AvailabilitiesRepository extends DatabaseRepository {
  static const table = 'availabilities';

  AvailabilitiesRepository({
    required Function(Map<String, dynamic>) fromSql,
  }) : super(tableName: table, fromSql: fromSql);

  Future<List<AvailabilityConfig>> getAvailabilities<Task>() async {
    List<Map<String, Object?>> items;
    try {
      items = await DatabaseService.database!.rawQuery("""
      SELECT *
      FROM availabilities
      WHERE deleted_at IS NULL
    """);
    } catch (e) {
      print('Error retrieving availabilities: $e');
      return [];
    }

    List<AvailabilityConfig> objects =
        await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }
}

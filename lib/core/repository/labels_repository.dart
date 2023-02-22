import 'package:flutter/foundation.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/repository/database_repository.dart';
import 'package:mobile/core/services/database_service.dart';
import 'package:mobile/common/utils/converters_isolate.dart';
import 'package:models/label/label.dart';

class LabelsRepository extends DatabaseRepository {
  final DatabaseService _databaseService = locator<DatabaseService>();

  static const table = 'lists';

  LabelsRepository({
    required Function(Map<String, dynamic>) fromSql,
  }) : super(tableName: table, fromSql: fromSql);

  Future<List<Label>> getLabels() async {
    String query = """SELECT * FROM lists WHERE deleted_at IS NULL ORDER BY sorting ASC;""";

    List<Map<String, Object?>> items;
    try {
      items = await _databaseService.database!.transaction((txn) async {
        return await txn.rawQuery(query);
      });
    } catch (e) {
      print('Error retrieving labels: $e');
      return [];
    }

    return await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
  }
}

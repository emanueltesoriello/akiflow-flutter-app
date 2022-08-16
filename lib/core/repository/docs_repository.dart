import 'package:flutter/foundation.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/repository/database_repository.dart';
import 'package:mobile/core/services/database_service.dart';
import 'package:mobile/common/utils/converters_isolate.dart';
import 'package:models/doc/doc.dart';

class DocsRepository extends DatabaseRepository {
  final DatabaseService _databaseService = locator<DatabaseService>();

  static const table = 'docs';

  DocsRepository({
    required Function(Map<String, dynamic>) fromSql,
  }) : super(tableName: table, fromSql: fromSql);

  Future<Doc?> getDocByConnectorIdAndOriginId({required String connectorId, required String originId}) async {
    List<Map<String, Object?>> items = await _databaseService.database!.rawQuery("""
      SELECT *
      FROM $table
      WHERE connector_id = ? AND origin_id = ?
""", [connectorId, originId]);

    List<Doc> docs = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));

    return docs.isNotEmpty ? docs.first : null;
  }
}

import 'package:flutter/foundation.dart';
import 'package:mobile/common/utils/converters_isolate.dart';
import 'package:mobile/core/repository/database_repository.dart';
import 'package:mobile/core/services/database_service.dart';

class ContactsRepository extends DatabaseRepository {
  static const table = 'contacts';

  ContactsRepository({
    required Function(Map<String, dynamic>) fromSql,
  }) : super(tableName: table, fromSql: fromSql);

  Future<List<Contact>> getSearchedContacts<Contact>(String query, {int limit = 25}) async {
    List<Map<String, Object?>> items = await DatabaseService.database!.rawQuery("""
          SELECT *
          FROM contacts
          WHERE search_text LIKE ?
          AND deleted_at IS NULL
          ORDER BY sorting DESC
          LIMIT ?
""", ['%$query%', limit]);

    List<Contact> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
    return objects;
  }
}

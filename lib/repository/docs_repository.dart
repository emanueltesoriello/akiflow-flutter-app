import 'package:mobile/repository/database_repository.dart';

class DocsRepository extends DatabaseRepository {
  static const table = 'docs';

  DocsRepository({
    required Function(Map<String, dynamic>) fromSql,
  }) : super(tableName: table, fromSql: fromSql);
}

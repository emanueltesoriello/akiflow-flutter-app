import 'package:mobile/core/locator.dart';
import 'package:mobile/exceptions/database_exception.dart';
import 'package:mobile/repository/base_database_repository.dart';
import 'package:mobile/services/database_service.dart';
import 'package:models/base.dart';

class DatabaseRepository implements IBaseDatabaseRepository {
  final DatabaseService _databaseService = locator<DatabaseService>();

  final String tableName;
  final Function(Map<String, dynamic>) fromSql;

  DatabaseRepository({required this.tableName, required this.fromSql});

  @override
  Future<List<T>> get<T>() async {
    List<Map<String, Object?>> items =
        await _databaseService.database!.query(tableName);

    List<T> result = [];

    for (dynamic item in items) {
      result.add(fromSql(item));
    }

    return result;
  }

  Future<void> add<T>(List<T> items) async {
    var batch = _databaseService.database!.batch();

    for (T item in items) {
      batch.insert(tableName, (item as Base).toSql());
    }

    await batch.commit();
  }

  @override
  Future<void> updateById<T>(String? id, {required T data}) {
    return _databaseService.database!.update(
      tableName,
      (data as Base).toSql(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<T>> unsynced<T>() async {
    const withoutRemoteUpdatedAt = 'remote_updated_at IS NULL';
    const deletedAtLaterThanRemoteUpdatedAt = 'deleted_at > remote_updated_at';
    const updatedAtLaterThanRemoteUpdatedAt = 'updated_at > remote_updated_at';

    var items = await _databaseService.database!.query(
      tableName,
      where:
          '$withoutRemoteUpdatedAt OR $deletedAtLaterThanRemoteUpdatedAt OR $updatedAtLaterThanRemoteUpdatedAt',
    );

    List<T> result = [];

    for (dynamic item in items) {
      result.add(fromSql(item));
    }

    return result;
  }

  @override
  Future<T> byId<T>(String id) async {
    var result = await _databaseService.database!.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) {
      throw DatabaseRepositoryException('No item found with id $id');
    }

    return fromSql(result.first);
  }
}

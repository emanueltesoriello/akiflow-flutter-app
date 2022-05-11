import 'package:flutter/foundation.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/exceptions/database_exception.dart';
import 'package:mobile/repository/base_database_repository.dart';
import 'package:mobile/services/database_service.dart';
import 'package:mobile/utils/converters_isolate.dart';
import 'package:models/base.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseRepository implements IBaseDatabaseRepository {
  final DatabaseService _databaseService = locator<DatabaseService>();

  final String tableName;
  final Function(Map<String, dynamic>) fromSql;

  DatabaseRepository({required this.tableName, required this.fromSql});

  @override
  Future<List<T>> get<T>() async {
    List<Map<String, Object?>> items = await _databaseService.database!.query(tableName);

    List<T> result = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));

    return result;
  }

  @override
  Future<T?> getById<T>(id) async {
    List<Map<String, Object?>> items =
        await _databaseService.database!.rawQuery("SELECT * FROM " + tableName + " WHERE id=? ", [id]);
    if (items.isEmpty) {
      return null;
    } else {
      return (await compute(convertToObjList, RawListConvert(items: items, converter: fromSql)))[0];
    }
  }

  @override
  Future<List<T>> getByIds<T>(List<dynamic> ids) async {
    String ins = ids.map((el) => '?').join(',');
    List<Map<String, Object?>> items =
        await _databaseService.database!.rawQuery("SELECT * FROM " + tableName + " WHERE id in (" + ins + ") ", ids);

    return (await compute(convertToObjList, RawListConvert(items: items, converter: fromSql)));
  }

  @override
  Future<List<Object?>> add<T>(List<T> items) async {
    Batch batch = _databaseService.database!.batch();

    List<dynamic> result = await compute(fromObjToSqlList, items);

    batch = await compute(prepareBatchInsert, BatchInsertModel(items: result, batch: batch, tableName: tableName));

    return await batch.commit();
  }

  @override
  Future<void> updateById<T>(String? id, {required T data}) async {
    await _databaseService.database!.update(
      tableName,
      (data as Base).toSql(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> setFieldByName<T>(String? id, {required String field, required T value}) async {
    await _databaseService.database!.update(
      tableName,
      {field: value},
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
      where: '$withoutRemoteUpdatedAt OR $deletedAtLaterThanRemoteUpdatedAt OR $updatedAtLaterThanRemoteUpdatedAt',
    );

    List<T> result = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));

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

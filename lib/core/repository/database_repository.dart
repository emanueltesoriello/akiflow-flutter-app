import 'package:flutter/foundation.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/exceptions/database_exception.dart';
import 'package:mobile/core/repository/base_database_repository.dart';
import 'package:mobile/core/services/database_service.dart';
import 'package:mobile/common/utils/converters_isolate.dart';
import 'package:models/base.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseRepository implements IBaseDatabaseRepository {
  final DatabaseService _databaseService = locator<DatabaseService>();

  static const int sqlMaxVariableNumber = 999;

  final String tableName;
  final Function(Map<String, dynamic>) fromSql;

  DatabaseRepository({required this.tableName, required this.fromSql});

  @override
  Future<List<T>> get<T>() async {
    List<Map<String, Object?>> items = await _databaseService.database!.query(tableName);

    List<T> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));

    return objects;
  }

  @override
  Future<T?> getById<T>(id) async {
    List<Map<String, Object?>> items =
        await _databaseService.database!.rawQuery("SELECT * FROM $tableName WHERE id=? ", [id]);
    if (items.isEmpty) {
      return null;
    } else {
      List<T> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
      return objects.first;
    }
  }

  @override
  Future<List<T>> getByIds<T>(List<dynamic> ids) async {
    List<T> items = [];

    if (ids.length > DatabaseRepository.sqlMaxVariableNumber) {
      List<List<dynamic>> chunks = [];

      for (var i = 0; i < ids.length; i += DatabaseRepository.sqlMaxVariableNumber) {
        List<dynamic> sublistWithMaxVariables = ids.sublist(
            i,
            i + DatabaseRepository.sqlMaxVariableNumber > ids.length
                ? ids.length
                : i + DatabaseRepository.sqlMaxVariableNumber);
        chunks.add(sublistWithMaxVariables);
      }

      for (var chunk in chunks) {
        List<T> existingModelsChunk = await _getByIds(chunk);
        items.addAll(existingModelsChunk);
      }
    } else {
      items = await _getByIds(ids);
    }

    return items;
  }

  Future<List<T>> _getByIds<T>(List<dynamic> ids) async {
    try {
      String ins = ids.map((el) => '?').join(',');
      List<Map<String, Object?>> items =
          await _databaseService.database!.rawQuery("SELECT * FROM $tableName WHERE id in ($ins) ", ids);
      List<T> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
      return objects;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  @override
  Future<List<T>> getByItems<T>(List<dynamic> ids) async {
    List<T> items = [];

    if (ids.length > DatabaseRepository.sqlMaxVariableNumber) {
      List<List<dynamic>> chunks = [];

      for (var i = 0; i < ids.length; i += DatabaseRepository.sqlMaxVariableNumber) {
        List<dynamic> sublistWithMaxVariables = ids.sublist(
            i,
            i + DatabaseRepository.sqlMaxVariableNumber > ids.length
                ? ids.length
                : i + DatabaseRepository.sqlMaxVariableNumber);
        chunks.add(sublistWithMaxVariables);
      }

      for (var chunk in chunks) {
        List<T> existingModelsChunk = await _supportGetByItems(chunk);
        items.addAll(existingModelsChunk);
      }
    } else {
      items = await _supportGetByItems(ids);
    }

    return items;
  }

  Future<List<T>> _supportGetByItems<T>(List<dynamic> elements) async {
    try {
      List<dynamic> ids = elements.map((remoteItem) => remoteItem.id).toList();
      String ins = ids.map((el) => '?').join(',');
      List<Map<String, Object?>> items = [];

      await _databaseService.database!.transaction((txn) async {
        items = await txn.rawQuery("SELECT * FROM $tableName WHERE id in ($ins) ", ids);

        if (elements.length != items.length) {
          print("checking if connectorId & originAccountId matches");

          List<dynamic> originAccountIds = elements.map((remoteItem) => remoteItem.originAccountId).toList();
          //List<dynamic> connectorIds = elements.map((remoteItem) => remoteItem.connectorId).toList();
          items = await txn.rawQuery("SELECT * FROM $tableName WHERE origin_account_id in ($ins) ", originAccountIds);
        }
      });

      List<T> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));

      return objects;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  @override
  Future<List<Object?>> add<T>(List<T> items) async {
    List<dynamic> result = await compute(fromObjToSqlList, items);

    try {
      return await _databaseService.database!.transaction<List<Object?>>((txn) async {
        Batch batch = txn.batch();
        batch = await compute(prepareBatchInsert, BatchInsertModel(items: result, batch: batch, tableName: tableName));
        return await batch.commit();
      });
    } catch (e) {
      print('Error adding items to the database: $e');
      return [];
    }
  }

  @override
  Future<void> removeById<T>(String? id, {required T data}) async {
    try {
      await _databaseService.database!.transaction((txn) async {
        await txn.delete(
          tableName,
          where: 'id = ?',
          whereArgs: [id],
        );
      });
    } catch (e) {
      print('Error removing item from the database: $e');
    }
  }

  @override
  Future<void> updateById<T>(String? id, {required T data}) async {
    try {
      await _databaseService.database!.transaction((txn) async {
        await txn.update(
          tableName,
          (data as Base).toSql(),
          where: 'id = ?',
          whereArgs: [id],
        );
      });
    } catch (e) {
      print('Error updating item in the database: $e');
    }
  }

  @override
  Future<void> setFieldByName<T>(String? id, {required String field, required T value}) async {
    try {
      await _databaseService.database!.transaction((txn) async {
        await txn.update(
          tableName,
          {field: value},
          where: 'id = ?',
          whereArgs: [id],
        );
      });
    } catch (e) {
      print('Error setting field in the database: $e');
    }
  }

  @override
  Future<List<T>> unsynced<T>() async {
    const withoutRemoteUpdatedAt = 'remote_updated_at IS NULL';
    const deletedAtGreaterThanRemoteUpdatedAt = 'deleted_at > remote_updated_at';
    const updatedAtGreaterThanRemoteUpdatedAt = 'updated_at > remote_updated_at';

    List<String> conditionsListId = [
      '(global_list_id_updated_at IS NOT NULL AND remote_list_id_updated_at IS NULL)',
      'global_list_id_updated_at > remote_list_id_updated_at',
    ];
    String joinedConditionsListId = conditionsListId.join(' OR ');
    List<Map<String, Object?>> items = [];
    try {
      await _databaseService.database!.transaction((txn) async {
        if (tableName == "tasks") {
          items = await txn.query(tableName,
              where:
                  '$withoutRemoteUpdatedAt OR $deletedAtGreaterThanRemoteUpdatedAt OR $updatedAtGreaterThanRemoteUpdatedAt OR $joinedConditionsListId');
        } else {
          items = await txn.query(
            tableName,
            where:
                '$withoutRemoteUpdatedAt OR $deletedAtGreaterThanRemoteUpdatedAt OR $updatedAtGreaterThanRemoteUpdatedAt',
          );
        }
      });
    } catch (e) {
      print('Error retrieving unsynced records: $e');
      return [];
    }

    List<T> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));

    return objects;
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

  Future<T?> getRecurringByOriginalStart<T>(
      akiflowAccountId, calendarId, recurringId, originalStartDateTimeColumn) async {
    String query =
        """SELECT id, akiflow_account_id, calendar_id, $originalStartDateTimeColumn, recurring_id, updated_at, remote_updated_at, deleted_at 
    FROM $tableName WHERE akiflow_account_id = ? AND calendar_id = ? AND recurring_id = ? AND $originalStartDateTimeColumn = ?""";
    List<Map<String, Object?>> items = await _databaseService.database!
        .rawQuery(query, [akiflowAccountId, calendarId, recurringId, originalStartDateTimeColumn]);
    if (items.isEmpty) {
      return null;
    } else {
      List<T> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromSql));
      return objects.first;
    }
  }
}

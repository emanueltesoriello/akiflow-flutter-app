import 'package:models/base.dart';
import 'package:models/doc/doc.dart';
import 'package:models/task/task.dart';
import 'package:sqflite/sqflite.dart';

class RawListConvert {
  final List<dynamic> items;
  final Function converter;

  RawListConvert({
    required this.items,
    required this.converter,
  });
}

class BatchInsertModel {
  final List<dynamic> items;
  final Batch batch;
  final String tableName;

  BatchInsertModel({
    required this.items,
    required this.batch,
    required this.tableName,
  });
}

class PrepareItemsModel {
  final List<dynamic> remoteItems;
  final List<dynamic> localItems;

  PrepareItemsModel({
    required this.remoteItems,
    required this.localItems,
  });
}

List<T> convertToObjList<T>(RawListConvert rawListConvert) {
  List<T> result = [];

  for (dynamic item in rawListConvert.items) {
    try {
      result.add(rawListConvert.converter(item));
    } catch (e) {
      print(e);
    }
  }

  return result;
}

List<dynamic> fromObjToMapList<T>(List<T> items) {
  List<dynamic> result = [];

  for (T item in items) {
    result.add((item as Base).toMap());
  }

  return result;
}

List<dynamic> fromObjToSqlList<T>(List<T> items) {
  List<dynamic> result = [];

  for (T item in items) {
    result.add((item as Base).toSql());
  }

  return result;
}

DateTime? getMaxUpdatedAt(List<dynamic> items) {
  DateTime? maxRemoteUpdateAt;

  for (var item in items) {
    DateTime? newUpdatedAt = item.updatedAt;

    if (maxRemoteUpdateAt == null || (newUpdatedAt != null && newUpdatedAt.isAfter(maxRemoteUpdateAt))) {
      maxRemoteUpdateAt = newUpdatedAt;
    }
  }

  return maxRemoteUpdateAt;
}

List<dynamic> prepareItemsForRemote<T>(List<dynamic> items) {
  for (int i = 0; i < items.length; i++) {
    var item = items[i];

    DateTime? updatedAt = item.updatedAt;
    DateTime? deletedAt = item.deletedAt;

    DateTime? maxDate;

    if (updatedAt != null && deletedAt != null) {
      maxDate = updatedAt.isAfter(deletedAt) ? updatedAt : deletedAt;
    } else if (updatedAt != null) {
      maxDate = updatedAt;
    } else if (deletedAt != null) {
      maxDate = deletedAt;
    }

    if (item is Doc || item is Task) {
      item = item.copyWith(
        globalUpdatedAt: maxDate ?? DateTime.now().toUtc(),
        updatedAt: maxDate ?? DateTime.now().toUtc(),
      );
    } else {
      item = item.rebuild((t) {
        t.globalUpdatedAt = maxDate ?? DateTime.now().toUtc();
        t.updatedAt = maxDate ?? DateTime.now().toUtc();
      });
    }

    items[i] = item;
  }

  return items;
}

Batch prepareBatchInsert(BatchInsertModel batchInsertModel) {
  for (dynamic item in batchInsertModel.items) {
    batchInsertModel.batch.insert(
      batchInsertModel.tableName,
      item,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  return batchInsertModel.batch;
}

List<dynamic> filterItemsToInsert<T>(PrepareItemsModel prepareItemsModel) {
  List<dynamic> itemsToInsert = [];

  for (int i = 0; i < prepareItemsModel.remoteItems.length; i++) {
    var remoteItem = prepareItemsModel.remoteItems[i];

    bool hasAlreadyInLocalDatabase = prepareItemsModel.localItems.any((element) => element.id == remoteItem.id);

    if (!hasAlreadyInLocalDatabase) {
      if (remoteItem is Doc || remoteItem is Task) {
        remoteItem = remoteItem.copyWith(
          updatedAt: remoteItem.globalUpdatedAt,
          remoteUpdatedAt: remoteItem.globalUpdatedAt,
        );
      } else {
        remoteItem = remoteItem.rebuild((t) {
          t.updatedAt = remoteItem.globalUpdatedAt;
          t.remoteUpdatedAt = remoteItem.globalUpdatedAt;
        });
      }

      prepareItemsModel.remoteItems[i] = remoteItem;

      itemsToInsert.add(remoteItem);
    }
  }

  return itemsToInsert;
}

List<dynamic> filterItemsToUpdate<T>(PrepareItemsModel prepareItemsModel) {
  List<dynamic> itemsToUpdate = [];

  for (int i = 0; i < prepareItemsModel.remoteItems.length; i++) {
    var remoteItem = prepareItemsModel.remoteItems[i];

    bool hasAlreadyInLocalDatabase = prepareItemsModel.localItems.any((element) => element.id == remoteItem.id);

    if (hasAlreadyInLocalDatabase) {
      var localTask = prepareItemsModel.localItems.firstWhere((element) => element.id == remoteItem.id);

      int remoteGlobalUpdateAtMillis = remoteItem.globalUpdatedAt?.millisecondsSinceEpoch ?? 0;
      int localUpdatedAtMillis = localTask.updatedAt?.millisecondsSinceEpoch ?? 0;

      if (remoteGlobalUpdateAtMillis >= localUpdatedAtMillis) {
        if (remoteItem is Doc || remoteItem is Task) {
          remoteItem = remoteItem.copyWith(
            updatedAt: remoteItem.globalUpdatedAt,
            remoteUpdatedAt: remoteItem.globalUpdatedAt,
          );
        } else {
          remoteItem = remoteItem.rebuild((t) {
            t.updatedAt = remoteItem.globalUpdatedAt;
            t.remoteUpdatedAt = remoteItem.globalUpdatedAt;
          });
        }

        prepareItemsModel.remoteItems[i] = remoteItem;

        itemsToUpdate.add(remoteItem);
      }
    }
  }

  return itemsToUpdate;
}

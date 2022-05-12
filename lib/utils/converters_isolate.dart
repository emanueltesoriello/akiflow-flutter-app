import 'package:models/base.dart';
import 'package:models/doc/doc.dart';
import 'package:models/task/task.dart';
import 'package:sqflite/sqflite.dart';

class RawListConvert {
  final List<dynamic> items;
  final Function(Map<String, dynamic>) converter;

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

class PartitioneItemModel {
  final List<dynamic> remoteItems;
  final List<dynamic> existingItems;

  PartitioneItemModel({
    required this.remoteItems,
    required this.existingItems,
  });
}

Future<List<T>> convertToObjList<T>(RawListConvert rawListConvert) async {
  List<T> result = [];

  for (dynamic item in rawListConvert.items) {
    result.add(rawListConvert.converter(item) as T);
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
        remoteUpdatedAt: maxDate ?? DateTime.now().toUtc(),
        updatedAt: maxDate ?? DateTime.now().toUtc(),
      );
    } else {
      item = item.rebuild((t) {
        t.remoteUpdatedAt = maxDate ?? DateTime.now().toUtc();
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

Future<List<List<dynamic>>> partitionItemsToUpsert<T>(PartitioneItemModel partitioneItemModel) async {
  List<dynamic> allModels = partitioneItemModel.remoteItems;
  List<dynamic> existingModels = partitioneItemModel.existingItems;
  List<dynamic> changedModels = [];
  List<dynamic> unchangedModels = [];
  List<dynamic> nonExistingModels = [];

  Map<String, dynamic> existingModelsById = Map.fromIterable(existingModels, key: (model) => model.id);

  for (var model in allModels) {
    int remoteGlobalUpdateAtMillis = model.globalUpdatedAt?.millisecondsSinceEpoch ?? 0;
    int localUpdatedAtMillis = existingModelsById[model.id]?.updatedAt?.millisecondsSinceEpoch ?? 0;

    if (model is Doc || model is Task) {
      model = model.copyWith(
        updatedAt: model.globalUpdatedAt,
        remoteUpdatedAt: model.globalUpdatedAt,
      );
    } else {
      model = model.rebuild((t) {
        t.updatedAt = model.globalUpdatedAt;
        t.remoteUpdatedAt = model.globalUpdatedAt;
      });
    }

    if (existingModelsById.containsKey(model.id)) {
      if (remoteGlobalUpdateAtMillis > localUpdatedAtMillis) {
        changedModels.add(model);
      } else {
        unchangedModels.add(model);
      }
    } else {
      nonExistingModels.add(model);
    }
  }
  return [changedModels, unchangedModels, nonExistingModels];
}

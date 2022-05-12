import 'package:models/base.dart';
import 'package:models/nullable.dart';
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
    String? newUpdatedAt = item.updatedAt;

    if (maxRemoteUpdateAt == null ||
        (newUpdatedAt != null && DateTime.parse(newUpdatedAt).isAfter(maxRemoteUpdateAt))) {
      maxRemoteUpdateAt = DateTime.parse(newUpdatedAt!);
    }
  }

  return maxRemoteUpdateAt;
}

List<dynamic> prepareItemsForRemote<T>(List<dynamic> items) {
  for (int i = 0; i < items.length; i++) {
    var item = items[i];

    String? updatedAt = item.updatedAt;
    String? deletedAt = item.deletedAt;

    DateTime? maxDate;

    if (updatedAt != null && deletedAt != null) {
      DateTime updatedAtDate = DateTime.parse(updatedAt);
      DateTime deletedAtDate = DateTime.parse(deletedAt);

      maxDate = updatedAtDate.isAfter(deletedAtDate) ? updatedAtDate : deletedAtDate;
    } else if (updatedAt != null) {
      DateTime updatedAtDate = DateTime.parse(updatedAt);
      maxDate = updatedAtDate;
    } else if (deletedAt != null) {
      DateTime deletedAtDate = DateTime.parse(deletedAt);
      maxDate = deletedAtDate;
    }

    String maxDateString = maxDate != null ? maxDate.toIso8601String() : (DateTime.now().toUtc().toIso8601String());

    item = item.copyWith(
      updatedAt: Nullable(maxDateString),
      remoteUpdatedAt: Nullable(maxDateString),
    );

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
    int remoteGlobalUpdateAtMillis = 0;
    int localUpdatedAtMillis = 0;

    if (model.globalUpdatedAt != null) {
      remoteGlobalUpdateAtMillis = DateTime.parse(model.globalUpdatedAt!).millisecondsSinceEpoch;
    }

    if (existingModelsById[model.id]?.updatedAt != null) {
      localUpdatedAtMillis = DateTime.parse(existingModelsById[model.id]!.updatedAt!).millisecondsSinceEpoch;
    }

    String? globalUpdatedAtString =
        model.globalUpdatedAt != null ? DateTime.parse(model.globalUpdatedAt!).toIso8601String() : null;

    model = model.copyWith(
      updatedAt: Nullable(globalUpdatedAtString),
      remoteUpdatedAt: Nullable(globalUpdatedAtString),
    );

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

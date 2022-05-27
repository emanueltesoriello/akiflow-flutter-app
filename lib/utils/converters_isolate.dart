import 'package:collection/collection.dart';
import 'package:models/base.dart';
import 'package:models/doc/doc.dart';
import 'package:models/nullable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

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

List<dynamic> prepareItemsForRemote<T>(List<dynamic> localItems) {
  for (int i = 0; i < localItems.length; i++) {
    var localItem = localItems[i];

    String? updatedAt = localItem.updatedAt;
    String? deletedAt = localItem.deletedAt;

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

    localItem = localItem.copyWith(
      globalUpdatedAt: maxDate?.toIso8601String(),
      globalCreatedAt: localItem.createdAt,
    );

    localItems[i] = localItem;
  }

  return localItems;
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
  List<dynamic> allRemoteModels = partitioneItemModel.remoteItems;
  List<dynamic> existingLocalModels = partitioneItemModel.existingItems;
  List<dynamic> changedModels = [];
  List<dynamic> unchangedModels = [];
  List<dynamic> nonExistingModels = [];

  Map<String, dynamic> existingModelsById = Map.fromIterable(existingLocalModels, key: (model) => model.id);

  for (var remoteModel in allRemoteModels) {
    int remoteGlobalUpdateAtMillis = 0;
    int localUpdatedAtMillis = 0;

    if (remoteModel.globalUpdatedAt != null) {
      remoteGlobalUpdateAtMillis = DateTime.parse(remoteModel.globalUpdatedAt!).millisecondsSinceEpoch;
    }

    if (existingModelsById[remoteModel.id]?.updatedAt != null) {
      localUpdatedAtMillis = DateTime.parse(existingModelsById[remoteModel.id]!.updatedAt!).millisecondsSinceEpoch;
    }

    Nullable<String?>? remoteUpdatedAt = Nullable(remoteModel.globalUpdatedAt);

    remoteModel = remoteModel.copyWith(
      updatedAt: remoteUpdatedAt,
      createdAt: remoteModel.globalCreatedAt,
      deletedAt: remoteModel.deletedAt,
      remoteUpdatedAt: remoteUpdatedAt,
    );

    if (existingModelsById.containsKey(remoteModel.id)) {
      if (remoteGlobalUpdateAtMillis >= localUpdatedAtMillis) {
        changedModels.add(remoteModel);
      } else {
        unchangedModels.add(remoteModel);
      }
    } else {
      nonExistingModels.add(remoteModel);
    }
  }
  return [changedModels, unchangedModels, nonExistingModels];
}

class PrepareDocForRemoteModel {
  final List<Doc> remoteItems;
  final List<Doc> existingItems;

  PrepareDocForRemoteModel({
    required this.remoteItems,
    required this.existingItems,
  });
}

class DocsFromGmailDataModel {
  final List<dynamic> gmailData;
  final int syncMode;
  final String connectorId;
  final String accountId;
  final String originAccountId;
  final String email;

  DocsFromGmailDataModel({
    required this.gmailData,
    required this.syncMode,
    required this.connectorId,
    required this.accountId,
    required this.originAccountId,
    required this.email,
  });
}

List<Doc> docsFromGmailData(DocsFromGmailDataModel data) {
  List<Doc> result = [];

  for (var messageContent in data.gmailData) {
    result.add(Doc(
      id: const Uuid().v4(),
      title: messageContent?['subject'],
      originId: messageContent?['messageId'],
      searchText: "${messageContent?['subject']?.toLowerCase()} ${messageContent?['from']?.toLowerCase()}",
      description: null,
      icon: null,
      type: 'email',
      content: {
        "from": messageContent?['from'],
        "internalDate": messageContent?['internalDate'],
        "initialSyncMode": data.syncMode
      },
      url: "https://mail.google.com/mail/u/${data.email}/#all/${messageContent?['threadId']}",
      localUrl: null,
      // customType: null,
      // important: messageContent.internalDate,
      priority: 2,
      sorting: messageContent?['internalDate'],
      connectorId: data.connectorId,
      accountId: data.accountId,
      originAccountId: data.originAccountId,
    ));
  }

  return result;
}

List<Doc> prepareDocsForRemote<T>(PrepareDocForRemoteModel prepareDocForRemoteModel) {
  List<Doc> remoteDocs = prepareDocForRemoteModel.remoteItems.toList();

  for (int i = 0; i < remoteDocs.length; i++) {
    Doc remoteDoc = remoteDocs[i];

    String? updatedAt = remoteDoc.updatedAt;
    String? deletedAt = remoteDoc.deletedAt;

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

    Doc? localDoc = prepareDocForRemoteModel.existingItems.firstWhereOrNull((element) => element.id == remoteDoc.id);

    remoteDoc = remoteDoc.copyWith(
      id: remoteDoc.id ?? localDoc?.id,
      taskId: remoteDoc.taskId ?? localDoc?.taskId,
      globalUpdatedAt: maxDate?.toIso8601String(),
      globalCreatedAt: remoteDoc.createdAt,
    );

    remoteDocs[i] = remoteDoc;
  }

  return remoteDocs;
}

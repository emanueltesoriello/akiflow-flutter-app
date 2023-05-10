import 'dart:convert';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:models/base.dart';
import 'package:models/integrations/gmail.dart';
import 'package:models/nullable.dart';
import 'package:models/task/task.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:convert/convert.dart';
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
  try {
    List<dynamic> result = [];

    for (T item in items) {
      result.add((item as Base).toSql());
    }

    return result;
  } catch (e) {
    print(e);
    rethrow;
  }
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
    String? deletedAt = localItem is Task ? localItem.trashedAt : localItem.deletedAt;

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
  try {
    final SentryService sentryService = locator<SentryService>();

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
          remoteUpdatedAt: remoteUpdatedAt);

      if (existingModelsById.containsKey(remoteModel.id)) {
        int globalListIdUpdatedAtAtMillis = 0;
        int localListIdUpdatedAtAtMillis = 0;

        if (remoteModel.runtimeType == Task) {
          var remoteListIdUpdatedAt = remoteModel.globalListIdUpdatedAt;

          remoteModel = remoteModel.copyWith(remoteListIdUpdatedAt: remoteListIdUpdatedAt);

          if (remoteModel.globalListIdUpdatedAt != null) {
            globalListIdUpdatedAtAtMillis = DateTime.parse(remoteModel.globalListIdUpdatedAt).millisecondsSinceEpoch;
          }
          if (existingModelsById[remoteModel.id] != null &&
              existingModelsById[remoteModel.id].globalListIdUpdatedAt != null) {
            localListIdUpdatedAtAtMillis =
                DateTime.parse(existingModelsById[remoteModel.id]?.globalListIdUpdatedAt).millisecondsSinceEpoch;
          }
        }

        if (remoteGlobalUpdateAtMillis >= localUpdatedAtMillis) {
          if (remoteModel.runtimeType == Task) {
            if (globalListIdUpdatedAtAtMillis < localListIdUpdatedAtAtMillis) {
              try {
                Nullable<String?>? globalListIdUpdatedAt =
                    Nullable(existingModelsById[remoteModel.id]?.globalListIdUpdatedAt);
                Nullable<String?>? listId = Nullable(existingModelsById[remoteModel.id]?.listId.toString());
                Nullable<String?>? sectionId = Nullable(existingModelsById[remoteModel.id]?.sectionId);

                remoteModel = (remoteModel as Task).copyWith(
                    listId: listId,
                    sectionId: sectionId,
                    globalListIdUpdatedAt: globalListIdUpdatedAt,
                    remoteListIdUpdatedAt: existingModelsById[remoteModel.id]?.remoteListIdUpdatedAt);
              } catch (e) {
                print('Error on partitionItemsToUpsert 1');
                print(e);
                sentryService.captureException(e);
              }
            }
          }

          changedModels.add(remoteModel);
        } else {
          if (remoteModel.runtimeType == Task) {
            if (globalListIdUpdatedAtAtMillis > localListIdUpdatedAtAtMillis) {
              Nullable<String?>? globalListIdUpdatedAt = Nullable(remoteModel.globalListIdUpdatedAt);
              try {
                existingModelsById[remoteModel.id] = existingModelsById[remoteModel.id].copyWith(
                    listId: remoteModel.listId,
                    sectionId: remoteModel.sectionId,
                    globalListIdUpdatedAt: globalListIdUpdatedAt,
                    remoteListIdUpdatedAt: remoteModel.remoteListIdUpdatedAt);
              } catch (e) {
                print('Error on partitionItemsToUpsert 2');
                print(e);
                sentryService.captureException(e);
              }

              changedModels.add(existingModelsById[remoteModel.id]);
            } else {
              unchangedModels.add(existingModelsById[remoteModel.id]);
            }
          } else {
            unchangedModels.add(remoteModel);
          }
        }
      } else {
        if (remoteModel.runtimeType == Task) {
          remoteModel = remoteModel.copyWith(remoteListIdUpdatedAt: remoteModel.globalListIdUpdatedAt);
        }
        nonExistingModels.add(remoteModel);
      }
    }
    return [changedModels, unchangedModels, nonExistingModels];
  } catch (e) {
    print(e);
    rethrow;
  }
}

class DocsFromGmailDataModel {
  final List<GmailMessage> messages;
  final int syncMode;
  final String connectorId;
  final String accountId;
  final String originAccountId;
  final String email;

  DocsFromGmailDataModel({
    required this.messages,
    required this.syncMode,
    required this.connectorId,
    required this.accountId,
    required this.originAccountId,
    required this.email,
  });
}

getTitleString(String? title) {
  final codeUnits = title?.codeUnits;
  return const Utf8Decoder().convert(codeUnits ?? []);
}

generateMd5(String data) {
  var content = const Utf8Encoder().convert(data);
  var md5 = crypto.md5;
  var digest = md5.convert(content);
  return hex.encode(digest.bytes);
}

List<Task> payloadFromGmailData(DocsFromGmailDataModel data) {
  List<Task> result = [];

  for (GmailMessage messageContent in data.messages) {
    var doc = {
      "url": "https://mail.google.com/mail/u/${data.email}/#all/${messageContent.threadId}",
      "from": messageContent.from,
      "subject": messageContent.subject,
      "internal_date": messageContent.internalDate,
      "message_id": messageContent.id,
      "thread_id": messageContent.threadId,
    };
    String stringified = const JsonEncoder().convert(doc);
    String hash = generateMd5(stringified);

    doc.addAll({"hash": hash});

    result.add(Task(
      id: const Uuid().v4(),
      title: getTitleString(messageContent.subject),
      connectorId: Nullable(data.connectorId),
      originId: Nullable(messageContent.messageId),
      originAccountId: Nullable(data.originAccountId),
      doc: doc,
    ));
  }
  return result;
}

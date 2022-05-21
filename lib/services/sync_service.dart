import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobile/api/api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/exceptions/post_unsynced_exception.dart';
import 'package:mobile/exceptions/upsert_database_exception.dart';
import 'package:mobile/repository/database_repository.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:mobile/utils/converters_isolate.dart';

class SyncService {
  final SentryService _sentryService = locator<SentryService>();

  final ApiClient api;
  final DatabaseRepository databaseRepository;

  SyncService({
    required this.api,
    required this.databaseRepository,
  });

  // Returns the last sync time updated.
  Future<DateTime?> start(DateTime? lastSyncAt) async {
    setSyncStatusIfNotNull("${api.runtimeType} start syncing");

    DateTime? updatedLastSync = await _remoteToLocal(lastSyncAt);

    await _localToRemote();

    setSyncStatusIfNotNull("${api.runtimeType} completed sync at: $updatedLastSync");

    return updatedLastSync;
  }

  Future<DateTime?> _remoteToLocal(DateTime? lastSyncAt) async {
    setSyncStatusIfNotNull("${api.runtimeType} last sync at: $lastSyncAt, starting remote to local");

    var remoteItems = await api.getItems(
      perPage: 2500,
      withDeleted: lastSyncAt != null ? true : false,
      updatedAfter: lastSyncAt,
      allPages: true,
    );

    setSyncStatusIfNotNull("${api.runtimeType} remote to local retrieved: ${remoteItems.length} items");

    if (remoteItems.isEmpty) {
      return null;
    }

    DateTime? maxRemoteUpdateAt = await compute(getMaxUpdatedAt, remoteItems);

    setSyncStatusIfNotNull("${api.runtimeType} update lastSyncAt to $maxRemoteUpdateAt, upserting items to db");

    // Upsert only after retrieved max remote update at.
    await _upsertItems(remoteItems);

    return maxRemoteUpdateAt;
  }

  Future<void> _localToRemote() async {
    setSyncStatusIfNotNull("${api.runtimeType} starting local to remote, getting unsynced items");

    List<dynamic> unsynced = await databaseRepository.unsynced();

    setSyncStatusIfNotNull("${api.runtimeType} local to remote, sync ${unsynced.length} items");

    if (unsynced.isEmpty) {
      return;
    }

    unsynced = await compute(prepareItemsForRemote, unsynced);

    setSyncStatusIfNotNull("${api.runtimeType} posting to api ${unsynced.length} items");

    List<dynamic> updated = await api.post(unsynced: unsynced);

    if (unsynced.length != updated.length) {
      throw PostUnsyncedExcepotion(
        "${api.runtimeType} upserted ${unsynced.length} items, but ${updated.length} items were updated",
      );
    }

    setSyncStatusIfNotNull("${api.runtimeType} posted to api ${updated.length} items");

    if (updated.isNotEmpty) {
      await _upsertItems(updated);
    }

    setSyncStatusIfNotNull("${api.runtimeType} local to remote: done");
  }

  Future<void> _upsertItems<T>(List<dynamic> remoteItems) async {
    setSyncStatusIfNotNull("${api.runtimeType} upsert remote items: ${remoteItems.length} to db");

    bool anyInsertErrors = false;

    var result = [];

    List<dynamic> localIds = remoteItems.map((remoteItem) => remoteItem.id).toList();
    setSyncStatusIfNotNull("${api.runtimeType} localIds length: ${localIds.length}");

    List<T> existingModels = [];

    int sqlMaxVariableNumber = 999;

    if (localIds.length > sqlMaxVariableNumber) {
      List<List<dynamic>> chunks = [];

      for (var i = 0; i < localIds.length; i += sqlMaxVariableNumber) {
        List<dynamic> sublistWithMaxVariables = localIds.sublist(
            i, i + sqlMaxVariableNumber > localIds.length ? localIds.length : i + sqlMaxVariableNumber);
        chunks.add(sublistWithMaxVariables);
      }

      for (var chunk in chunks) {
        List<T> existingModelsChunk = await databaseRepository.getByIds(chunk);
        existingModels.addAll(existingModelsChunk);
      }
    } else {
      existingModels = await databaseRepository.getByIds(localIds);
    }

    setSyncStatusIfNotNull("${api.runtimeType} existingModels length: ${existingModels.length}");

    result = await compute(
        partitionItemsToUpsert, PartitioneItemModel(remoteItems: remoteItems, existingItems: existingModels));

    var changedModels = result[0];
    // var unchangedModels = result[1];
    var nonExistingModels = result[2];

    _sentryService.addBreadcrumb(
      category: "sync",
      message: "${api.runtimeType} changedModels length: ${changedModels.length}",
    );

    _sentryService.addBreadcrumb(
      category: "sync",
      message: "${api.runtimeType} nonExistingModels length: ${nonExistingModels.length}",
    );

    if (changedModels.isEmpty && nonExistingModels.isEmpty) {
      _sentryService.addBreadcrumb(
        category: "sync",
        message: "${api.runtimeType} no items to upsert",
      );
      return;
    }

    if (nonExistingModels.isNotEmpty) {
      anyInsertErrors = await _addRemoteTaskToLocalDb(nonExistingModels);
    }

    if (changedModels.isNotEmpty) {
      for (var item in changedModels) {
        await databaseRepository.updateById(item.id!, data: item);
      }
    }

    _sentryService.addBreadcrumb(
      category: "sync",
      message: '${api.runtimeType} anyInsertErrors: $anyInsertErrors',
    );

    if (anyInsertErrors) {
      _sentryService.captureException(UpsertDatabaseException("upsert items error"));
    }

    setSyncStatusIfNotNull("${api.runtimeType} upsert remote items: done");
  }

  Future<bool> _addRemoteTaskToLocalDb(itemsToInsert) async {
    List<Object?> result = await databaseRepository.add(itemsToInsert);

    _sentryService.addBreadcrumb(
      category: "sync",
      message: '${api.runtimeType} databaseRepository add result: ${result.length} items',
    );

    if (result.isEmpty) {
      throw UpsertDatabaseException('${api.runtimeType} result empty');
    }

    return false;
  }

  void setSyncStatusIfNotNull(String message) {
    print(message);
  }
}

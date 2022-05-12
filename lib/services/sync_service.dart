import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobile/api/api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/exceptions/api_exception.dart';
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
    setSyncStatusIfNotNull("last sync at: $lastSyncAt, starting remote to local");

    var remoteItems = await api.get(
      perPage: 2500,
      withDeleted: lastSyncAt != null ? true : false,
      updatedAfter: lastSyncAt,
      allPages: true,
    );

    setSyncStatusIfNotNull("remote to local retrieved: ${remoteItems.length} items");

    if (remoteItems.isEmpty) {
      return null;
    }

    DateTime? maxRemoteUpdateAt = await compute(getMaxUpdatedAt, remoteItems);

    setSyncStatusIfNotNull("${api.runtimeType}: update lastSyncAt to $maxRemoteUpdateAt, upserting items to db");

    // Upsert only after retrieved max remote update at.
    await _upsertItems(remoteItems);

    return maxRemoteUpdateAt;
  }

  Future<void> _localToRemote() async {
    setSyncStatusIfNotNull("starting local to remote, getting unsynced items");

    List<dynamic> unsynced = await databaseRepository.unsynced();

    setSyncStatusIfNotNull("local to remote, sync ${unsynced.length} items");

    if (unsynced.isEmpty) {
      return;
    }

    unsynced = await compute(prepareItemsForRemote, unsynced);

    try {
      setSyncStatusIfNotNull("posting to api ${unsynced.length} items");

      List<dynamic> updated = await api.post(unsynced: unsynced);

      setSyncStatusIfNotNull("posted to api ${updated.length} items");

      if (updated.isNotEmpty) {
        await _upsertItems(updated);
      }

      setSyncStatusIfNotNull("local to remote: done");
    } on ApiException catch (e) {
      setSyncStatusIfNotNull("error posting to api: ${e.message}");
    }
  }

  Future<void> _upsertItems<T>(List<dynamic> remoteItems) async {
    setSyncStatusIfNotNull("upsert remote items: ${remoteItems.length} to db");

    bool anyInsertErrors = false;

    var result = [];

    List<dynamic> localIds = remoteItems.map((remoteItem) => remoteItem.id).toList();
    List<dynamic> existingModels = await databaseRepository.getByIds(localIds);
    result = await compute(
        partitionItemsToUpsert, PartitioneItemModel(remoteItems: remoteItems, existingItems: existingModels));

    var changedModels = result[0];
    // var unchangedModels = result[1];
    var nonExistingModels = result[2];

    if (changedModels.isEmpty && nonExistingModels.isEmpty) {
      _sentryService.addBreadcrumb(
        category: "sync",
        message: "no items to upsert",
      );
      return;
    }
    _sentryService.addBreadcrumb(
      category: "sync",
      message: 'nonExistingModels length: ${nonExistingModels.length}, itemToUpdate length: ${changedModels.length}',
    );

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
      message: 'anyInsertErrors: $anyInsertErrors',
    );

    if (anyInsertErrors) {
      _sentryService.captureException(UpsertDatabaseException("upsert items error"));
    }

    setSyncStatusIfNotNull("upsert remote items: done");
  }

  Future<bool> _addRemoteTaskToLocalDb(itemsToInsert) async {
    try {
      List<Object?> result = await databaseRepository.add(itemsToInsert);

      _sentryService.addBreadcrumb(
        category: "sync",
        message: 'databaseRepository add result: ${result.length} items',
      );

      if (result.isEmpty) {
        throw UpsertDatabaseException('result empty');
      }
    } catch (e) {
      _sentryService.addBreadcrumb(
        category: "sync",
        message: '${api.runtimeType}: upsert item, exception: $e',
      );

      return true;
    }

    return false;
  }

  void setSyncStatusIfNotNull(String message) {
    print(message);
  }
}

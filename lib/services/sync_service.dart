import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobile/core/api/api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/exceptions/post_unsynced_exception.dart';
import 'package:mobile/exceptions/upsert_database_exception.dart';
import 'package:mobile/core/repository/database_repository.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:mobile/utils/converters_isolate.dart';
import 'package:models/extensions/account_ext.dart';

class SyncService {
  final SentryService _sentryService = locator<SentryService>();

  final ApiClient api;
  final DatabaseRepository databaseRepository;
  final Function()? hasDataToImport;

  SyncService({
    required this.api,
    required this.databaseRepository,
    this.hasDataToImport,
  });

  // Returns the last sync time updated.
  Future<DateTime?> start(DateTime? lastSyncAt) async {
    addBreadcrumb("${api.runtimeType} start syncing");

    DateTime? updatedLastSync = await _remoteToLocal(lastSyncAt);

    await _localToRemote();

    addBreadcrumb("${api.runtimeType} completed sync at: $updatedLastSync");

    return updatedLastSync;
  }

  Future<DateTime?> _remoteToLocal(DateTime? lastSyncAt) async {
    addBreadcrumb("${api.runtimeType} last sync at: $lastSyncAt, starting remote to local");

    var remoteItems = await api.getItems(
      perPage: 2500,
      withDeleted: lastSyncAt != null ? true : false,
      updatedAfter: lastSyncAt,
      allPages: true,
    );

    // Ignore other integrations
    try {
      // TODO remove when migrate to gmail v3
      if (api.runtimeType.toString() == "AccountApi") {
        remoteItems =
            remoteItems.where((element) => AccountExt.acceptedAccountsOrigin.contains(element.connectorId)).toList();
      }
    } catch (_) {}

    addBreadcrumb("${api.runtimeType} remote to local retrieved: ${remoteItems.length} items");

    if (remoteItems.isEmpty) {
      return null;
    }

    DateTime? maxRemoteUpdateAt = await compute(getMaxUpdatedAt, remoteItems);

    addBreadcrumb("${api.runtimeType} update lastSyncAt to $maxRemoteUpdateAt, upserting items to db");

    // Upsert only after retrieved max remote update at.
    bool hasDataToImportValue = await _upsertItems(remoteItems);

    if (hasDataToImportValue && hasDataToImport != null) {
      hasDataToImport!();
    }

    return maxRemoteUpdateAt;
  }

  Future<void> _localToRemote() async {
    addBreadcrumb("${api.runtimeType} starting local to remote, getting unsynced items");

    List<dynamic> unsynced = await databaseRepository.unsynced();

    addBreadcrumb("${api.runtimeType} local to remote, sync ${unsynced.length} items");

    // No post old v2 accounts
    try {
      if (api.runtimeType.toString() == "AccountV2Api") {
        unsynced = [];
      }
    } catch (_) {}

    try {
      // TODO remove when migrate to gmail v3
      if (api.runtimeType.toString() == "AccountApi") {
        unsynced =
            unsynced.where((element) => element.connectorId == "akiflow" || element.connectorId == "google").toList();
      }
    } catch (_) {}

    if (unsynced.isEmpty) {
      return;
    }

    unsynced = await compute(prepareItemsForRemote, unsynced);

    addBreadcrumb("${api.runtimeType} posting to api ${unsynced.length} items");

    List<dynamic> updated = await api.postUnsynced(unsynced: unsynced);

    if (unsynced.length != updated.length) {
      throw PostUnsyncedExcepotion(
        "${api.runtimeType} upserted ${unsynced.length} items, but ${updated.length} items were updated",
      );
    }

    addBreadcrumb("${api.runtimeType} posted to api ${updated.length} items");

    if (updated.isNotEmpty) {
      await _upsertItems(updated);
    }

    addBreadcrumb("${api.runtimeType} local to remote: done");
  }

  /// Return if there is data to import.
  Future<bool> _upsertItems<T>(List<dynamic> remoteItems) async {
    addBreadcrumb("${api.runtimeType} upsert remote items: ${remoteItems.length} to db");

    bool anyInsertErrors = false;

    var result = [];

    List<dynamic> localIds = remoteItems.map((remoteItem) => remoteItem.id).toList();
    addBreadcrumb("${api.runtimeType} localIds length: ${localIds.length}");

    List<T> existingModels = await databaseRepository.getByIds(localIds);
    addBreadcrumb("${api.runtimeType} existingModels length: ${existingModels.length}");

    result = await compute(
        partitionItemsToUpsert, PartitioneItemModel(remoteItems: remoteItems, existingItems: existingModels));

    var changedModels = result[0];
    // var unchangedModels = result[1];
    var nonExistingModels = result[2];

    addBreadcrumb("${api.runtimeType} changedModels length: ${changedModels.length}");
    addBreadcrumb("${api.runtimeType} nonExistingModels length: ${nonExistingModels.length}");

    if (changedModels.isEmpty && nonExistingModels.isEmpty) {
      addBreadcrumb("${api.runtimeType} no items to upsert");
      return false;
    }

    if (nonExistingModels.isNotEmpty) {
      anyInsertErrors = await _addRemoteTaskToLocalDb(nonExistingModels);
    }

    if (changedModels.isNotEmpty) {
      for (var item in changedModels) {
        await databaseRepository.updateById(item.id!, data: item);
      }
    }

    addBreadcrumb('${api.runtimeType} anyInsertErrors: $anyInsertErrors');

    if (anyInsertErrors) {
      _sentryService.captureException(UpsertDatabaseException("upsert items error"));
    }

    addBreadcrumb("${api.runtimeType} upsert remote items: done");

    return true;
  }

  Future<bool> _addRemoteTaskToLocalDb(itemsToInsert) async {
    List<Object?> result = await databaseRepository.add(itemsToInsert);

    addBreadcrumb('${api.runtimeType} databaseRepository add result: ${result.length} items');

    if (result.isEmpty) {
      throw UpsertDatabaseException('${api.runtimeType} result empty');
    }

    return false;
  }

  void addBreadcrumb(String message) {
    _sentryService.addBreadcrumb(category: "sync", message: message);
  }
}

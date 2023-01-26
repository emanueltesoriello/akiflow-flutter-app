import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobile/core/api/api.dart';
import 'package:mobile/core/exceptions/api_exception.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/exceptions/post_unsynced_exception.dart';
import 'package:mobile/core/exceptions/upsert_database_exception.dart';
import 'package:mobile/core/repository/database_repository.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:mobile/common/utils/converters_isolate.dart';
import 'package:models/account/account.dart';
import 'package:models/event/event.dart';
import 'package:models/extensions/account_ext.dart';
import 'package:models/nullable.dart';
import 'package:models/task/task.dart';

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

    if (unsynced.isEmpty) {
      return;
    }

    unsynced = await compute(prepareItemsForRemote, unsynced);

    addBreadcrumb("${api.runtimeType} posting to api ${unsynced.length} items");
    try {
      List<dynamic> updated = await api.postUnsynced(unsynced: unsynced);

      if (unsynced.length != updated.length) {
        throw PostUnsyncedExcepotion(
          "${api.runtimeType} upserted ${unsynced.length} items, but ${updated.length} items were updated",
        );
      }
      var up = updated[0];
      if (up is Task) {
        addBreadcrumb(up.toSql().toString());
      }

      addBreadcrumb("${api.runtimeType} posted to api ${updated.length} items");

      if (updated.isNotEmpty) {
        await _upsertItems(updated);
      }

      addBreadcrumb("${api.runtimeType} local to remote: done");
    } catch (e) {
      throw ApiException({"message": "Server Error", "errors": [e]});
    }
  }

  /// Return if there is data to import.
  Future<bool> _upsertItems<T>(List<dynamic> remoteItems) async {
    addBreadcrumb("${api.runtimeType} upsert remote items: ${remoteItems.length} to db");

    bool anyInsertErrors = false;

    var result = [];

    List<dynamic> localIds = remoteItems.map((remoteItem) => remoteItem.id).toList();

    addBreadcrumb("${api.runtimeType} localIds length: ${localIds.length}");

    List<T> existingModels;
    if (api.runtimeType.toString() == "AccountApi") {
      existingModels = await databaseRepository.getByItems(remoteItems);
    } else {
      existingModels = await databaseRepository.getByIds(localIds);
    }
    addBreadcrumb("${api.runtimeType} existingModels length: ${existingModels.length}");

    result = await compute(
        partitionItemsToUpsert, PartitioneItemModel(remoteItems: remoteItems, existingItems: existingModels));

    List changedModels = result[0];
    // var unchangedModels = result[1];
    List nonExistingModels = result[2];
    List valToBeDeleted = [];

    addBreadcrumb("${api.runtimeType} changedModels length: ${changedModels.length}");
    addBreadcrumb("${api.runtimeType} nonExistingModels length: ${nonExistingModels.length}");

    if (changedModels.isEmpty && nonExistingModels.isEmpty) {
      addBreadcrumb("${api.runtimeType} no items to upsert");
      return false;
    }
    //TODO optimize and refactor the code
    List val = [];
    if (nonExistingModels.isNotEmpty) {
      if (api.runtimeType.toString() == "AccountApi") {
        var nonExistingModelsCopy = [];
        nonExistingModelsCopy.addAll(nonExistingModels);
        for (var model in nonExistingModelsCopy) {
          try {
            var list = existingModels.cast<Account>().toList();
            val.addAll(list
                .where((element) =>
                    element.originAccountId == model.originAccountId && element.connectorId == model.connectorId)
                .toList());
          } catch (e) {
            print(e);
          }

          if (val.isNotEmpty) {
            valToBeDeleted.add(model);
          }
          if (valToBeDeleted.isNotEmpty) {
            for (var v in val) {
              await databaseRepository.removeById(v.id, data: val);
            }
          }
        }
      }
      if (api.runtimeType.toString() == "EventApi") {
        for (Event event in nonExistingModels) {
          if (event.recurringId != null && event.id != event.recurringId) {
            String? originalStartDateTimeColumn = event.originalStartDate != null
                ? 'original_start_date'
                : event.originalStartTime != null
                    ? 'original_start_time'
                    : null;
            if (originalStartDateTimeColumn != null) {
              addBreadcrumb('${api.runtimeType} recurring event instance by original start time. id: ${event.id}');

              Event? dbEvent;
              dbEvent = await databaseRepository.getRecurringByOriginalStart(
                  event.akiflowAccountId, event.calendarId, event.recurringId, originalStartDateTimeColumn);
              if (dbEvent != null) {
                await _prepareUpsertIfNewer(dbEvent: dbEvent, remoteEvent: event, eventIsNewer: false);
              }
            }
          }
        }
      }
      if (nonExistingModels.isNotEmpty) {
        anyInsertErrors = await _addRemoteTaskToLocalDb(nonExistingModels);
      }
    }

    if (changedModels.isNotEmpty) {
      if (api.runtimeType.toString() == "EventApi") {
        for (Event event in changedModels) {
          Event dbEvent = await databaseRepository.getById(event.id);
          await _prepareUpsertIfNewer(dbEvent: dbEvent, remoteEvent: event);
        }
      } else {
        for (var item in changedModels) {
          await databaseRepository.updateById(item.id!, data: item);
        }
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

  Future<void> _prepareUpsertIfNewer(
      {required Event dbEvent, required Event remoteEvent, bool eventIsNewer = true}) async {
    bool eventUpdatedInLocal = false;
    if (eventIsNewer) {
      if (dbEvent.globalUpdatedAt != null) {
        int dbRemoteUpdatedAtMillis = DateTime.parse(dbEvent.globalUpdatedAt!).millisecondsSinceEpoch;
        int dbUpdatedAtMillis = DateTime.parse(dbEvent.updatedAt!).millisecondsSinceEpoch;
        eventUpdatedInLocal = dbUpdatedAtMillis > dbRemoteUpdatedAtMillis;
      }

      bool isStale = remoteEvent.remoteUpdatedAt != dbEvent.updatedAt &&
          ((!eventUpdatedInLocal &&
                  DateTime.parse(remoteEvent.remoteUpdatedAt!).isBefore(DateTime.parse(dbEvent.updatedAt!))) ||
              (eventUpdatedInLocal &&
                  DateTime.parse(remoteEvent.remoteUpdatedAt!)
                      .isBefore(DateTime.parse(dbEvent.updatedAt!).add(const Duration(minutes: 5)))));

      if (isStale) {
        addBreadcrumb('${api.runtimeType} partially updating stale event with id: ${remoteEvent.id}');
        await _prepareUpdateStaleEvent(dbEvent: dbEvent, remoteEvent: remoteEvent);
      } else if (remoteEvent.recurrenceException != null && remoteEvent.oldId != null) {
        await databaseRepository.removeById(remoteEvent.oldId, data: remoteEvent);
      } else {
        await databaseRepository.updateById(remoteEvent.id!, data: remoteEvent);
      }
    }
    if (remoteEvent.id != dbEvent.id && !eventIsNewer) {
      addBreadcrumb('${api.runtimeType} partially updating event with id: ${remoteEvent.id}');
      await _prepareUpdateStaleEvent(dbEvent: dbEvent, remoteEvent: remoteEvent);
    }
  }

  Future<void> _prepareUpdateStaleEvent({required Event dbEvent, required Event remoteEvent}) async {
    Event steledEvent = dbEvent.copyWith(
      id: remoteEvent.id,
      recurringId: remoteEvent.recurringId ?? dbEvent.recurringId,
      originId: remoteEvent.originId,
      originRecurringId: remoteEvent.originRecurringId,
      etag: remoteEvent.etag,
      attendees: remoteEvent.attendees,
      meetingStatus: remoteEvent.meetingStatus,
      meetingUrl: remoteEvent.meetingUrl,
      meetingIcon: remoteEvent.meetingIcon,
      meetingSolution: remoteEvent.meetingSolution,
      originUpdatedAt: remoteEvent.originUpdatedAt,
      remoteUpdatedAt: Nullable(remoteEvent.remoteUpdatedAt),
      updatedAt: remoteEvent.recurringId != null ||
              remoteEvent.id == remoteEvent.recurringId ||
              dbEvent.recurrenceException != null
          ? Nullable(DateTime.now().toUtc().toIso8601String())
          : Nullable(dbEvent.updatedAt),
    );
    await databaseRepository.updateById(dbEvent.id!, data: steledEvent);
  }
}

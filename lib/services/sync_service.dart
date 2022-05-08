import 'dart:async';

import 'package:mobile/api/api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/exceptions/api_exception.dart';
import 'package:mobile/exceptions/upsert_database_exception.dart';
import 'package:mobile/repository/database_repository.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:models/doc/doc.dart';
import 'package:models/task/task.dart';

class SyncService {
  final SentryService _sentryService = locator<SentryService>();

  final Api api;
  final DatabaseRepository databaseRepository;

  Function(String)? _setSyncStatus;

  SyncService({
    required this.api,
    required this.databaseRepository,
  });

  // Returns the last sync time updated.
  Future<DateTime?> start(
    DateTime? lastSyncAt, {
    required Function(String) setSyncStatus,
  }) async {
    _setSyncStatus = setSyncStatus;

    setSyncStatusIfNotNull("${api.runtimeType} start syncing");

    DateTime? updatedLastSync = await _remoteToLocal(lastSyncAt);

    await _localToRemote();

    setSyncStatusIfNotNull(
        "${api.runtimeType} completed sync at: $updatedLastSync");

    return updatedLastSync;
  }

  Future<DateTime?> _remoteToLocal(DateTime? lastSyncAt) async {
    setSyncStatusIfNotNull(
        "last sync at: $lastSyncAt, starting remote to local");

    var remoteItems = await api.get(
      perPage: 2500,
      withDeleted: true,
      updatedAfter: lastSyncAt,
      allPages: true,
    );

    setSyncStatusIfNotNull(
        "remote to local retrieved: ${remoteItems.length} items");

    if (remoteItems.isEmpty) {
      return null;
    }

    DateTime? maxRemoteUpdateAt;

    for (var item in remoteItems) {
      DateTime? newUpdatedAt = item.updatedAt;

      if (maxRemoteUpdateAt == null ||
          (newUpdatedAt != null && newUpdatedAt.isAfter(maxRemoteUpdateAt))) {
        maxRemoteUpdateAt = newUpdatedAt;
      }
    }

    setSyncStatusIfNotNull(
        "${api.runtimeType}: update lastSyncAt to $maxRemoteUpdateAt, upserting items to db");

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

    for (int i = 0; i < unsynced.length; i++) {
      var item = unsynced[i];

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

      unsynced[i] = item;
    }

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
    List<dynamic> localItems = await databaseRepository.get();

    setSyncStatusIfNotNull("upsert remote items: ${remoteItems.length} to db");

    bool anyInsertErrors = false;

    for (int i = 0; i < remoteItems.length; i++) {
      var remoteItem = remoteItems[i];

      bool hasAlreadyInLocalDatabase =
          localItems.any((element) => element.id == remoteItem.id);

      if (hasAlreadyInLocalDatabase) {
        var localTask =
            localItems.firstWhere((element) => element.id == remoteItem.id);

        int remoteGlobalUpdateAtMillis =
            remoteItem.globalUpdatedAt?.millisecondsSinceEpoch ?? 0;
        int localUpdatedAtMillis =
            localTask.updatedAt?.millisecondsSinceEpoch ?? 0;

        if (remoteGlobalUpdateAtMillis >= localUpdatedAtMillis) {
          if (remoteItem is Doc || remoteItem is Task) {
            remoteItem = remoteItem.copyWith(
              globalUpdatedAt: remoteItem.globalUpdatedAt,
              updatedAt: remoteItem.globalUpdatedAt,
            );
          } else {
            remoteItem = remoteItem.rebuild((t) {
              t.updatedAt = remoteItem.globalUpdatedAt;
              t.remoteUpdatedAt = remoteItem.globalUpdatedAt;
            });
          }

          remoteItems[i] = remoteItem;

          await databaseRepository.updateById(remoteItem.id!, data: remoteItem);
        } else {
          _sentryService.addBreadcrumb(
            category: "sync",
            message:
                '${api.runtimeType}: skip upsert item, remote is not recent than local',
          );
        }
      } else {
        if (remoteItem is Doc || remoteItem is Task) {
          remoteItem = remoteItem.copyWith(
            globalUpdatedAt: remoteItem.globalUpdatedAt,
            updatedAt: remoteItem.globalUpdatedAt,
          );
        } else {
          remoteItem = remoteItem.rebuild((t) {
            t.updatedAt = remoteItem.globalUpdatedAt;
            t.remoteUpdatedAt = remoteItem.globalUpdatedAt;
          });
        }

        remoteItems[i] = remoteItem;

        anyInsertErrors = await _addRemoteTaskToLocalDb(remoteItem);
      }
    }

    if (anyInsertErrors) {
      _sentryService
          .captureException(UpsertDatabaseException("upsert items error"));
    }

    setSyncStatusIfNotNull("upsert remote items: done");
  }

  Future<bool> _addRemoteTaskToLocalDb(remoteItem) async {
    try {
      List<Object?> result = await databaseRepository.add([remoteItem]);

      if (result.isEmpty) {
        throw UpsertDatabaseException('result empty');
      }
    } catch (e) {
      _sentryService.addBreadcrumb(
        category: "sync",
        message: '${api.runtimeType}: upsert item $remoteItem, exception: $e',
      );

      return true;
    }

    return false;
  }

  void setSyncStatusIfNotNull(String message) {
    if (_setSyncStatus != null) {
      _setSyncStatus!(message);
    }
  }
}

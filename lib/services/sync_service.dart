import 'dart:async';

import 'package:mobile/api/api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/exceptions/api_exception.dart';
import 'package:mobile/repository/database_repository.dart';
import 'package:mobile/services/sentry_service.dart';

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

    DateTime? updatedLastSync = await _remoteToLocal(lastSyncAt);

    await _localToRemote();

    setSyncStatusIfNotNull("completed sync at: $updatedLastSync");

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

      item = item.rebuild((t) {
        t.globalUpdatedAt = maxDate ?? DateTime.now().toUtc();
        t.updatedAt = maxDate ?? DateTime.now().toUtc();
      });

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
          remoteItem = remoteItem.rebuild((t) {
            t.updatedAt = remoteItem.globalUpdatedAt;
            t.remoteUpdatedAt = remoteItem.globalUpdatedAt;
          });

          remoteItems[i] = remoteItem;

          await _updateLocalTask(id: remoteItem.id!, remoteItem: remoteItem);
        } else {
          _sentryService.addBreadcrumb(
            category: "sync",
            message:
                '${api.runtimeType}: skip upsert item, remote is not recent than local',
          );
        }
      } else {
        remoteItem = remoteItem.rebuild((t) {
          t.updatedAt = remoteItem.globalUpdatedAt;
          t.remoteUpdatedAt = remoteItem.globalUpdatedAt;
        });

        remoteItems[i] = remoteItem;

        await _addRemoteTaskToLocalDb(remoteItem);
      }
    }

    setSyncStatusIfNotNull("upsert remote items: done");
  }

  Future<void> _updateLocalTask(
      {required String id, required var remoteItem}) async {
    await databaseRepository.updateById(id, data: remoteItem);
  }

  Future<void> _addRemoteTaskToLocalDb(var remoteItem) async {
    await databaseRepository.add([remoteItem]);
  }

  void setSyncStatusIfNotNull(String message) {
    if (_setSyncStatus != null) {
      _setSyncStatus!(message);
    }
  }
}

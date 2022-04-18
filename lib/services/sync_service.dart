import 'dart:async';

import 'package:mobile/api/api.dart';
import 'package:mobile/exceptions/api_exception.dart';
import 'package:mobile/repository/database_repository.dart';

class SyncService {
  final Api api;
  final DatabaseRepository databaseRepository;

  SyncService({
    required this.api,
    required this.databaseRepository,
  });

  // Returns the last sync time updated.
  Future<DateTime?> start(DateTime? lastSyncAt) async {
    print('${api.runtimeType}: start sync');

    DateTime? updatedLastSync = await _remoteToLocal(lastSyncAt);

    await _localToRemote();

    return updatedLastSync;
  }

  Future<DateTime?> _remoteToLocal(DateTime? lastSyncAt) async {
    print('${api.runtimeType}: remote to local lastSync $lastSyncAt');

    var remoteItems = await api.get(
      perPage: 2500,
      withDeleted: true,
      updatedAfter: lastSyncAt,
      allPages: true,
    );

    if (remoteItems.isEmpty) {
      return null;
    } else {
      print(
          '${api.runtimeType}: remote to local: ${remoteItems.length} items to sync');
    }

    int maxRemoteUpdateAtMillis = 0;

    for (var item in remoteItems) {
      int newUpdatedAtMillis = item.updatedAt?.millisecondsSinceEpoch ?? 0;

      if (newUpdatedAtMillis > maxRemoteUpdateAtMillis) {
        maxRemoteUpdateAtMillis = newUpdatedAtMillis;
      }
    }

    print('${api.runtimeType}: remote to local item: ${remoteItems.length}');

    await _upsertItems(remoteItems);

    DateTime? lastSyncAtUpdated;

    if (maxRemoteUpdateAtMillis != 0) {
      lastSyncAtUpdated =
          DateTime.fromMillisecondsSinceEpoch(maxRemoteUpdateAtMillis).toUtc();
    }

    print('${api.runtimeType}: update lastSyncAt to $lastSyncAtUpdated');

    return lastSyncAtUpdated;
  }

  Future<void> _localToRemote() async {
    print('${api.runtimeType}: local to remote');

    List<dynamic> unsynced = await databaseRepository.unsynced();

    if (unsynced.isEmpty) {
      print('${api.runtimeType}: local no data to sync');
      return;
    } else {
      print(
          '${api.runtimeType}: local to remote: ${unsynced.length} items to sync');
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
        t.globalUpdatedAt = maxDate;
      });

      unsynced[i] = item;
    }

    try {
      List<dynamic> updated = await api.post(unsynced: unsynced);

      await _upsertItems(updated);

      print('${api.runtimeType}: local to remote: done');
    } on ApiException catch (e) {
      print('${api.runtimeType}: ${e.runtimeType}: ${e.message}');
    }
  }

  Future<void> _upsertItems<T>(List<dynamic> remoteItems) async {
    List<dynamic> localItems = await databaseRepository.get();

    for (int i = 0; i < remoteItems.length; i++) {
      var remoteItem = remoteItems[i];

      bool hasAlreadyInLocalDatabase =
          localItems.any((element) => element.id == remoteItem.id);

      if (hasAlreadyInLocalDatabase) {
        var localTask =
            localItems.firstWhere((element) => element.id == remoteItem.id);

        DateTime? remoteGlobalUpdateAt = remoteItem.globalUpdatedAt;
        DateTime? localUpdatedAt = localTask.updatedAt;

        bool notYetUpdated =
            localUpdatedAt == null || remoteGlobalUpdateAt == null;

        bool remoteItemIsRecentThanLocal = notYetUpdated ||
            remoteGlobalUpdateAt.isAfter(localUpdatedAt) ||
            remoteGlobalUpdateAt.isAtSameMomentAs(localUpdatedAt);

        if (remoteItemIsRecentThanLocal) {
          remoteItem = remoteItem.rebuild((t) {
            t.updatedAt = remoteGlobalUpdateAt;
            t.remoteUpdatedAt = remoteGlobalUpdateAt;
          });

          remoteItems[i] = remoteItem;

          await _updateLocalTask(id: remoteItem.id!, remoteItem: remoteItem);
        } else {
          print(
              '${api.runtimeType}: skip upsert item, remote is not recent than local');
        }
      } else {
        await _addRemoteTaskToLocalDb(remoteItem);
      }
    }
  }

  Future<void> _updateLocalTask(
      {required String id, required var remoteItem}) async {
    await databaseRepository.updateById(id, data: remoteItem);
  }

  Future<void> _addRemoteTaskToLocalDb(var remoteItem) async {
    await databaseRepository.add([remoteItem]);
  }
}

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
    print('${api.runtimeType}: start sync, last sync at: $lastSyncAt');

    DateTime? updatedLastSync = await _remoteToLocal(lastSyncAt);

    await _localToRemote();

    return updatedLastSync;
  }

  Future<DateTime?> _remoteToLocal(DateTime? lastSyncAt) async {
    var remoteItems = await api.get(
      perPage: 2500,
      withDeleted: true,
      updatedAfter: lastSyncAt,
      allPages: true,
    );

    if (remoteItems.isEmpty) {
      print('${api.runtimeType}: remote to local no items');
      return null;
    }

    print('${api.runtimeType}: remote to local item: ${remoteItems.length}');

    DateTime? maxRemoteUpdateAt;

    for (var item in remoteItems) {
      DateTime? newUpdatedAt = item.updatedAt;

      if (maxRemoteUpdateAt == null ||
          (newUpdatedAt != null && newUpdatedAt.isAfter(maxRemoteUpdateAt))) {
        maxRemoteUpdateAt = newUpdatedAt;
      }
    }

    print('${api.runtimeType}: update lastSyncAt to $maxRemoteUpdateAt');

    // Upsert only after retrieved max remote update at.
    await _upsertItems(remoteItems);

    return maxRemoteUpdateAt;
  }

  Future<void> _localToRemote() async {
    List<dynamic> unsynced = await databaseRepository.unsynced();

    if (unsynced.isEmpty) {
      print('${api.runtimeType}: local to remote no items');
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
        t.globalUpdatedAt = maxDate ?? DateTime.now().toUtc();
        t.updatedAt = maxDate ?? DateTime.now().toUtc();
      });

      unsynced[i] = item;
    }

    try {
      List<dynamic> updated = await api.post(unsynced: unsynced);

      if (updated.isNotEmpty) {
        await _upsertItems(updated);
      }

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
          print(
              '${api.runtimeType}: skip upsert item, remote is not recent than local');
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
  }

  Future<void> _updateLocalTask(
      {required String id, required var remoteItem}) async {
    await databaseRepository.updateById(id, data: remoteItem);
  }

  Future<void> _addRemoteTaskToLocalDb(var remoteItem) async {
    await databaseRepository.add([remoteItem]);
  }
}

import 'dart:async';

import 'package:mobile/api/api.dart';
import 'package:mobile/exceptions/api_exception.dart';
import 'package:mobile/repository/database_repository.dart';

class SyncService {
  final Api api;
  final DatabaseRepository databaseRepository;
  final DateTime? Function() getLastUpdate;
  final Function(DateTime) setLastUpdate;

  SyncService({
    required this.api,
    required this.databaseRepository,
    required this.getLastUpdate,
    required this.setLastUpdate,
  });

  Future<void> start() async {
    print('--- ${api.runtimeType}, start sync ---');

    await _remoteToLocal();
    await _localToRemote();
  }

  Future<void> _remoteToLocal() async {
    DateTime? lastSyncAt = getLastUpdate();

    var remoteItems = await api.get(
      perPage: 2500,
      withDeleted: true,
      updatedAfter: lastSyncAt,
      allPages: true,
    );

    if (remoteItems.isEmpty) {
      return;
    } else {
      print('remote to local: ${remoteItems.length} items to sync');
    }

    DateTime maxRemoteUpdatedAt = DateTime.fromMillisecondsSinceEpoch(0);

    for (var item in remoteItems) {
      DateTime remoteTaskUpdatedAt = item.updatedAt;
      if (remoteTaskUpdatedAt.isAfter(maxRemoteUpdatedAt)) {
        maxRemoteUpdatedAt = remoteTaskUpdatedAt;
      }
    }

    await _upsertItems(remoteItems);

    await setLastUpdate(maxRemoteUpdatedAt);
  }

  Future<void> _localToRemote() async {
    List<dynamic> unsynced = await databaseRepository.unsynced();

    if (unsynced.isEmpty) {
      return;
    } else {
      print('local to remote: ${unsynced.length} items to sync');
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
        t.remoteUpdatedAt = maxDate;
        t.globalUpdatedAt = maxDate;
      });

      unsynced[i] = item;
    }

    try {
      print("local to remote: ${unsynced.length} items to sync");

      List<dynamic> updated = await api.post(unsynced: unsynced);

      await _upsertItems(updated);

      print("local to remote: done");
    } on ApiException catch (e) {
      print(e);
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

        bool remoteItemIsRecentThanLocal =
            notYetUpdated || remoteGlobalUpdateAt.isAfter(localUpdatedAt);

        if (remoteItemIsRecentThanLocal) {
          remoteItem = remoteItem.rebuild((t) {
            t.updatedAt = remoteGlobalUpdateAt;
            t.remoteUpdatedAt = remoteGlobalUpdateAt;
          });

          remoteItems[i] = remoteItem;

          await _updateLocalTask(id: localTask.id!, remoteItem: remoteItem);

          print('save item to db: ${remoteItem.id}');
        } else {
          print("skip upsert item, remote is not recent than local");
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

import 'dart:async';

import 'package:mobile/api/api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/exceptions/api_exception.dart';
import 'package:mobile/repository/accounts_repository.dart';
import 'package:mobile/repository/database_repository.dart';
import 'package:models/account/account.dart';

class SyncService {
  // need to check last sync time
  final AccountsRepository _accountsRepository = locator<AccountsRepository>();

  final Account akiflowAccount;
  final Api api;
  final DatabaseRepository databaseRepository;

  SyncService({
    required this.akiflowAccount,
    required this.api,
    required this.databaseRepository,
  });

  Future<void> start() async {
    print(
        'start sync entity ${api.runtimeType} id ${akiflowAccount.connectorId}');

    await _remoteToLocal();
    await _localToRemote();
  }

  Future<void> _remoteToLocal() async {
    DateTime? lastSyncAt = await getLocalLastSync();

    var remoteItems = await api.get(
      perPage: 2500,
      withDeleted: true,
      updatedAfter: lastSyncAt,
      allPages: true,
    );

    if (remoteItems.isEmpty) {
      print('No remote items to sync');
      return;
    }

    List<dynamic> localItems = await databaseRepository.get();

    for (var remoteItem in remoteItems) {
      bool hasAlreadyInLocalDatabase =
          localItems.any((element) => element.id == remoteItem.id);

      // check if remote item is already in local database
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

          await _updateLocalTask(id: localTask.id!, remoteItem: remoteItem);
        }
      } else {
        await _addRemoteTaskToLocalDb(remoteItem);
      }
    }

    if (remoteItems.any((element) => element.updatedAt != null)) {
      var maxRemoteTasksUpdatedAt = remoteItems
          .map((element) => element.updatedAt)
          .reduce((value, element) => value.isAfter(element) ? value : element);

      await updateLocalLastSyncAt(maxRemoteTasksUpdatedAt);
    }
  }

  Future<void> _localToRemote() async {
    List<dynamic> unsynced = await databaseRepository.unsynced();

    if (unsynced.isEmpty) {
      print('No local items to sync');
      return;
    }

    for (var item in unsynced) {
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
        t.updatedAt = maxDate;
        t.remoteUpdatedAt = maxDate;
      });
    }

    try {
      List<dynamic> updated = await api.post(unsynced: unsynced);

      print("updated: ${updated.length}");
    } on ApiException catch (e) {
      print(e);
    }
  }

  Future<DateTime?> getLocalLastSync() async {
    Account localAccount = await _accountsRepository.byId(akiflowAccount.id!);
    return localAccount.localDetails?.lastAccountsSyncAt;
  }

  Future<void> updateLocalLastSyncAt(DateTime? date) async {
    Account localAccount = await _accountsRepository.byId(akiflowAccount.id!);

    localAccount = localAccount.rebuild((t) {
      t.localDetails.lastTasksSyncAt = date;
    });

    await _accountsRepository.updateById(
      localAccount.id.toString(),
      data: localAccount,
    );
  }

  Future<void> _updateLocalTask(
      {required String id, required var remoteItem}) async {
    print("update local item: ${remoteItem.id}");
    await databaseRepository.updateById(id, data: remoteItem);
  }

  Future<void> _addRemoteTaskToLocalDb(var remoteItem) async {
    print("does not exist locally, add it");
    await databaseRepository.add([remoteItem]);
  }
}

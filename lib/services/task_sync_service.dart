import 'dart:async';

import 'package:mobile/api/tasks_api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/exceptions/api_exception.dart';
import 'package:mobile/repository/accounts_repository.dart';
import 'package:mobile/repository/tasks_repository.dart';
import 'package:models/account/account.dart';
import 'package:models/task/task.dart';

class TaskSyncService {
  final TasksApi _tasksApi = locator<TasksApi>();
  final TasksRepository _tasksRepository = locator<TasksRepository>();
  final AccountsRepository _accountsRepository = locator<AccountsRepository>();

  final Account account;

  TaskSyncService({required this.account});

  Future<void> start() async {
    await _remoteToLocal();
    await _localToRemote();
  }

  Future<void> _remoteToLocal() async {
    DateTime? lastSyncAt = await getRemoteUpdatedAt();

    // TODO read all paginated response
    List<Task> remoteItems = await _tasksApi.all(
      updatedAfter: lastSyncAt,
      allPages: true,
    );

    if (remoteItems.isEmpty) {
      print('No remote tasks to sync');
      return;
    }

    List<Task> localItems = await _tasksRepository.tasks();

    for (Task remoteItem in remoteItems) {
      bool hasAlreadyInLocalDatabase =
          localItems.any((element) => element.id == remoteItem.id);

      // check if remote task is already in local database
      if (hasAlreadyInLocalDatabase) {
        Task localTask =
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
      Task maxRemoteTasksUpdatedAt = remoteItems.reduce((t1, t2) {
        if (t1.updatedAt == null) return t2;
        if (t2.updatedAt == null) return t1;
        return t1.updatedAt!.isAfter(t2.updatedAt!) ? t1 : t2;
      });

      await updateLocalLastSyncAt(maxRemoteTasksUpdatedAt.updatedAt);
    }
  }

  Future<void> _localToRemote() async {
    List<Task> unsynced = await _tasksRepository.unsynced();

    if (unsynced.isEmpty) {
      print('No local tasks to sync');
      return;
    }

    for (Task item in unsynced) {
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
      List<Task> updated = await _tasksApi.post(unsynced);

      print("updated: ${updated.length}");
    } on ApiException catch (e) {
      print(e);
    }
  }

  Future<DateTime?> getRemoteUpdatedAt() async {
    Account localAccount = await _accountsRepository.byId(account.id!);
    return localAccount.localDetails?.lastAccountsSyncAt;
  }

  Future<void> updateLocalLastSyncAt(DateTime? date) async {
    Account localAccount = await _accountsRepository.byId(account.id!);

    localAccount = localAccount.rebuild((t) {
      t.localDetails.lastTasksSyncAt = date;
    });

    await _accountsRepository.updateById(
      localAccount.id.toString(),
      data: localAccount,
    );
  }

  Future<void> _updateLocalTask(
      {required String id, required Task remoteItem}) async {
    print("update local task: ${remoteItem.title}");
    await _tasksRepository.updateById(id, data: remoteItem);
  }

  Future<void> _addRemoteTaskToLocalDb(Task remoteItem) async {
    print("does not exist locally, add it");
    await _tasksRepository.add([remoteItem]);
  }
}

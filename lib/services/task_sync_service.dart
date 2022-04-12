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
    List<Task> remoteTasks = await _tasksApi.all(updatedAfter: lastSyncAt);

    if (remoteTasks.isEmpty) {
      print('No remote tasks to sync');
      return;
    }

    List<Task> localTasks = await _tasksRepository.tasks();

    for (Task remoteTask in remoteTasks) {
      bool hasAlreadyInLocalDatabase =
          localTasks.any((element) => element.id == remoteTask.id);

      // check if remote task is already in local database
      if (hasAlreadyInLocalDatabase) {
        Task localTask =
            localTasks.firstWhere((element) => element.id == remoteTask.id);

        DateTime? remoteGlobalUpdateAt = remoteTask.globalUpdatedAt;
        DateTime? localUpdatedAt = localTask.updatedAt;

        bool notYetUpdated =
            localUpdatedAt == null || remoteGlobalUpdateAt == null;

        bool remoteTaskIsRecentThanLocal =
            notYetUpdated || remoteGlobalUpdateAt.isAfter(localUpdatedAt);

        if (remoteTaskIsRecentThanLocal) {
          remoteTask = remoteTask.rebuild((t) {
            t.updatedAt = remoteGlobalUpdateAt;
            t.remoteUpdatedAt = remoteGlobalUpdateAt;
          });

          await _updateLocalTask(id: localTask.id!, remoteTask: remoteTask);
        }
      } else {
        await _addRemoteTaskToLocalDb(remoteTask);
      }
    }

    if (remoteTasks.any((element) => element.updatedAt != null)) {
      Task maxRemoteTasksUpdatedAt = remoteTasks.reduce((t1, t2) {
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

    for (Task task in unsynced) {
      DateTime? updatedAt = task.updatedAt;
      DateTime? deletedAt = task.deletedAt;

      DateTime? maxDate;

      if (updatedAt != null && deletedAt != null) {
        maxDate = updatedAt.isAfter(deletedAt) ? updatedAt : deletedAt;
      } else if (updatedAt != null) {
        maxDate = updatedAt;
      } else if (deletedAt != null) {
        maxDate = deletedAt;
      }

      task = task.rebuild((t) {
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
      {required String id, required Task remoteTask}) async {
    print("update local task: ${remoteTask.title}");
    await _tasksRepository.updateById(id, data: remoteTask);
  }

  Future<void> _addRemoteTaskToLocalDb(Task remoteTask) async {
    print("does not exist locally, add it");
    await _tasksRepository.add([remoteTask]);
  }
}

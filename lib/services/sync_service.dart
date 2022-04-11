import 'dart:async';

import 'package:mobile/api/tasks_api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/repository/tasks_repository.dart';
import 'package:models/task/task.dart';

class SyncService {
  final TasksApi _tasksApi = locator<TasksApi>();
  final TasksRepository _tasksRepository = locator<TasksRepository>();

  SyncService();

  Future<void> start() async {
    // Remote updated tasks to local
    await _syncRemoteTasks();

    // Local unsynced tasks to remote
    await _syncLocalTasks();
  }

  Future<void> _syncRemoteTasks() async {
    DateTime lastSyncAt = DateTime.now()
        .subtract(const Duration(days: 30)); // TODO retrieve from account table

    List<Task> remoteTasks = await _tasksApi.all(
        updatedAfter: lastSyncAt); // TODO read all paginated response

    if (remoteTasks.isNotEmpty) {
      List<Task> localTasks = await _tasksRepository.tasks();

      for (Task remoteTask in remoteTasks) {
        // check if remote task is already in local database
        if (localTasks.any((element) => element.id == remoteTask.id)) {
          Task localTask =
              localTasks.firstWhere((element) => element.id == remoteTask.id);

          DateTime? remoteUpdatedAt = remoteTask.updatedAt;
          DateTime? localUpdatedAt = localTask.updatedAt;

          bool remoteTaskIsRecentThanLocal = remoteUpdatedAt != null &&
              localUpdatedAt != null &&
              remoteUpdatedAt.isAfter(localUpdatedAt);

          if (remoteTaskIsRecentThanLocal) {
            await _updateLocalTask(id: localTask.id!, remoteTask: remoteTask);
          }
        } else {
          await _addRemoteTaskToLocalDb(remoteTask);
        }
      }
    }

    // TODO update lastSyncAt in db of account table

    // TODO update globalUpdatedAt remote account
  }

  Future<void> _updateLocalTask(
      {required String id, required Task remoteTask}) async {
    print("update local task");
    await _tasksRepository.updateById(id, data: remoteTask);
  }

  Future<void> _addRemoteTaskToLocalDb(Task remoteTask) async {
    print("does not exist locally, add it");
    await _tasksRepository.add([remoteTask]);
  }

  Future<void> _syncLocalTasks() async {
    List<Task> unsynced = await _tasksRepository.unsynced();

    if (unsynced.isNotEmpty) {
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

      print("sync local tasks: ${unsynced.length}");

      await _tasksApi.post(unsynced);
    }
  }
}

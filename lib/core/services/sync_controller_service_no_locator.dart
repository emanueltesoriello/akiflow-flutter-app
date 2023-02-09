import 'dart:async';
import 'dart:convert';
import 'package:mobile/core/api/task_api.dart';
import 'package:mobile/core/repository/tasks_repository.dart';
import 'package:mobile/core/services/analytics_service.dart';
import 'package:mobile/core/services/sync_service.dart';
import 'package:models/task/task.dart';
import 'package:models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Entity { accounts, calendars, tasks, labels, events, docs }

enum IntegrationEntity { gmail }

class SyncControllerServiceNoLocator {
  final SharedPreferences _prefs;
  SyncControllerServiceNoLocator(this._prefs);

  sync([List<Entity>? entities]) async {
    print("started sync");

    final userString = _prefs.getString("user");

    if (userString == null) {
      return null;
    }

    User? user = User.fromMap(jsonDecode(userString));

    if (user != null) {
      //AnalyticsService.track("Trigger sync now");

      await _syncEntity(Entity.tasks);

      // check after docs sync to prevent docs duplicates

    }
  }

  final Map<Entity, SyncService> _syncServices = {
    Entity.tasks: SyncService(
      api: TaskApi(),
      databaseRepository: TasksRepository(fromSql: Task.fromSql),
      hasDataToImport: () async {
        AnalyticsService.track('Tasks imported');
      },
    ),
  };

  Future<void> _syncEntity(Entity entity) async {
    try {
      print("Syncing $entity...");

      SyncService syncService = _syncServices[entity]!;

      String? value = _prefs.getString("lastTasksSyncAt");
      DateTime? lastSync = value == null ? null : DateTime.parse(value);

      DateTime? lastSyncUpdated = await syncService.start(lastSync);

      if (lastSyncUpdated != null) {
        await _prefs.setString("lastTasksSyncAt", lastSyncUpdated.toIso8601String());
      }
    } catch (e, s) {
      print(e);
    }
  }
}

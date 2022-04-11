import 'package:get_it/get_it.dart';
import 'package:mobile/api/auth_api.dart';
import 'package:mobile/api/tasks_api.dart';
import 'package:mobile/core/http_client.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/repository/tasks_repository.dart';
import 'package:mobile/services/dialog_service.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:mobile/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqlite_api.dart';

GetIt locator = GetIt.instance;

void setupLocator({
  required SharedPreferences preferences,
  required Database database,
}) {
  PreferencesRepository preferencesRepository =
      PreferencesRepositoryImpl(preferences);

  /// Core
  locator.registerSingleton<HttpClient>(HttpClient(preferencesRepository));

  /// Utils
  locator.registerLazySingleton(() => DialogService());

  /// Apis
  locator.registerSingleton<AuthApi>(AuthApi());
  locator.registerSingleton<TasksApi>(TasksApi());

  /// Repositories
  locator.registerSingleton<PreferencesRepository>(preferencesRepository);
  locator.registerSingleton<TasksRepository>(TasksRepository(database));

  /// Services
  locator.registerSingleton<SentryService>(SentryService());
  locator.registerSingleton<SyncService>(SyncService());
}

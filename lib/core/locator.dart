import 'package:get_it/get_it.dart';
import 'package:mobile/core/http_client.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/repository/auth.dart';
import 'package:mobile/repository/tasks.dart';
import 'package:mobile/services/dialog_service.dart';
import 'package:mobile/services/local_database_service.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:mobile/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

GetIt locator = GetIt.instance;

void setupLocator(SharedPreferences preferences) {
  PreferencesRepository preferencesRepository =
      PreferencesRepositoryImpl(preferences);

  /// Core
  locator.registerSingleton<HttpClient>(HttpClient(preferencesRepository));

  /// Utils
  locator.registerLazySingleton(() => DialogService());

  /// Services
  locator.registerSingleton<SentryService>(SentryService());
  locator.registerSingleton<LocalDatabaseService>(LocalDatabaseService());
  locator.registerSingleton<SyncService>(SyncService());

  /// Repositories
  locator.registerSingleton<PreferencesRepository>(preferencesRepository);
  locator.registerSingleton<AuthRepository>(AuthRepository());
  locator.registerSingleton<TasksRepository>(TasksRepository());
}

import 'package:get_it/get_it.dart';
import 'package:mobile/repository/local_storage_repository.dart';
import 'package:mobile/repository/preferences_repository.dart';
import 'package:mobile/services/dialog_service.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:sembast/sembast.dart';
import 'package:shared_preferences/shared_preferences.dart';

GetIt locator = GetIt.instance;

void setupLocator(Database db, SharedPreferences preferences) {
  /// Utils
  locator.registerLazySingleton(() => DialogService());

  /// Repositories
  locator.registerSingleton<PreferencesRepository>(
      PreferencesRepositoryImpl(preferences));
  locator.registerSingleton<LocalStorageRepository>(
      LocalStorageRepositoryImpl(db));

  /// Services
  locator.registerSingleton<SentryService>(SentryService());
}

import 'package:get_it/get_it.dart';
import 'package:mobile/core/http_client.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/repository/auth.dart';
import 'package:mobile/repository/local_storage.dart';
import 'package:mobile/services/dialog_service.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:sembast/sembast.dart';
import 'package:shared_preferences/shared_preferences.dart';

GetIt locator = GetIt.instance;

void setupLocator(Database db, SharedPreferences preferences) {
  PreferencesRepository preferencesRepository =
      PreferencesRepositoryImpl(preferences);

  /// Core
  locator.registerSingleton<LocalStorageRepository>(
      LocalStorageRepositoryImpl(db));
  locator.registerSingleton<HttpClient>(HttpClient(preferencesRepository));

  /// Utils
  locator.registerLazySingleton(() => DialogService());

  /// Services
  locator.registerSingleton<SentryService>(SentryService());

  /// Repositories
  locator.registerSingleton<PreferencesRepository>(preferencesRepository);
  locator.registerSingleton<AuthRepository>(AuthRepository());
}

import 'package:get_it/get_it.dart';
import 'package:mobile/core/api/account_api.dart';
import 'package:mobile/core/api/account_v2_api.dart';
import 'package:mobile/core/api/auth_api.dart';
import 'package:mobile/core/api/calendar_api.dart';
import 'package:mobile/core/api/docs_api.dart';
import 'package:mobile/core/api/event_api.dart';
import 'package:mobile/core/api/integrations/google_api.dart';
import 'package:mobile/core/api/label_api.dart';
import 'package:mobile/core/api/task_api.dart';
import 'package:mobile/core/api/user_api.dart';
import 'package:mobile/core/http_client.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/services/intercom_service.dart';
import 'package:mobile/src/base/cubit/auth/auth_cubit.dart';
import 'package:mobile/features/push/cubit/push_cubit.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/core/repository/accounts_repository.dart';
import 'package:mobile/core/repository/calendars_repository.dart';
import 'package:mobile/core/repository/docs_repository.dart';
import 'package:mobile/core/repository/events_repository.dart';
import 'package:mobile/core/repository/labels_repository.dart';
import 'package:mobile/core/repository/tasks_repository.dart';
import 'package:mobile/core/services/database_service.dart';
import 'package:mobile/core/services/dialog_service.dart';
import 'package:mobile/core/services/push_notification_service.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:mobile/core/services/sync_controller_service.dart';
import 'package:mobile/src/base/ui/cubit/base_cubit.dart';
import 'package:mobile/src/home/ui/cubit/today/today_cubit.dart';
import 'package:models/account/account.dart';
import 'package:models/calendar/calendar.dart';
import 'package:models/doc/doc.dart';
import 'package:models/event/event.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

GetIt locator = GetIt.instance;

// Order of the registration is important
void setupLocator({
  required SharedPreferences preferences,
  required DatabaseService databaseService,
}) {
  PreferencesRepository preferencesRepository = PreferencesRepositoryImpl(preferences);

  /// Core
  locator.registerSingleton<HttpClient>(HttpClient(preferencesRepository));
  locator.registerSingleton<DatabaseService>(databaseService);
  locator.registerSingleton<DialogService>(DialogService());

  /// Apis
  locator.registerSingleton<AuthApi>(AuthApi());
  locator.registerSingleton<AccountApi>(AccountApi());
  locator.registerSingleton<AccountV2Api>(AccountV2Api());
  locator.registerSingleton<TaskApi>(TaskApi());
  locator.registerSingleton<CalendarApi>(CalendarApi());
  locator.registerSingleton<LabelApi>(LabelApi());
  locator.registerSingleton<EventApi>(EventApi());
  locator.registerSingleton<DocsApi>(DocsApi());
  locator.registerSingleton<UserApi>(UserApi());

  /// Integrations
  locator.registerSingleton<GoogleApi>(GoogleApi());

  /// Repositories
  locator.registerSingleton<PreferencesRepository>(preferencesRepository);
  locator.registerSingleton<TasksRepository>(TasksRepository(fromSql: Task.fromSql));
  locator.registerSingleton<AccountsRepository>(AccountsRepository(fromSql: Account.fromSql));
  locator.registerSingleton<CalendarsRepository>(CalendarsRepository(fromSql: Calendar.fromSql));
  locator.registerSingleton<LabelsRepository>(LabelsRepository(fromSql: Label.fromSql));
  locator.registerSingleton<EventsRepository>(EventsRepository(fromSql: Event.fromSql));
  locator.registerSingleton<DocsRepository>(DocsRepository(fromSql: Doc.fromSql));

  /// Services
  locator.registerSingleton<SentryService>(SentryService());
  locator.registerSingleton<IntercomService>(IntercomService());

  locator.registerSingleton<SyncControllerService>(SyncControllerService());
  locator.registerSingleton<PushNotificationService>(PushNotificationService());

  /// Blocs
  TodayCubit todayCubit = TodayCubit();
  SyncCubit syncCubit = SyncCubit();
  TasksCubit tasksCubit = TasksCubit(syncCubit);
  PushCubit pushCubit = PushCubit();
  AuthCubit authCubit = AuthCubit(syncCubit, pushCubit);
  //BaseCubit exampleCubit = BaseCubit();

  tasksCubit.attachAuthCubit(authCubit);
  tasksCubit.attachTodayCubit(todayCubit);
  todayCubit.attachTasksCubit(tasksCubit);

  locator.registerSingleton<TasksCubit>(tasksCubit);
  locator.registerSingleton<TodayCubit>(todayCubit);
  locator.registerSingleton<SyncCubit>(syncCubit);
  locator.registerSingleton<PushCubit>(pushCubit);
  locator.registerSingleton<AuthCubit>(authCubit);
  //locator.registerSingleton<BaseCubit>(exampleCubit);
}

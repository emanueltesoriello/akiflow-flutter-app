import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/core/api/account_api.dart';
import 'package:mobile/core/api/auth_api.dart';
import 'package:mobile/core/api/calendar_api.dart';
import 'package:mobile/core/api/contacts_api.dart';
import 'package:mobile/core/api/event_api.dart';
import 'package:mobile/core/api/integrations/google_api.dart';
import 'package:mobile/core/api/label_api.dart';
import 'package:mobile/core/api/task_api.dart';
import 'package:mobile/core/api/user_api.dart';
import 'package:mobile/core/http_client.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/repository/availabilities_repository.dart';
import 'package:mobile/core/repository/contacts_repository.dart';
import 'package:mobile/core/repository/event_modifiers_repository.dart';
import 'package:mobile/core/services/intercom_service.dart';
import 'package:mobile/core/repository/accounts_repository.dart';
import 'package:mobile/core/repository/calendars_repository.dart';
import 'package:mobile/core/repository/events_repository.dart';
import 'package:mobile/core/repository/labels_repository.dart';
import 'package:mobile/core/repository/tasks_repository.dart';
import 'package:mobile/core/services/database_service.dart';
import 'package:mobile/core/services/dialog_service.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:mobile/core/services/sync_controller_service.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/cubit/notifications/notifications_cubit.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:mobile/src/events/ui/cubit/events_cubit.dart';
import 'package:mobile/src/home/ui/cubit/today/today_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:models/account/account.dart';
import 'package:models/calendar/calendar.dart';
import 'package:models/contact/contact.dart';
import 'package:models/event/event.dart';
import 'package:models/event/event_modifier.dart';
import 'package:models/label/label.dart';
import 'package:models/task/availability_config.dart';
import 'package:models/task/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/availability_api.dart';
import 'api/event_modifiers_api.dart';

GetIt locator = GetIt.instance;

// Order of the registration is important
void setupLocator(
    {required SharedPreferences preferences,
    required DatabaseService databaseService,
    String? endpoint,
    bool initFirebaseApp = true}) {
  PreferencesRepository preferencesRepository = PreferencesRepositoryImpl(preferences);

  /// Core
  locator.registerSingleton<HttpClient>(HttpClient(preferencesRepository));
  locator.registerSingleton<DatabaseService>(databaseService);
  locator.registerSingleton<DialogService>(DialogService());

  /// Apis
  locator.registerSingleton<AuthApi>(AuthApi());
  locator.registerSingleton<AccountApi>(AccountApi(endpoint: endpoint));
  locator.registerSingleton<TaskApi>(TaskApi(endpoint: endpoint));
  locator.registerSingleton<AvailabilityApi>(AvailabilityApi(endpoint: endpoint));
  locator.registerSingleton<CalendarApi>(CalendarApi(endpoint: endpoint));
  locator.registerSingleton<LabelApi>(LabelApi(endpoint: endpoint));
  locator.registerSingleton<EventApi>(EventApi(endpoint: endpoint));
  locator.registerSingleton<EventModifiersApi>(EventModifiersApi(endpoint: endpoint));
  locator.registerSingleton<ContactsApi>(ContactsApi(endpoint: endpoint));
  locator.registerSingleton<UserApi>(UserApi(endpoint: endpoint));

  /// Integrations
  locator.registerSingleton<GoogleApi>(GoogleApi());

  /// Repositories
  locator.registerSingleton<PreferencesRepository>(preferencesRepository);
  locator.registerSingleton<TasksRepository>(TasksRepository(fromSql: Task.fromSql));
  locator.registerSingleton<AccountsRepository>(AccountsRepository(fromSql: Account.fromSql));
  locator.registerSingleton<AvailabilitiesRepository>(AvailabilitiesRepository(fromSql: AvailabilityConfig.fromSql));

  locator.registerSingleton<CalendarsRepository>(CalendarsRepository(fromSql: Calendar.fromSql));
  locator.registerSingleton<LabelsRepository>(LabelsRepository(fromSql: Label.fromSql));
  locator.registerSingleton<EventsRepository>(EventsRepository(fromSql: Event.fromSql));
  locator.registerSingleton<EventModifiersRepository>(EventModifiersRepository(fromSql: EventModifier.fromSql));
  locator.registerSingleton<ContactsRepository>(ContactsRepository(fromSql: Contact.fromSql));

  /// Services
  locator.registerSingleton<SentryService>(SentryService());
  //locator.registerSingleton<IntercomService>(IntercomService());
  locator.registerSingleton<SyncControllerService>(SyncControllerService());

  /// Blocs
  TodayCubit todayCubit = TodayCubit();
  SyncCubit syncCubit = SyncCubit();
  NotificationsCubit notificationsCubit = NotificationsCubit(initFirebaseApp: initFirebaseApp);
  TasksCubit tasksCubit = TasksCubit(syncCubit);
  AuthCubit authCubit = AuthCubit(syncCubit);
  CalendarCubit calendarCubit = CalendarCubit(syncCubit);
  EventsCubit eventsCubit = EventsCubit(syncCubit);
  //BaseCubit exampleCubit = BaseCubit();

  tasksCubit.attachAuthCubit(authCubit);
  tasksCubit.attachTodayCubit(todayCubit);
  todayCubit.attachTasksCubit(tasksCubit);

  locator.registerSingleton<TasksCubit>(tasksCubit);
  locator.registerSingleton<TodayCubit>(todayCubit);
  locator.registerSingleton<SyncCubit>(syncCubit);
  locator.registerSingleton<NotificationsCubit>(notificationsCubit);
  locator.registerSingleton<AuthCubit>(authCubit);
  locator.registerSingleton<CalendarCubit>(calendarCubit);
  locator.registerSingleton<EventsCubit>(eventsCubit);

  //locator.registerSingleton<BaseCubit>(exampleCubit);
}

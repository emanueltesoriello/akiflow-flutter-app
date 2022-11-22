import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/src/availability/ui/cubit/availability_cubit.dart';
import 'package:mobile/src/base/ui/cubit/auth/auth_cubit.dart';
import 'package:mobile/src/base/ui/cubit/dialog/dialog_cubit.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/home/ui/cubit/today/today_cubit.dart';
import 'package:mobile/src/integrations/ui/cubit/integrations_cubit.dart';
import 'package:mobile/src/label/ui/cubit/labels_cubit.dart';
import 'package:mobile/src/onboarding/ui/cubit/onboarding_cubit.dart';
import 'package:mobile/src/settings/ui/cubit/settings_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';

List<BlocProvider> baseProviders = [
  BlocProvider<DialogCubit>(
    lazy: false,
    create: (BuildContext context) => DialogCubit(),
  ),
  BlocProvider<SyncCubit>(
    lazy: false,
    create: (BuildContext context) => locator<SyncCubit>(),
  ),
  BlocProvider<AvailabilityCubit>(
    lazy: false,
    create: (BuildContext context) => locator<AvailabilityCubit>(),
  ),
  BlocProvider<TasksCubit>(
    lazy: false,
    create: (BuildContext context) => locator<TasksCubit>(),
  ),
  BlocProvider<LabelsCubit>(
    lazy: false,
    create: (BuildContext context) => LabelsCubit(locator<SyncCubit>()),
  ),
  BlocProvider<MainCubit>(
    lazy: false,
    create: (BuildContext context) => MainCubit(locator<SyncCubit>(), locator<AuthCubit>()),
  ),
  BlocProvider<AuthCubit>(
    lazy: false,
    create: (BuildContext context) => locator<AuthCubit>(),
  ),
  BlocProvider<SettingsCubit>(
    lazy: false,
    create: (BuildContext context) => SettingsCubit(),
  ),
  BlocProvider<IntegrationsCubit>(
    lazy: false,
    create: (BuildContext context) => IntegrationsCubit(locator<AuthCubit>(), locator<SyncCubit>()),
  ),
  BlocProvider<TodayCubit>(
    lazy: false,
    create: (BuildContext context) => locator<TodayCubit>(),
  ),
  BlocProvider<EditTaskCubit>(
    lazy: false,
    create: (BuildContext context) => EditTaskCubit(locator<TasksCubit>(), locator<SyncCubit>()),
  ),
  BlocProvider<OnboardingCubit>(
    lazy: false,
    create: (BuildContext context) => OnboardingCubit(),
  ),
];

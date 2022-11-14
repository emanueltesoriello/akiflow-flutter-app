import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/src/base/cubit/auth/auth_cubit.dart';
import 'package:mobile/features/account/integrations/cubit/integrations_cubit.dart';
import 'package:mobile/features/account/settings/cubit/settings_cubit.dart';
import 'package:mobile/features/dialog/dialog_cubit.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/features/main/cubit/main_cubit.dart';
import 'package:mobile/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:mobile/features/push/cubit/push_cubit.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/features/tasks/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/features/today/cubit/today_cubit.dart';

List<BlocProvider> baseProviders = [
  BlocProvider<DialogCubit>(
    lazy: false,
    create: (BuildContext context) => DialogCubit(),
  ),
  BlocProvider<PushCubit>(
    lazy: false,
    create: (BuildContext context) => locator<PushCubit>(),
  ),
  BlocProvider<SyncCubit>(
    lazy: false,
    create: (BuildContext context) => locator<SyncCubit>(),
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

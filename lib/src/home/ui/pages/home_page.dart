import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/services/background_service.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/base/ui/cubit/notifications/notifications_cubit.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/home/ui/widgets/gmail_actions_dialog.dart';
import 'package:mobile/src/integrations/ui/cubit/integrations_cubit.dart';
import 'package:mobile/src/integrations/ui/pages/reconnect_integrations.dart';
import 'package:mobile/src/label/ui/cubit/labels_cubit.dart';
import 'package:mobile/src/onboarding/ui/cubit/onboarding_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/doc_action.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:mobile/src/tasks/ui/pages/create_task/create_task_modal.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/recurring_edit_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/account/account.dart';
import 'package:models/extensions/account_ext.dart';
import 'package:share_handler/share_handler.dart';

import 'home_body.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  StreamSubscription? streamSubscription;
  StreamSubscription? periodicStreamSubscription;
  SharedMedia? media;
  final handler = ShareHandlerPlatform.instance;

  Future<void> initPlatformState() async {
    print('started initPlatformState');
    try {
      var media = await handler.getInitialSharedMedia();
      if (!mounted) return;
      if (media != null) {
        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => CreateTaskModal(
            sharedText: media.content,
          ),
        );
      }

      handler.sharedMediaStream.listen((SharedMedia? media) {
        if (!mounted) return;
        if (media != null) {
          showCupertinoModalBottomSheet(
            context: context,
            builder: (context) => CreateTaskModal(
              sharedText: media.content,
            ),
          );
        }
      });
      if (!mounted) return;
    } catch (e) {
      print('Erorr on initPlatformState\n');
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();

    TasksCubit tasksCubit = context.read<TasksCubit>();

    if (streamSubscription != null) {
      streamSubscription!.cancel();
    }

    streamSubscription = tasksCubit.editRecurringTasksDialog.listen((allSelected) {
      showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => RecurringEditModal(
                onlyThisTap: () {
                  tasksCubit.update(allSelected);
                },
                allTap: () {
                  tasksCubit.update(allSelected, andFutureTasks: true);
                },
              ));
    });

    tasksCubit.docActionsStream.listen((List<GmailDocAction> actions) async {
      for (final action in actions) {
        await showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => GmailActionDialog(
            syncMode: action.account.gmailSyncMode,
            goToGmail: () {
              tasksCubit.goToGmail(action.doc);
            },
            unstarOrUnlabel: () {
              tasksCubit.unstarGmail(action);
            },
          ),
        );
      }
    });

    context.read<MainCubit>().onLoggedAppStart();

    context.read<SyncCubit>().syncCompletedStream.listen((_) {
      bool reconnectPageSkipped = context.read<IntegrationsCubit>().reconnectPageSkipped;

      if (reconnectPageSkipped == false) {
        _checkIfHasAccountsToReconnect();
      }
    });

    if (periodicStreamSubscription != null) {
      periodicStreamSubscription!.cancel();
    }
    periodicStreamSubscription =
        Stream.periodic(const Duration(seconds: 30)).listen((_) => context.read<SyncCubit>().checkConnectivity());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    streamSubscription?.cancel();
    periodicStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkIfHasAccountsToReconnect() async {
    context.read<IntegrationsCubit>().refresh().then((_) {
      bool reconnectPageVisible = context.read<IntegrationsCubit>().state.reconnectPageVisible;
      bool tutorialVisible = context.read<OnboardingCubit>().state.show;

      if (reconnectPageVisible || tutorialVisible) {
        return;
      }

      List<Account> accounts = context.read<IntegrationsCubit>().state.accounts;

      if (accounts.any((account) => !context.read<IntegrationsCubit>().isLocalActive(account)) &&
          !locator<PreferencesRepository>().reconnectPageSkipped) {
        context.read<IntegrationsCubit>().reconnectPageVisible(true);

        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ReconnectIntegrations())).then((_) {
            context.read<IntegrationsCubit>().reconnectPageVisible(false);
          });
        });
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    bool isAuthenticatingOAuth = context.read<IntegrationsCubit>().state.isAuthenticatingOAuth;
    if (state == AppLifecycleState.resumed && isAuthenticatingOAuth == false) {
      try {
        context.read<SyncCubit>().sync(loading: true);
        NotificationsCubit.scheduleNotificationsService(locator<PreferencesRepository>());
        periodicStreamSubscription =
            Stream.periodic(const Duration(seconds: 30)).listen((_) => context.read<SyncCubit>().checkConnectivity());
      } catch (e) {
        print(e);
      }
    } else {
      periodicStreamSubscription?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (TaskExt.isSelectMode(context.read<TasksCubit>().state)) {
            context.read<TasksCubit>().clearSelected();
            return false;
          } else if (context.read<LabelsCubit>().state.selectedLabel != null) {
            context.read<MainCubit>().changeHomeView(context.read<MainCubit>().state.lastHomeViewType);
            return false;
          } else {
            if (ModalRoute.of(context)?.settings.name != "/") {
              return false;
            }
            return true;
          }
        },
        child: HomeBody(
            bottomBarHeight: bottomBarHeight, homeViewType: context.watch<MainCubit>().state.homeViewType.index));
  }
}

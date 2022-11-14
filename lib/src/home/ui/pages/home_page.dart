import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/components/task/bottom_task_actions.dart';
import 'package:mobile/features/calendar/ui/calendar_view.dart';
import 'package:mobile/features/tasks/edit_task/cubit/doc_action.dart';
import 'package:mobile/features/tasks/edit_task/ui/recurring_edit_dialog.dart';
import 'package:mobile/features/account/integrations/cubit/integrations_cubit.dart';
import 'package:mobile/features/account/integrations/ui/reconnect_integrations.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/features/label/ui/label_view.dart';
import 'package:mobile/features/main/ui/gmail_actions_dialog.dart';
import 'package:mobile/features/main/ui/undo_button.dart';
import 'package:mobile/features/main/ui/webview.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/cubit/main/main_cubit.dart';
import 'package:mobile/src/base/ui/widgets/floating_button.dart';
import 'package:mobile/src/base/ui/widgets/navbar/bottom_nav_bar.dart';
import 'package:mobile/src/home/ui/pages/inbox_view.dart';
import 'package:mobile/src/home/ui/pages/views/today_view.dart';
import 'package:mobile/src/home/ui/widgets/just_created_task_button.dart';
import 'package:mobile/src/onboarding/ui/cubit/onboarding_cubit.dart';
import 'package:mobile/src/onboarding/ui/pages/onboarding_tutorial.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/account/account.dart';
import 'package:models/extensions/account_ext.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  StreamSubscription? streamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    TasksCubit tasksCubit = context.read<TasksCubit>();

    if (streamSubscription != null) {
      streamSubscription!.cancel();
    }

    streamSubscription = tasksCubit.editRecurringTasksDialog.listen((allSelected) {
      showDialog(
          context: context,
          builder: (context) => RecurringEditDialog(
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
              tasksCubit.unstarGmail(action.account, action.doc);
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
  }

  Future<void> _checkIfHasAccountsToReconnect() async {
    context.read<IntegrationsCubit>().refresh().then((_) {
      bool reconnectPageVisible = context.read<IntegrationsCubit>().state.reconnectPageVisible;
      bool tutorialVisible = context.read<OnboardingCubit>().state.show;

      if (reconnectPageVisible || tutorialVisible) {
        return;
      }

      List<Account> accounts = context.read<IntegrationsCubit>().state.accounts;

      if (accounts.any((account) => !context.read<IntegrationsCubit>().isLocalActive(account))) {
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
      context.read<SyncCubit>().sync(loading: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
      child: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    int homeViewType = context.watch<MainCubit>().state.homeViewType.index;

    return Stack(
      children: [
        const InternalWebView(),
        Scaffold(
          extendBodyBehindAppBar: true,
          floatingActionButton: const FloatingButton(bottomBarHeight: bottomBarHeight),
          bottomNavigationBar: CustomBottomNavigationBar(
            labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ColorsExt.grey2(context)),
            bottomBarIconSize: 30,
            topPadding: MediaQuery.of(context).padding.top,
          ),
          body: Builder(builder: (context) {
            if (homeViewType < 4) {
              return IndexedStack(
                index: homeViewType,
                children: const [
                  InboxView(),
                  TodayView(),
                  CalendarView(),
                ],
              );
            }
            return const LabelView();
          }),
        ),
        BlocBuilder<TasksCubit, TasksCubitState>(
          builder: (context, state) {
            bool anyInboxSelected = state.inboxTasks.any((t) => t.selected ?? false);
            bool anyTodaySelected = state.selectedDayTasks.any((t) => t.selected ?? false);
            bool anyLabelsSelected = state.labelTasks.any((t) => t.selected ?? false);

            if (anyInboxSelected || anyTodaySelected || anyLabelsSelected) {
              return const Align(
                alignment: Alignment.bottomCenter,
                child: BottomTaskActions(),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
        const UndoBottomView(),
        const JustCreatedTaskView(),
        BlocBuilder<OnboardingCubit, OnboardingCubitState>(
          builder: (context, state) {
            if (state.show) {
              return const OnboardingTutorial();
            } else {
              return const SizedBox();
            }
          },
        ),
      ],
    );
  }
}

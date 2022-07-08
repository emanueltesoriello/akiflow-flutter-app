import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/components/task/bottom_task_actions.dart';
import 'package:mobile/components/task/task_list_menu.dart';
import 'package:mobile/features/calendar/ui/calendar_view.dart';
import 'package:mobile/features/create_task/ui/create_task_modal.dart';
import 'package:mobile/features/edit_task/cubit/doc_action.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/edit_task/ui/recurring_edit_dialog.dart';
import 'package:mobile/features/inbox/ui/inbox_view.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/features/label/ui/label_appbar.dart';
import 'package:mobile/features/label/ui/label_view.dart';
import 'package:mobile/features/main/cubit/main_cubit.dart';
import 'package:mobile/features/main/ui/bottom_nav_bar.dart';
import 'package:mobile/features/main/ui/gmail_actions_dialog.dart';
import 'package:mobile/features/main/ui/just_created_task_button.dart';
import 'package:mobile/features/main/ui/undo_button.dart';
import 'package:mobile/features/main/ui/webview.dart';
import 'package:mobile/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:mobile/features/onboarding/ui/onboarding_tutorial.dart';
import 'package:mobile/features/settings/cubit/settings_cubit.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/features/today/cubit/today_cubit.dart';
import 'package:mobile/features/today/ui/today_appbar.dart';
import 'package:mobile/features/today/ui/today_view.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/style/sizes.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/extensions/account_ext.dart';
import 'package:models/label/label.dart';
import 'package:models/nullable.dart';
import 'package:models/task/task.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  StreamSubscription? streamSubscription;
  final PageController _pageController = PageController(initialPage: 1);

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
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    bool isAuthenticatingOAuth = context.read<SettingsCubit>().state.isAuthenticatingOAuth;
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
    HomeViewType homeViewType = context.watch<MainCubit>().state.homeViewType;
    Label? label = context.watch<LabelsCubit>().state.selectedLabel;

    return Stack(
      children: [
        const InternalWebView(),
        Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _appBar(
            context,
            todayAppBarHeight: toolbarHeight,
            calendarTopMargin: toolbarHeight,
            homeViewType: homeViewType,
            selectedLabel: label,
          ),
          floatingActionButton: _floatingButton(),
          bottomNavigationBar: _bottomBar(context),
          body: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + toolbarHeight),
            child: _content(),
          ),
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

  PreferredSizeWidget _appBar(
    BuildContext context, {
    required double calendarTopMargin,
    required double todayAppBarHeight,
    required HomeViewType homeViewType,
    required Label? selectedLabel,
  }) {
    switch (homeViewType) {
      case HomeViewType.inbox:
        return AppBarComp(
          title: t.bottomBar.inbox,
          leading: SvgPicture.asset(
            "assets/images/icons/_common/tray.svg",
            width: 26,
            height: 26,
          ),
          actions: const [TaskListMenu()],
          showSyncButton: true,
        );
      case HomeViewType.today:
        return TodayAppBar(preferredSizeHeight: todayAppBarHeight, calendarTopMargin: calendarTopMargin);
      case HomeViewType.calendar:
        return AppBarComp(
          title: t.bottomBar.calendar,
          leading: SvgPicture.asset(
            "assets/images/icons/_common/calendar.svg",
            width: 26,
            height: 26,
          ),
          showSyncButton: true,
        );
      case HomeViewType.label:
        bool showDone = context.watch<LabelsCubit>().state.showDone;
        return LabelAppBar(label: selectedLabel!, showDone: showDone);
      default:
        return const PreferredSize(preferredSize: Size.zero, child: SizedBox());
    }
  }

  Widget _content() {
    return BlocListener<MainCubit, MainCubitState>(
      listener: (context, state) {
        int? page;

        switch (state.homeViewType) {
          case HomeViewType.inbox:
            page = 1;
            break;
          case HomeViewType.today:
            page = 2;
            break;
          case HomeViewType.calendar:
            page = 3;
            break;
          case HomeViewType.label:
            page = 4;

            break;
          default:
        }

        if (page == null) return;

        if (page == 4) {
          _pageController.jumpToPage(page);
        } else if ((state.lastHomeViewType == HomeViewType.label || state.homeViewType == HomeViewType.label)) {
          _pageController.jumpToPage(page);
        } else {
          _pageController.animateToPage(page, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        }
      },
      child: BlocBuilder<LabelsCubit, LabelsCubitState>(
        builder: (context, labelsState) {
          Label? selectedLabel = labelsState.selectedLabel;

          return PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const SizedBox(),
              const InboxView(),
              const TodayView(),
              const CalendarView(),
              if (selectedLabel != null) LabelView(key: ObjectKey(selectedLabel)) else const SizedBox()
            ],
          );
        },
      ),
    );
  }

  static const double bottomBarIconSize = 30;

  Widget _bottomBar(BuildContext context) {
    double topPadding = MediaQuery.of(context).padding.top;

    return BlocBuilder<TasksCubit, TasksCubitState>(
      builder: (context, state) {
        List<Task> inboxTasks = List.from(state.inboxTasks);

        TextStyle labelStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ColorsExt.grey2(context));

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomBottomNavigationBar(
              labelStyle: labelStyle,
              bottomBarIconSize: bottomBarIconSize,
              inboxTasksCount: inboxTasks.length,
              fixedTodoTodayTasksCount: state.todayCount,
              topPadding: topPadding,
            ),
          ],
        );
      },
    );
  }

  BlocBuilder<TasksCubit, TasksCubitState> _floatingButton() {
    return BlocBuilder<TasksCubit, TasksCubitState>(
      builder: (context, state) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: state.queue.isNotEmpty || state.justCreatedTask != null ? bottomBarHeight : 0),
          child: SizedBox(
            width: 52,
            height: 52,
            child: FloatingActionButton(
              onPressed: () async {
                HapticFeedback.mediumImpact();

                HomeViewType homeViewType = context.read<MainCubit>().state.homeViewType;

                TaskStatusType taskStatusType;

                if (homeViewType == HomeViewType.inbox || homeViewType == HomeViewType.label) {
                  taskStatusType = TaskStatusType.inbox;
                } else {
                  taskStatusType = TaskStatusType.planned;
                }

                DateTime date = context.read<TodayCubit>().state.selectedDate;

                Label? label = context.read<LabelsCubit>().state.selectedLabel;

                EditTaskCubit editTaskCubit = context.read<EditTaskCubit>();

                Task task = editTaskCubit.state.updatedTask.copyWith(
                  status: Nullable(taskStatusType.id),
                  date: (taskStatusType == TaskStatusType.inbox || homeViewType == HomeViewType.label)
                      ? Nullable(null)
                      : Nullable(date.toIso8601String()),
                  listId: Nullable(label?.id),
                );

                editTaskCubit.attachTask(task);

                showCupertinoModalBottomSheet(
                  context: context,
                  builder: (context) => const CreateTaskModal(),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SvgPicture.asset(
                "assets/images/icons/_common/plus.svg",
                color: ColorsExt.background(context),
              ),
            ),
          ),
        );
      },
    );
  }
}

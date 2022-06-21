import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
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
import 'package:mobile/features/main/ui/gmail_actions_dialog.dart';
import 'package:mobile/features/main/ui/just_created_task_button.dart';
import 'package:mobile/features/main/ui/quill_web_view.dart';
import 'package:mobile/features/main/ui/undo_button.dart';
import 'package:mobile/features/settings/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/ui/settings_modal.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/features/today/cubit/today_cubit.dart';
import 'package:mobile/features/today/ui/today_appbar.dart';
import 'package:mobile/features/today/ui/today_view.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/extensions/account_ext.dart';
import 'package:models/label/label.dart';
import 'package:models/nullable.dart';
import 'package:models/task/task.dart';

const double bottomBarHeight = 72;

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
      context.read<SyncCubit>().sync();
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
        const QuillWebView(),
        BlocBuilder<TodayCubit, TodayCubitState>(
          builder: (context, state) {
            double todayAppBarHeight;
            double toolbarHeight = 56;
            double openedCalendarHeight = 280;
            double closedCalendarHeight = 80;

            switch (state.calendarFormat) {
              case CalendarFormatState.month:
                todayAppBarHeight = toolbarHeight + openedCalendarHeight;
                break;
              case CalendarFormatState.week:
                todayAppBarHeight = toolbarHeight + closedCalendarHeight;
                break;
            }

            double contentTopPadding = MediaQuery.of(context).padding.top + toolbarHeight;

            if (homeViewType == HomeViewType.today) {
              contentTopPadding += closedCalendarHeight;
            }

            return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: _appBar(
                context,
                todayAppBarHeight: todayAppBarHeight,
                calendarTopMargin: toolbarHeight,
                homeViewType: homeViewType,
                selectedLabel: label,
              ),
              floatingActionButton: _floatingButton(),
              bottomNavigationBar: _bottomBar(context),
              body: Padding(
                padding: EdgeInsets.only(top: contentTopPadding),
                child: _content(),
              ),
            );
          },
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
            width: 30,
            height: 30,
          ),
          actions: const [TaskListMenu()],
        );
      case HomeViewType.today:
        return TodayAppBar(preferredSizeHeight: todayAppBarHeight, calendarTopMargin: calendarTopMargin);
      case HomeViewType.calendar:
        return AppBarComp(title: t.bottomBar.calendar);
      case HomeViewType.label:
        bool showDone = context.watch<LabelsCubit>().state.showDone;
        return LabelAppBar(label: selectedLabel!, showDone: showDone);
      default:
        return const PreferredSize(preferredSize: Size.zero, child: SizedBox());
    }
  }

  Widget _content() {
    return BlocBuilder<TasksCubit, TasksCubitState>(
      builder: (context, state) {
        if (state.firstTimeLoaded == false) {
          return const FirstSyncProgress();
        }

        return BlocConsumer<MainCubit, MainCubitState>(
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
          builder: (context, state) {
            Label? selectedLabel = context.watch<LabelsCubit>().state.selectedLabel;

            return PageView(
              key: const ObjectKey("pageView"),
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
        );
      },
    );
  }

  static const double bottomBarIconSize = 30;

  Widget _bottomBar(BuildContext context) {
    double topPadding = MediaQuery.of(context).padding.top;

    return BlocBuilder<TasksCubit, TasksCubitState>(
      builder: (context, state) {
        List<Task> inboxTasks = List.from(state.inboxTasks);
        List<Task> fixedTodayTasks = List.from(state.fixedTodayTasks);
        List<Task> fixedTodoTodayTasks =
            List.from(fixedTodayTasks.where((element) => !element.isCompletedComputed && element.isTodayOrBefore));

        TextStyle labelStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ColorsExt.grey2(context));

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 0.5, color: const Color(0xffE4EDF3)),
            CustomBottomNavigationBar(
              labelStyle: labelStyle,
              bottomBarIconSize: bottomBarIconSize,
              inboxTasks: inboxTasks,
              fixedTodoTodayTasks: fixedTodoTodayTasks,
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
        double bottomPadding;

        if (state.queue.isNotEmpty || state.justCreatedTask != null) {
          bottomPadding = bottomBarHeight;
        } else {
          bottomPadding = 0;
        }

        return Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: FloatingActionButton(
            onPressed: () async {
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
                builder: (context) => SingleChildScrollView(
                  controller: ModalScrollController.of(context),
                  child: const CreateTaskModal(),
                ),
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
        );
      },
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    Key? key,
    required this.labelStyle,
    required this.bottomBarIconSize,
    required this.inboxTasks,
    required this.fixedTodoTodayTasks,
    required this.topPadding,
  }) : super(key: key);

  final TextStyle labelStyle;
  final double bottomBarIconSize;
  final List<Task> inboxTasks;
  final List<Task> fixedTodoTodayTasks;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsExt.background(context),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            offset: Offset(0, -1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: bottomBarHeight,
            child: BlocBuilder<MainCubit, MainCubitState>(
              builder: (context, state) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NavItem(
                      active: false,
                      activeIconAsset: "assets/images/icons/_common/menu.svg",
                      title: t.bottomBar.menu,
                      topPadding: topPadding,
                    ),
                    NavItem(
                      active: state.homeViewType == HomeViewType.inbox,
                      activeIconAsset: "assets/images/icons/_common/tray.svg",
                      title: t.bottomBar.inbox,
                      homeViewType: HomeViewType.inbox,
                      badge: _BottomIconBadge(inboxTasks.length),
                      topPadding: topPadding,
                    ),
                    NavItem(
                      active: state.homeViewType == HomeViewType.today,
                      activeIconAsset:
                          "assets/images/icons/_common/${DateFormat("dd").format(DateTime.now())}_square.svg",
                      title: t.bottomBar.today,
                      homeViewType: HomeViewType.today,
                      badge: _BottomIconBadge(fixedTodoTodayTasks.length),
                      topPadding: topPadding,
                    ),
                    NavItem(
                      active: state.homeViewType == HomeViewType.calendar,
                      activeIconAsset: "assets/images/icons/_common/calendar.svg",
                      title: t.bottomBar.calendar,
                      homeViewType: HomeViewType.calendar,
                      topPadding: topPadding,
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final String activeIconAsset;
  final bool active;
  final String title;
  final HomeViewType? homeViewType;
  final Widget? badge;
  final double topPadding;

  const NavItem({
    Key? key,
    required this.activeIconAsset,
    required this.active,
    required this.title,
    required this.topPadding,
    this.homeViewType,
    this.badge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;

    if (active) {
      color = ColorsExt.akiflow(context);
    } else {
      color = ColorsExt.grey2(context);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (homeViewType != null) {
            context.read<MainCubit>().changeHomeView(homeViewType!);
          } else {
            showCupertinoModalBottomSheet(
              context: context,
              builder: (context) => SettingsModal(topPadding: topPadding),
            );
          }
        },
        child: Container(
          color: ColorsExt.background(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, Platform.isAndroid ? -3 : 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 40,
                        height: 40,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: SvgPicture.asset(activeIconAsset, color: color),
                        )),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color),
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null) Align(alignment: Alignment.topCenter, child: badge!),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomIconBadge extends StatelessWidget {
  final int count;

  const _BottomIconBadge(
    this.count, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return const SizedBox();
    }

    return Transform.translate(
      offset: Offset(17, Platform.isAndroid ? 5 : 8),
      child: Container(
        width: 17,
        height: 17,
        decoration: BoxDecoration(
          color: ColorsExt.akiflow(context),
          border: Border.all(color: ColorsExt.background(context), width: 1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            count > 99 ? "99+" : count.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: count > 99 ? 6 : 9,
              fontWeight: FontWeight.w600,
              color: ColorsExt.background(context),
            ),
          ),
        ),
      ),
    );
  }
}

class FirstSyncProgress extends StatelessWidget {
  const FirstSyncProgress({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          SizedBox(
            width: 66,
            height: 66,
            child: CircularProgressIndicator(
              strokeWidth: 5,
              color: ColorsExt.akiflow20(context),
            ),
          ),
          SizedBox(
            width: 66,
            height: 66,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  "assets/images/app_icon/top.png",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

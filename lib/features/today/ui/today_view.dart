import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/task/task_list.dart';
import 'package:mobile/features/main/ui/first_sync_progress.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/features/today/cubit/today_cubit.dart';
import 'package:mobile/features/today/ui/today_app_bar_calendar.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/style/sizes.dart';
import 'package:mobile/utils/panel.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/task/task.dart';

class TodayView extends StatelessWidget {
  const TodayView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _View();
  }
}

class _View extends StatefulWidget {
  const _View({Key? key}) : super(key: key);

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  StreamSubscription? streamSubscription;
  ScrollController scrollController = ScrollController();
  ValueNotifier<double> calendarOffsetNotifier = ValueNotifier<double>(200);
  PanelController panelController = PanelController();

  @override
  void initState() {
    TasksCubit tasksCubit = context.read<TasksCubit>();
    TodayCubit todayCubit = context.read<TodayCubit>();

    if (streamSubscription != null) {
      streamSubscription!.cancel();
    }

    streamSubscription = tasksCubit.scrollListStream.listen((allSelected) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        try {
          scrollController.animateTo(scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        } catch (_) {}
      });
    });

    todayCubit.panelStateStream.listen((PanelState panelState) {
      switch (panelState) {
        case PanelState.OPEN:
          panelController.open();
          break;
        case PanelState.CLOSED:
          panelController.close();
          break;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TasksCubit tasksCubit = context.watch<TasksCubit>();

    DateTime selectedDate = context.watch<TodayCubit>().state.selectedDate;
    List<Task> todayTasks = List.from(tasksCubit.state.selectedDayTasks);

    List<Task> todos;
    List<Task> pinned;
    List<Task> completed;

    if (selectedDate.day == DateTime.now().day &&
        selectedDate.month == DateTime.now().month &&
        selectedDate.year == DateTime.now().year) {
      todos = List.from(todayTasks
          .where((element) => !element.isCompletedComputed && element.isTodayOrBefore && !element.isPinnedInCalendar));
      pinned = todayTasks
          .where((element) => !element.isCompletedComputed && !element.isOverdue && element.isPinnedInCalendar)
          .toList();
      completed = List.from(todayTasks.where((element) => element.isCompletedComputed && element.isToday));
    } else {
      todos = List.from(todayTasks.where((element) =>
          !element.isCompletedComputed && element.isSameDateOf(selectedDate) && !element.isPinnedInCalendar));
      pinned = todayTasks
          .where((element) =>
              !element.isCompletedComputed &&
              !element.isOverdue &&
              element.isPinnedInCalendar &&
              element.isSameDateOf(selectedDate))
          .toList();
      completed =
          List.from(todayTasks.where((element) => element.isCompletedComputed && element.isSameDateOf(selectedDate)));
    }

    pinned.sort((a, b) {
      try {
        return DateTime.parse(a.datetime!).toLocal().compareTo(DateTime.parse(b.datetime!).toLocal());
      } catch (_) {}
      return 0;
    });

    return SlidingUpPanel(
      bodyHeight: MediaQuery.of(context).size.height - toolbarHeight - bottomBarHeight - todayViewTopMargin,
      slideDirection: SlideDirection.DOWN,
      controller: panelController,
      maxHeight: 280,
      minHeight: 80,
      defaultPanelState: PanelState.CLOSED,
      panel: ValueListenableBuilder(
        valueListenable: calendarOffsetNotifier,
        builder: (context, value, child) {
          return Container(
            color: Colors.white,
            child: const TodayAppBarCalendar(calendarFormat: CalendarFormatState.month),
          );
        },
      ),
      onPanelClosed: () {
        context.read<TodayCubit>().panelClosed();
      },
      onPanelOpened: () {
        context.read<TodayCubit>().panelOpened();
      },
      collapsed: Container(
        color: Colors.white,
        child: const TodayAppBarCalendar(calendarFormat: CalendarFormatState.week),
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: todayViewTopMargin),
            child: RefreshIndicator(
              backgroundColor: ColorsExt.background(context),
              onRefresh: () async {
                return context.read<SyncCubit>().sync();
              },
              child: SlidableAutoCloseBehavior(
                child: ListView(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    TaskList(
                      key: const ObjectKey("todos"),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      tasks: todos,
                      sorting: TaskListSorting.sortingAscending,
                      visible: context.watch<TodayCubit>().state.todosListOpen,
                      showLabel: true,
                      showPlanInfo: false,
                      header: _Header(
                        t.today.toDos,
                        tasks: todos,
                        onClick: () {
                          context.read<TodayCubit>().openTodoList();
                        },
                        listOpened: context.watch<TodayCubit>().state.todosListOpen,
                        usePrimaryColor: true,
                      ),
                    ),
                    TaskList(
                      key: const ObjectKey("pinned"),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      tasks: pinned,
                      visible: context.watch<TodayCubit>().state.pinnedListOpen,
                      showLabel: true,
                      showPlanInfo: false,
                      sorting: TaskListSorting.dateAscending,
                      header: _Header(
                        t.today.pinnedInCalendar,
                        tasks: pinned,
                        onClick: () {
                          context.read<TodayCubit>().openPinnedList();
                        },
                        listOpened: context.watch<TodayCubit>().state.pinnedListOpen,
                        usePrimaryColor: false,
                      ),
                    ),
                    TaskList(
                      key: const ObjectKey("completed"),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      tasks: completed,
                      sorting: TaskListSorting.sortingDescending,
                      visible: context.watch<TodayCubit>().state.completedListOpen,
                      showLabel: true,
                      showPlanInfo: false,
                      header: _Header(
                        t.today.done,
                        tasks: completed,
                        onClick: () {
                          context.read<TodayCubit>().openCompletedList();
                        },
                        listOpened: context.watch<TodayCubit>().state.completedListOpen,
                        usePrimaryColor: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Builder(
            builder: (context) {
              if (tasksCubit.state.loading) {
                return const FirstSyncProgress();
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(
    this.title, {
    Key? key,
    required this.tasks,
    required this.listOpened,
    required this.onClick,
    required this.usePrimaryColor,
  }) : super(key: key);

  final String title;
  final List<Task> tasks;
  final bool listOpened;
  final Function() onClick;
  final bool usePrimaryColor;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const SizedBox();
    }

    return InkWell(
      onTap: onClick,
      child: Container(
        height: 42,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: ColorsExt.grey5(context),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context))),
            const SizedBox(width: 4),
            Text("(${tasks.length})",
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: usePrimaryColor ? ColorsExt.akiflow(context) : ColorsExt.grey2(context))),
            const Spacer(),
            SvgPicture.asset(
              listOpened
                  ? "assets/images/icons/_common/chevron_up.svg"
                  : "assets/images/icons/_common/chevron_down.svg",
              color: ColorsExt.grey3(context),
              width: 20,
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}

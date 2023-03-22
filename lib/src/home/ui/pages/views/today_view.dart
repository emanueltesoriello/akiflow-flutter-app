import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/services/notifications_service.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/base/ui/widgets/task/panel.dart';
import 'package:mobile/src/base/ui/widgets/task/task_list.dart';
import 'package:mobile/src/home/ui/widgets/first_sync_progress.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/home/ui/cubit/today/today_cubit.dart';
import 'package:mobile/src/home/ui/widgets/today/today_app_bar_calendar.dart';
import 'package:mobile/src/home/ui/widgets/today/today_appbar.dart';
import 'package:mobile/src/home/ui/widgets/today/today_header.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:models/task/task.dart';
import 'package:mobile/src/home/ui/cubit/today/viewed_month_cubit.dart';
import 'package:mobile/core/preferences.dart';

class TodayView extends StatefulWidget {
  const TodayView({Key? key}) : super(key: key);

  @override
  State<TodayView> createState() => _TodayViewState();
}

class _TodayViewState extends State<TodayView> {
  StreamSubscription? streamSubscription;
  ScrollController scrollController = ScrollController();
  ValueNotifier<double> calendarOffsetNotifier = ValueNotifier<double>(200);
  PanelController panelController = PanelController();

  @override
  void initState() {
    TodayCubit todayCubit = context.read<TodayCubit>();

    if (streamSubscription != null) {
      streamSubscription!.cancel();
    }
    todayCubit.panelStateStream.listen((PanelState panelState) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        switch (panelState) {
          case PanelState.opened:
            panelController.open();
            break;
          case PanelState.closed:
            panelController.close();
            break;
        }
      });
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

    try {
      todos.sort((a, b) {
        try {
          return DateTime.parse(a.datetime!).toLocal().compareTo(DateTime.parse(b.datetime!).toLocal());
        } catch (_) {}
        return 0;
      });
    } catch (e) {
      print(e);
    }

    pinned.sort((a, b) {
      try {
        DateTime parsedAUTC = DateTime.parse(a.datetime!);
        DateTime parsedALocal = parsedAUTC.toLocal();
        DateTime fixedA = parsedALocal != null
            ? DateTime(parsedAUTC.year, parsedAUTC.month, parsedAUTC.day, parsedALocal.hour, parsedALocal.minute,
                parsedALocal.second)
            : DateTime.now();

        DateTime parsedBUTC = DateTime.parse(b.datetime!);
        DateTime parsedBLocal = parsedBUTC.toLocal();
        DateTime fixedB = parsedBLocal != null
            ? DateTime(parsedBUTC.year, parsedBUTC.month, parsedBUTC.day, parsedBLocal.hour, parsedBLocal.minute,
                parsedBLocal.second)
            : DateTime.now();

        return fixedA.compareTo(fixedB);
      } catch (e) {
        print("Error sorting pinned items: ${e.toString()}");
        return 0;
      }
    });

    return BlocProvider(
        lazy: false,
        create: (BuildContext context) => ViewedMonthCubit(),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: const TodayAppBar(
              preferredSizeHeight: Dimension.toolbarHeight, calendarTopMargin: Dimension.toolbarHeight),
          body: LayoutBuilder(builder: (context, constraints) {
            return SlidingUpPanel(
              bodyHeight: constraints.maxHeight,
              slideDirection: SlideDirection.down,
              controller: panelController,
              maxHeight: 280,
              minHeight: Dimension.todayViewTopMargin,
              defaultPanelState: PanelState.closed,
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
              collapsed: const Material(
                color: Colors.white,
                child: TodayAppBarCalendar(calendarFormat: CalendarFormatState.week),
              ),
              body: Container(
                margin: const EdgeInsets.only(top: Dimension.todayViewTopMargin),
                child: Stack(
                  children: [
                    RefreshIndicator(
                      backgroundColor: ColorsExt.background(context),
                      onRefresh: () async {
                        context.read<SyncCubit>().sync();
                        NotificationsService.scheduleNotificationsService(locator<PreferencesRepository>());
                      },
                      child: SlidableAutoCloseBehavior(
                        child: ListView(
                          controller: scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          children: [
                            if (todos.isEmpty && pinned.isEmpty)
                              Container(
                                padding: const EdgeInsets.only(top: Dimension.paddingXXL, bottom: Dimension.paddingS),
                                child: SvgPicture.asset(Assets.images.akiflow.tasksDoneSVG,
                                    width: Dimension.pagesImageSize, height: Dimension.pagesImageSize),
                              ),
                            TaskList(
                              key: const ObjectKey("todos"),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              tasks: todos,
                              sorting: TaskListSorting.dateAscending,
                              visible: context.watch<TodayCubit>().state.todosListOpen,
                              showLabel: true,
                              showPlanInfo: false,
                              header: TodayHeader(
                                t.today.toDos,
                                tasks: todos,
                                onClick: () {
                                  context.read<TodayCubit>().openTodoList();
                                },
                                listOpened: context.watch<TodayCubit>().state.todosListOpen,
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
                              header: TodayHeader(
                                t.today.pinnedInCalendar,
                                tasks: pinned,
                                onClick: () {
                                  context.read<TodayCubit>().openPinnedList();
                                },
                                listOpened: context.watch<TodayCubit>().state.pinnedListOpen,
                              ),
                            ),
                            TaskList(
                              key: const ObjectKey("completed"),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              tasks: completed,
                              sorting: TaskListSorting.doneAtDescending,
                              visible: context.watch<TodayCubit>().state.completedListOpen,
                              showLabel: true,
                              showPlanInfo: false,
                              header: TodayHeader(
                                t.today.done,
                                tasks: completed,
                                onClick: () {
                                  context.read<TodayCubit>().openCompletedList();
                                },
                                listOpened: context.watch<TodayCubit>().state.completedListOpen,
                              ),
                            ),
                            const SizedBox(height: Dimension.paddingXXL)
                          ],
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
              ),
            );
          }),
        ));
  }
}

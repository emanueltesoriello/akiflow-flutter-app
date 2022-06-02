import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/task/task_list.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/features/today/cubit/today_cubit.dart';
import 'package:mobile/features/today/ui/today_task_list.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/task/task.dart';

class TodayView extends StatelessWidget {
  const TodayView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _View();
  }
}

class _View extends StatelessWidget {
  const _View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = context.watch<TodayCubit>().state.selectedDate;
    List<Task> todayTasks = List.from(context.watch<TasksCubit>().state.todayTasks);

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

    return RefreshIndicator(
      backgroundColor: ColorsExt.background(context),
      onRefresh: () async {
        return context.read<SyncCubit>().sync();
      },
      child: SlidableAutoCloseBehavior(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: PrimaryScrollController.of(context) ?? ScrollController(),
          slivers: [
            TodayTaskList(
              tasks: todos,
              sorting: TaskListSorting.descending,
              showTasks: context.watch<TodayCubit>().state.todosListOpen,
              showLabel: true,
              footer: null,
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
            TodayTaskList(
              tasks: pinned,
              sorting: TaskListSorting.descending,
              showTasks: context.watch<TodayCubit>().state.pinnedListOpen,
              showLabel: true,
              footer: null,
              showPlanInfo: false,
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
            TodayTaskList(
              tasks: completed,
              sorting: TaskListSorting.descending,
              showTasks: context.watch<TodayCubit>().state.completedListOpen,
              showLabel: true,
              footer: null,
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/task/task_list.dart';
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

    return SlidableAutoCloseBehavior(
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: PrimaryScrollController.of(context) ?? ScrollController(),
        slivers: [
          TodayTaskList(
            tasks: todos,
            sorting: TaskListSorting.descending,
            showTasks: context.watch<TodayCubit>().state.todosListOpen,
            header: _Header(
              t.today.toDos,
              tasks: todos,
              onClick: () {
                context.read<TodayCubit>().openTodoList();
              },
              listOpened: context.watch<TodayCubit>().state.todosListOpen,
            ),
          ),
          TodayTaskList(
            tasks: pinned,
            sorting: TaskListSorting.descending,
            showTasks: context.watch<TodayCubit>().state.pinnedListOpen,
            header: _Header(
              t.today.pinnedInCalendar,
              tasks: pinned,
              onClick: () {
                context.read<TodayCubit>().openPinnedList();
              },
              listOpened: context.watch<TodayCubit>().state.pinnedListOpen,
            ),
          ),
          TodayTaskList(
            tasks: completed,
            sorting: TaskListSorting.descending,
            showTasks: context.watch<TodayCubit>().state.completedListOpen,
            header: _Header(
              t.today.done,
              tasks: completed,
              onClick: () {
                context.read<TodayCubit>().openCompletedList();
              },
              listOpened: context.watch<TodayCubit>().state.completedListOpen,
            ),
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
  }) : super(key: key);

  final String title;
  final List<Task> tasks;
  final bool listOpened;
  final Function() onClick;

  @override
  Widget build(BuildContext context) {
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
          boxShadow: [
            const BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.06), // shadow color
            ),
            BoxShadow(
              offset: const Offset(0, 4),
              blurRadius: 6,
              color: ColorsExt.grey7(context),
              // background color
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context))),
            const SizedBox(width: 4),
            Text("(${tasks.length})",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: ColorsExt.akiflow(context))),
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

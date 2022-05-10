import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
    return BlocProvider(create: (context) => TodayCubit(), child: const _View());
  }
}

class _View extends StatelessWidget {
  const _View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Task> _tasks = List.from(context.watch<TasksCubit>().state.tasks);

    List<Task> todos = TaskExt.filterTodayTodoTasks(_tasks).toList();
    // List pinned = TaskExt.filterTodayPinnedTasks(tasks);
    // List completed = TaskExt.filterTodayCompletedTasks(tasks);

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            await context.read<TasksCubit>().syncAllAndRefresh();
          },
          child: SlidableAutoCloseBehavior(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: PrimaryScrollController.of(context) ?? ScrollController(),
              slivers: [
                TodayTaskList(
                  tasks: todos,
                  sorting: TaskListSorting.descending,
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
                  tasks: todos,
                  sorting: TaskListSorting.descending,
                  header: _Header(
                    t.today.pinnedInCalendar,
                    tasks: todos,
                    onClick: () {
                      context.read<TodayCubit>().openPinnedList();
                    },
                    listOpened: context.watch<TodayCubit>().state.pinnedListOpen,
                  ),
                ),
                TodayTaskList(
                  tasks: todos,
                  sorting: TaskListSorting.descending,
                  header: _Header(
                    t.today.done,
                    tasks: todos,
                    onClick: () {
                      context.read<TodayCubit>().openCompletedList();
                    },
                    listOpened: context.watch<TodayCubit>().state.completedListOpen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
          ],
        ),
      ),
    );
  }
}

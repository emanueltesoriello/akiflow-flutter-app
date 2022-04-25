import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobile/components/task/task_row.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:models/task/task.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;

  // Used to show done tasks, before debounce update it
  final List<Task> updatedTasks;

  final Widget? notice;
  final bool hideInboxLabel;

  const TaskList({
    Key? key,
    required this.tasks,
    required this.updatedTasks,
    this.notice,
    this.hideInboxLabel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            await context.read<TasksCubit>().syncAllAndRefresh();
          },
          child: SlidableAutoCloseBehavior(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: tasks.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  if (notice == null) {
                    return const SizedBox(height: 0);
                  }

                  return notice!;
                }

                index -= 1;

                Task task = tasks[index];

                Task? updatedTask = updatedTasks
                    .firstWhereOrNull((element) => element.id == task.id);

                return TaskRow(
                  task: task,
                  updatedTask: updatedTask,
                  hideInboxLabel: hideInboxLabel,
                  selectMode: tasks.any((element) => element.selected ?? false),
                  completedClick: () {
                    context.read<TasksCubit>().done(updatedTask ?? task);
                  },
                  longClick: () {
                    context.read<TasksCubit>().select(task);
                  },
                  planClick: () {
                    // TODO plan task
                  },
                  selectLabelClick: () {
                    // TODO select label of task
                  },
                  snoozeClick: () {
                    // TODO snooze task
                  },
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox();
              },
            ),
          ),
        ),
      ],
    );
  }
}

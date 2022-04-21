import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobile/components/task/task_row.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:models/task/task.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Widget? notice;
  final bool hideInboxLabel;

  const TaskList({
    Key? key,
    required this.tasks,
    this.notice,
    this.hideInboxLabel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
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
                return const SizedBox(height: 16);
              }

              return notice!;
            }

            index -= 1;

            Task task = tasks[index];

            return TaskRow(
              task: task,
              hideInboxLabel: hideInboxLabel,
              completedClick: () {
                context.read<TasksCubit>().setCompleted(task);
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
    );
  }
}

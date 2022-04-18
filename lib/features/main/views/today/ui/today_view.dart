import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/components/inbox/task.dart';
import 'package:mobile/features/main/views/today/cubit/today_cubit.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/task/task.dart';

class TodayView extends StatelessWidget {
  const TodayView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => TodayCubit(), child: const _View());
  }
}

class _View extends StatelessWidget {
  const _View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Task> tasks = List.from(context.watch<TasksCubit>().state.tasks);

    tasks = TaskExt.filterTodayTasks(tasks);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<SyncCubit>().syncTasks();
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          Task task = tasks[index];

          return TaskRow(
            task: task,
            completed: () {
              context.read<TasksCubit>().setCompleted(task);
            },
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 4);
        },
      ),
    );
  }
}

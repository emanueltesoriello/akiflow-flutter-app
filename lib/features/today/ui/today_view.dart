import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/components/task/task_list.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/features/today/cubit/today_cubit.dart';
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

    return TaskList(tasks: tasks);
  }
}

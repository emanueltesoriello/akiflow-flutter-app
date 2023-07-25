import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/base/ui/widgets/task/task_list.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:models/task/task.dart';

class SomedayBody extends StatefulWidget {
  const SomedayBody({super.key});

  @override
  State<SomedayBody> createState() => SomedayBodyState();
}

class SomedayBodyState extends State<SomedayBody> {
  late ScrollController scrollController;

  @override
  initState() {
    scrollController = ScrollController();
    context.read<TasksCubit>().fetchSomedayTasks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksCubitState>(
      builder: (context, state) {
        List<Task> tasks = state.somedayTasks;
        return TaskList(
          key: const Key('somedayTaskList'),
          tasks: tasks,
          hideInboxLabel: true,
          scrollController: scrollController,
          sorting: TaskListSorting.none,
          showLabel: true,
          showPlanInfo: true,
          addBottomPadding: true,
        );
      },
    );
  }
}

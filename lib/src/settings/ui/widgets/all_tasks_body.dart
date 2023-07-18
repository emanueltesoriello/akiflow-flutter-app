import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/settings/ui/widgets/paginated_task_list.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:models/task/task.dart';

class AllTasksBody extends StatefulWidget {
  const AllTasksBody({super.key});

  @override
  State<AllTasksBody> createState() => AllTasksBodyState();
}

class AllTasksBodyState extends State<AllTasksBody> {
  late ScrollController scrollController;
  int itemsPerPage = 0;

  @override
  initState() {
    scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksCubitState>(
      builder: (context, state) {
        List<Task> tasks = state.allTasks;
        return PaginatedTaskList(
          key: const Key('allTasks'),
          tasksLength: itemsPerPage,
          tasks: tasks,
          initFunction: () async {
            context.read<TasksCubit>().fetchAllTasks(limit: 30, offset: itemsPerPage);
          },
          scrollNextPageFunc: () async {
            setState(() {
              itemsPerPage += 30;
            });
            context.read<TasksCubit>().fetchAllTasks(limit: 30, offset: itemsPerPage);
          },
          maxTasksLenght: 300,
          scrollController: scrollController,
          physics: const ScrollPhysics(),
        );
      },
    );
  }
}

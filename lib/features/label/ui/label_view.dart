import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/components/base/container_inner_shadow.dart';
import 'package:mobile/components/task/task_list.dart';
import 'package:mobile/features/label/cubit/label_cubit.dart';
import 'package:mobile/features/label/ui/label_appbar.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/task/task.dart';

class LabelView extends StatelessWidget {
  const LabelView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Task> all = [
      ...context.watch<TasksCubit>().state.inboxTasks,
      ...context.watch<TasksCubit>().state.todayTasks,
    ];

    return BlocBuilder<LabelCubit, LabelCubitState>(
      builder: (context, state) {
        List<Task> labelTasks =
            all.where((element) => element.listId == state.selectedLabel!.id! && !element.isCompletedComputed).toList();

        print(state.selectedLabel?.title);

        return Column(
          children: [
            LabelAppBar(label: state.selectedLabel!),
            Expanded(
              child: ContainerInnerShadow(
                child: TaskList(
                  tasks: labelTasks,
                  sorting: TaskListSorting.ascending,
                  hideLabel: true,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

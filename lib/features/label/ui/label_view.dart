import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/components/base/container_inner_shadow.dart';
import 'package:mobile/components/task/task_list.dart';
import 'package:mobile/features/label/cubit/label_cubit.dart';
import 'package:mobile/features/label/ui/label_appbar.dart';
import 'package:models/task/task.dart';

class LabelView extends StatelessWidget {
  const LabelView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Task> tasks = [];

    return BlocBuilder<LabelCubit, LabelCubitState>(
      builder: (context, state) {
        return Column(
          children: [
            LabelAppBar(label: state.selectedLabel!),
            Expanded(
              child: ContainerInnerShadow(
                child: TaskList(
                  tasks: tasks,
                  sorting: TaskListSorting.ascending,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

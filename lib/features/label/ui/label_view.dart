import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/components/base/container_inner_shadow.dart';
import 'package:mobile/components/task/task_list.dart';
import 'package:mobile/features/label/cubit/create_edit/label_cubit.dart';
import 'package:mobile/features/label/ui/label_appbar.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/task/task.dart';

class LabelView extends StatelessWidget {
  const LabelView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LabelCubit, LabelCubitState>(
      builder: (context, state) {
        List<Task> labelTasks = state.tasks ?? [];

        List<Task> filtered = labelTasks.where((element) => !element.isCompletedComputed).toList();

        return Column(
          children: [
            LabelAppBar(label: state.selectedLabel!),
            Expanded(
              child: ContainerInnerShadow(
                child: TaskList(
                  tasks: filtered,
                  sorting: state.sorting,
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

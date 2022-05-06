import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/components/task/label_item.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/utils/label_ext.dart';
import 'package:models/label/label.dart';

class AddTaskLabels extends StatelessWidget {
  const AddTaskLabels({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<TasksCubit, TasksCubitState>(
          builder: (context, state) {
            List<Label> labels = state.labels.toList();

            labels = LabelExt.filter(labels);

            return Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                itemCount: labels.length,
                itemBuilder: (context, index) {
                  Label label = labels[index];

                  return LabelItem(
                    label,
                    onTap: () {
                      context
                          .read<EditTaskCubit>()
                          .setLabel(label, update: false);
                    },
                  );
                },
              ),
            );
          },
        ),
        Container(
          color: Theme.of(context).dividerColor,
          width: double.infinity,
          height: 1,
        ),
      ],
    );
  }
}

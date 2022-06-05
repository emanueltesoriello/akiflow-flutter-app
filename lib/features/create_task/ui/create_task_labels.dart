import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/edit_task/ui/labels_list.dart';
import 'package:models/label/label.dart';

class CreateTaskLabels extends StatelessWidget {
  const CreateTaskLabels({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: LabelsList(
            showHeaders: false,
            onSelect: (Label selected) {
              context.read<EditTaskCubit>().setLabel(selected);
            },
          ),
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

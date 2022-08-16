import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../edit_task/cubit/edit_task_cubit.dart';
import '../create_task_duration.dart';

class DurationWidget extends StatelessWidget {
  const DurationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditTaskCubit, EditTaskCubitState>(
      builder: (context, state) {
        if (state.showDuration) {
          return const CreateTaskDurationItem();
        } else {
          return const SizedBox();
        }
      },
    );
  }
}

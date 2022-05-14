import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/components/base/scroll_chip.dart';
import 'package:mobile/components/base/separator.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/edit_task/ui/edit_task_bottom_actions.dart';
import 'package:mobile/features/edit_task/ui/edit_task_linked_content.dart';
import 'package:mobile/features/edit_task/ui/edit_task_links.dart';
import 'package:mobile/features/edit_task/ui/edit_task_row.dart';
import 'package:mobile/features/edit_task/ui/edit_task_top_actions.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/task/task.dart';

class EditTaskModal extends StatelessWidget {
  final Task? task;
  final TaskStatusType? taskStatusType;

  const EditTaskModal({
    Key? key,
    this.task,
    this.taskStatusType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          EditTaskCubit(context.read<TasksCubit>(), task: task, taskStatusType: taskStatusType, isCreateMode: false),
      child: const EditTaskModalView(),
    );
  }
}

class EditTaskModalView extends StatefulWidget {
  const EditTaskModalView({Key? key}) : super(key: key);

  @override
  State<EditTaskModalView> createState() => _EditTaskModalViewState();
}

class _EditTaskModalViewState extends State<EditTaskModalView> {
  @override
  void initState() {
    context.read<EditTaskCubit>().setRead();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          child: Container(
            color: Theme.of(context).backgroundColor,
            child: ListView(
              shrinkWrap: true,
              children: const [
                SizedBox(height: 12),
                ScrollChip(),
                SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: EditTaskTopActions(),
                ),
                SizedBox(height: 12),
                EditTaskRow(),
                SizedBox(height: 12),
                Separator(),
                EditTaskLinkedContent(),
                EditTaskLinks(),
                EditTaskBottomActions(),
                Separator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

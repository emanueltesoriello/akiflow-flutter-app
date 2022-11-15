import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/components/base/scroll_chip.dart';
import 'package:mobile/common/components/base/separator.dart';
import 'package:mobile/features/tasks/create_task/ui/create_task_duration.dart';
import 'package:mobile/features/tasks/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/tasks/edit_task/ui/edit_task_bottom_actions.dart';
import 'package:mobile/features/tasks/edit_task/ui/edit_task_linked_content.dart';
import 'package:mobile/features/tasks/edit_task/ui/edit_task_links.dart';
import 'package:mobile/features/tasks/edit_task/ui/edit_task_row.dart';
import 'package:mobile/features/tasks/edit_task/ui/edit_task_top_actions.dart';
import 'package:mobile/common/utils/no_scroll_behav.dart';

class EditTaskModal extends StatefulWidget {
  const EditTaskModal({Key? key}) : super(key: key);

  @override
  State<EditTaskModal> createState() => _EditTaskModalState();
}

class _EditTaskModalState extends State<EditTaskModal> {
  @override
  void initState() {
    context.read<EditTaskCubit>().setRead();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).backgroundColor,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ScrollConfiguration(
          behavior: NoScrollBehav(),
          child: ListView(
            shrinkWrap: true,
            children: [
              const SizedBox(height: 12),
              const ScrollChip(),
              const SizedBox(height: 12),
              BlocBuilder<EditTaskCubit, EditTaskCubitState>(
                builder: (context, state) {
                  return Visibility(
                    visible: state.showDuration,
                    replacement: const SizedBox(),
                    child: Column(
                      children: const [
                        Separator(),
                        CreateTaskDurationItem(),
                      ],
                    ),
                  );
                },
              ),
              const EditTaskTopActions(),
              const SizedBox(height: 12),
              const EditTaskRow(),
              const SizedBox(height: 12),
              const Separator(),
              const EditTaskLinkedContent(),
              const EditTaskLinks(),
              const EditTaskBottomActions(),
              const Separator(),
            ],
          ),
        ),
      ),
    );
  }
}

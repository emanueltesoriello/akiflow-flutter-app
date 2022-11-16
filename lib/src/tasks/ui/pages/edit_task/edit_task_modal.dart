import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/utils/no_scroll_behav.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/pages/create_task/create_task_duration.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/edit_task_bottom_actions.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/edit_task_linked_content.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/edit_task_links.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/edit_task_row.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/edit_task_top_actions.dart';

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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: EditTaskTopActions(),
                  ),
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
        ),
      ),
    );
  }
}

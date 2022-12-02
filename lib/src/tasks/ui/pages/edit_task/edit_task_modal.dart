import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/style/colors.dart';
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

  _actionsForFocusNodes() {
    EditTaskCubit cubit = context.read<EditTaskCubit>();

    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8),
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () => cubit.setHasFocusOnTitleOrDescription(false),
            icon: Icon(Icons.arrow_back, size: 16, color: ColorsExt.grey3(context)),
            label: Text(
              'Edit task',
              style: Theme.of(context).textTheme.button?.copyWith(color: ColorsExt.grey3(context)),
            ),
          ),
          TextButton(
            onPressed: () => cubit.setHasFocusOnTitleOrDescription(false),
            child: Text(
              'SAVE',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(fontWeight: FontWeight.w500, color: ColorsExt.akiflow(context)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditTaskCubit, EditTaskCubitState>(
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () {
            if (state.hasFocusOnTitleOrDescription) {
              EditTaskCubit cubit = context.read<EditTaskCubit>();
              cubit.setHasFocusOnTitleOrDescription(false);
            } else {
              Navigator.of(context).pop();
            }
            return Future.value();
          },
          child: Material(
              color: Theme.of(context).backgroundColor,
              child: Container(
                height: state.hasFocusOnTitleOrDescription ? MediaQuery.of(context).size.height / 2 : null,
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
                      if (!state.hasFocusOnTitleOrDescription) const ScrollChip(),
                      if (!state.hasFocusOnTitleOrDescription) const SizedBox(height: 12),
                      if (!state.hasFocusOnTitleOrDescription)
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
                      Column(
                        children: [
                          if (!state.hasFocusOnTitleOrDescription) const EditTaskTopActions(),
                          if (!state.hasFocusOnTitleOrDescription) const SizedBox(height: 12),
                          if (state.hasFocusOnTitleOrDescription) _actionsForFocusNodes(),
                          if (state.hasFocusOnTitleOrDescription) const SizedBox(height: 10),
                          if (state.hasFocusOnTitleOrDescription) const Separator(),
                          if (state.hasFocusOnTitleOrDescription) const SizedBox(height: 15),
                          const EditTaskRow(),
                          if (!state.hasFocusOnTitleOrDescription) const SizedBox(height: 12),
                          if (!state.hasFocusOnTitleOrDescription) const Separator(),
                          if (!state.hasFocusOnTitleOrDescription) const EditTaskLinkedContent(),
                          if (!state.hasFocusOnTitleOrDescription) const EditTaskLinks(),
                          if (!state.hasFocusOnTitleOrDescription) const EditTaskBottomActions(),
                          if (!state.hasFocusOnTitleOrDescription) const Separator(),
                        ],
                      )
                    ],
                  ),
                ),
              )),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/tasks/create_task/ui/components/create_task_actions.dart';
import 'package:mobile/features/tasks/create_task/ui/components/description_field.dart';
import 'package:mobile/features/tasks/create_task/ui/components/label_widget.dart';
import 'package:mobile/features/tasks/create_task/ui/components/send_task_button.dart';
import 'package:mobile/features/tasks/create_task/ui/components/title_field.dart';
import 'package:mobile/features/tasks/edit_task/cubit/edit_task_cubit.dart';
import 'package:models/task/task.dart';
import 'components/duration_widget.dart';
import 'components/priority_widget.dart';

class CreateTaskModal extends StatefulWidget {
  const CreateTaskModal({Key? key}) : super(key: key);

  @override
  State<CreateTaskModal> createState() => _CreateTaskModalState();
}

class _CreateTaskModalState extends State<CreateTaskModal> {
  final TextEditingController descriptionController = TextEditingController();

  final FocusNode titleFocus = FocusNode();

  final TextEditingController simpleTitleController = TextEditingController();

  final ValueNotifier<bool> isTitleEditing = ValueNotifier<bool>(false);

  final ScrollController parentScrollController = ScrollController();
  @override
  void initState() {
    titleFocus.requestFocus();
    EditTaskCubit editTaskCubit = context.read<EditTaskCubit>();
    simpleTitleController.text = editTaskCubit.state.originalTask.title ?? '';

    String descriptionHtml = editTaskCubit.state.originalTask.description ?? '';
    descriptionController.text = descriptionHtml;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).backgroundColor,
      child: ListView(
          controller: parentScrollController,
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          children: [
            Container(
              color: Theme.of(context).backgroundColor,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SafeArea(
                child: Column(
                  children: [
                    const DurationWidget(),
                    const PriorityWidget(),
                    const LabelWidget(),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TitleField(
                              simpleTitleController: simpleTitleController,
                              isTitleEditing: isTitleEditing,
                              titleFocus: titleFocus),
                          const SizedBox(height: 8),
                          DescriptionField(descriptionController: descriptionController),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CreateTaskActions(
                                titleController: simpleTitleController,
                                titleFocus: titleFocus,
                              ),
                              SendTaskButton(onTap: () {
                                HapticFeedback.mediumImpact();
                                context.read<EditTaskCubit>().create();
                                Task taskUpdated = context.read<EditTaskCubit>().state.updatedTask;
                                Navigator.pop(context, taskUpdated);
                              }),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
    );
  }
}

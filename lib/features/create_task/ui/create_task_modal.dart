import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/features/create_task/ui/components/create_task_actions.dart';
import 'package:mobile/features/create_task/ui/components/description_field.dart';
import 'package:mobile/features/create_task/ui/components/label_widget.dart';
import 'package:mobile/features/create_task/ui/components/send_task_button.dart';
import 'package:mobile/features/create_task/ui/components/title_field.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/style/colors.dart';
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

  final TextEditingController _simpleTitleController = TextEditingController();

  final ValueNotifier<bool> _isTitleEditing = ValueNotifier<bool>(false);

  final ScrollController _parentScrollController = ScrollController();

  @override
  void initState() {
    titleFocus.requestFocus();
    EditTaskCubit editTaskCubit = context.read<EditTaskCubit>();
    String descriptionHtml = editTaskCubit.state.originalTask.description ?? '';
    descriptionController.text = descriptionHtml;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).backgroundColor,
      child: ListView(
        controller: _parentScrollController,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              child: Container(
                color: Theme.of(context).backgroundColor,
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
                            TitleField(simpleTitleController: _simpleTitleController, isTitleEditing: _isTitleEditing, titleFocus: titleFocus),
                            const SizedBox(height: 8),
                            DescriptionField(descriptionController: descriptionController),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CreateTaskActions(
                                  titleController: _simpleTitleController,
                                  titleFocus: titleFocus,
                                ),
                                SendTaskButton(onTap: () {
                                  print(_simpleTitleController.text + descriptionController.text);
                                  HapticFeedback.mediumImpact();
                                  context.read<EditTaskCubit>().create(
                                      title: _simpleTitleController.text, description: descriptionController.text);
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
            ),
          ),
        ],
      ),
    );
  }
}

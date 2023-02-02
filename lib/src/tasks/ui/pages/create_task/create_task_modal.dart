import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/services/background_service.dart';
import 'package:mobile/src/base/ui/cubit/notifications/notifications_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/create_task_actions.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/description_field.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/duration_widget.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/label_widget.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/priority_widget.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/send_task_button.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/title_field.dart';
import 'package:models/task/task.dart';
import 'package:workmanager/workmanager.dart';

class CreateTaskModal extends StatefulWidget {
  const CreateTaskModal({Key? key, this.sharedText}) : super(key: key);
  final String? sharedText;
  @override
  State<CreateTaskModal> createState() => _CreateTaskModalState();
}

class _CreateTaskModalState extends State<CreateTaskModal> {
  final TextEditingController descriptionController = TextEditingController();
  final FocusNode titleFocus = FocusNode();
  final TextEditingController simpleTitleController = TextEditingController();
  final ValueNotifier<bool> isTitleEditing = ValueNotifier<bool>(false);
  final ScrollController parentScrollController = ScrollController();
  bool showRefresh = false;

  @override
  void initState() {
    titleFocus.requestFocus();
    EditTaskCubit editTaskCubit = context.read<EditTaskCubit>();
    simpleTitleController.text = editTaskCubit.state.originalTask.title ?? '';

    String descriptionHtml = widget.sharedText ?? editTaskCubit.state.originalTask.description ?? '';
    descriptionController.text = descriptionHtml;
    context.read<EditTaskCubit>().updateDescription(descriptionHtml);

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
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: const BorderRadius.only(
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
                          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            CreateTaskActions(
                              titleController: simpleTitleController,
                              titleFocus: titleFocus,
                            ),
                            showRefresh
                                ? const Center(
                                    child: Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: CircularProgressIndicator(),
                                  ))
                                : SendTaskButton(onTap: () async {
                                    try {
                                      setState(() {
                                        showRefresh = true;
                                      });
                                      HapticFeedback.mediumImpact();
                                      var cubit = context.read<EditTaskCubit>();
                                      await cubit.create();
                                      setState(() {
                                        showRefresh = false;
                                        Navigator.pop(context);
                                      });
                                      await cubit.forceSync();
                                      NotificationsCubit.scheduleNotificationsService(locator<PreferencesRepository>());
                                    } catch (e) {
                                      setState(() {
                                        showRefresh = false;
                                      });
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        content: Text("Error"),
                                      ));
                                    }
                                  }),
                          ]),
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

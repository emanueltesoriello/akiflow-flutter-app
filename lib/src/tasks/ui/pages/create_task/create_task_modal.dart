import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:mobile/common/utils/stylable_text_editing_controller.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/services/notifications_service.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/create_task_actions.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/description_field.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/duration_widget.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/label_widget.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/priority_widget.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/send_task_button.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/title_field.dart';

import '../../../../label/ui/cubit/labels_cubit.dart';

class CreateTaskModal extends StatefulWidget {
  const CreateTaskModal({Key? key, this.sharedText}) : super(key: key);
  final String? sharedText;
  @override
  State<CreateTaskModal> createState() => _CreateTaskModalState();
}

class _CreateTaskModalState extends State<CreateTaskModal> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController controller = TextEditingController();

  final FocusNode titleFocus = FocusNode();

  final ValueNotifier<bool> isTitleEditing = ValueNotifier<bool>(false);
  final ScrollController parentScrollController = ScrollController();
  bool showRefresh = false;

  late final StylableTextEditingController simpleTitleController;

  @override
  void initState() {
    titleFocus.requestFocus();

    EditTaskCubit editTaskCubit = context.read<EditTaskCubit>();
    editTaskCubit.onOpen();
    simpleTitleController = editTaskCubit.simpleTitleController;
    String descriptionHtml = widget.sharedText ?? editTaskCubit.state.originalTask.description ?? '';
    descriptionController.text = descriptionHtml;
    context.read<EditTaskCubit>().updateDescription(descriptionHtml);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    simpleTitleController.done();
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
                              entityExtractor: context.read<EditTaskCubit>().getExtractor(),
                              labels: context.read<LabelsCubit>().state.labels,
                              stylableController: simpleTitleController,
                              isTitleEditing: isTitleEditing,
                              onChanged: (String value) async {
                                context.read<EditTaskCubit>().updateTitle(value,
                                    recognized: simpleTitleController.recognizedButRemoved,
                                    mapping: simpleTitleController.mapping);
                              },
                              onDateDetected: (DateTimeEntity detected, String value, int start, int end) {
                                context.read<EditTaskCubit>().onDateDetected(context, detected, value, start, end);
                              },
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
                                      var tasksCubit = context.read<TasksCubit>();

                                      await cubit.create();
                                      print('created complete');

                                      await tasksCubit.refreshAllFromRepository().timeout(const Duration(seconds: 6),
                                          onTimeout: () {
                                        print('timeout on refreshAllFromRepository - stopped after 5 seconds');
                                      });

                                      setState(() {
                                        showRefresh = false;
                                        Navigator.pop(context);
                                      });

                                      await cubit.forceSync();
                                      NotificationsService.scheduleNotificationsService(
                                          locator<PreferencesRepository>());
                                    } catch (e) {
                                      setState(() {
                                        showRefresh = false;
                                      });
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text(e.toString()),
                                      ));
                                      locator<SentryService>().captureException(Exception(e.toString()));
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

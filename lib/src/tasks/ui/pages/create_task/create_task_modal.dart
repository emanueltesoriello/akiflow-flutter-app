import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:mobile/common/utils/stylable_text_editing_controller.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/change_priority_modal.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/create_task_actions.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/description_field.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/duration_widget.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/label_widget.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/priority_widget.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/send_task_button.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/title_field.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';

import '../../../../../common/style/colors.dart';
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

  late final StylableTextEditingController simpleTitleController;

  final ValueNotifier<bool> isTitleEditing = ValueNotifier<bool>(false);
  final EntityExtractor extractor = EntityExtractor(language: EntityExtractorLanguage.english);
  final ScrollController parentScrollController = ScrollController();

  @override
  void initState() {
    titleFocus.requestFocus();
    simpleTitleController = StylableTextEditingController({}, (String? value) {
      MapType type = simpleTitleController.removeMappingByValue(value);
      switch (type.type) {
        case 0:
          context.read<EditTaskCubit>().planFor(null, statusType: TaskStatusType.inbox);
          break;
        case 1:
          context.read<EditTaskCubit>().setEmptyLabel();
          break;
        case 2:
          context.read<EditTaskCubit>().setPriority(PriorityEnum.none);
          break;
        case 3:
          context.read<EditTaskCubit>().setDuration(0);
          break;
        default:
      }
      setState(() {});
    }, {});
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
                              entityExtractor: extractor,
                              labels: context.read<LabelsCubit>().state.labels,
                              stylableController: simpleTitleController,
                              isTitleEditing: isTitleEditing,
                              onChanged: (String value) async {
                                
                              },
                              onDurationDetected: (Duration duration, String value) {
                                onDurationDetected(duration, value);
                              },
                              onPriorityDetected: (int priority, String value) {
                                onPriorityDetected(priority, value);
                              },
                              onLabelDetected: (Label label, String value) {
                                onLabelDetected(label, value);
                              },
                              onDateDetected: (DateTimeEntity detected, String value, int start, int end) {
                                onDateDetected(detected, value, start, end);
                              },
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

  onDateDetected(DateTimeEntity detected, String value, int start, int end) {
    if (simpleTitleController.hasParsedDate() && !simpleTitleController.isRemoved(value)) {
      simpleTitleController.removeMapping(0);
      simpleTitleController.addMapping({
        value: MapType(
            0,
            TextStyle(
              backgroundColor: ColorsExt.akiflow20(context),
            )),
      });

      context.read<EditTaskCubit>().planWithNLP(detected.timestamp);
    } else if (!simpleTitleController.isRemoved(value)) {
      simpleTitleController.addMapping({
        value: MapType(
            0,
            TextStyle(
              backgroundColor: ColorsExt.akiflow20(context),
            )),
      });
      context.read<EditTaskCubit>().planWithNLP(detected.timestamp);
    }
  }

  onLabelDetected(Label label, String value) {
    if (simpleTitleController.hasParsedLabel() && !simpleTitleController.isRemoved(value)) {
      simpleTitleController.removeMapping(1);
      simpleTitleController.addMapping({
        "#$value": MapType(
            1,
            TextStyle(
              backgroundColor: ColorsExt.akiflow20(context),
            )),
      });

      context.read<EditTaskCubit>().setLabel(label);
    } else if (!simpleTitleController.isRemoved(value)) {
      simpleTitleController.addMapping({
        "#$value": MapType(
            1,
            TextStyle(
              backgroundColor: ColorsExt.akiflow20(context),
            )),
      });
      context.read<EditTaskCubit>().setLabel(label);
    }
  }

  onPriorityDetected(int priority, String value) {
    if (simpleTitleController.hasParsedPriority() && !simpleTitleController.isRemoved(value)) {
      simpleTitleController.removeMapping(2);
      simpleTitleController.addMapping({
        "!$value": MapType(
            2,
            TextStyle(
              backgroundColor: ColorsExt.akiflow20(context),
            )),
      });

      context.read<EditTaskCubit>().setPriority(null, value: priority);
    } else if (!simpleTitleController.isRemoved(value)) {
      simpleTitleController.addMapping({
        "!$value": MapType(
            2,
            TextStyle(
              backgroundColor: ColorsExt.akiflow20(context),
            )),
      });
      context.read<EditTaskCubit>().setPriority(null, value: priority);
    }
  }

  onDurationDetected(Duration duration, String value) {
    if (simpleTitleController.hasParsedDuration() && !simpleTitleController.isRemoved(value)) {
      simpleTitleController.removeMapping(3);
      simpleTitleController.addMapping({
        "=$value": MapType(
            3,
            TextStyle(
              backgroundColor: ColorsExt.cyan25(context),
            )),
      });

      context.read<EditTaskCubit>().setDuration(duration.inSeconds);
    } else if (!simpleTitleController.isRemoved(value)) {
      simpleTitleController.addMapping({
        "=$value": MapType(
            3,
            TextStyle(
              backgroundColor: ColorsExt.cyan25(context),
            )),
      });
      context.read<EditTaskCubit>().setDuration(duration.inSeconds);
    }
  }
}

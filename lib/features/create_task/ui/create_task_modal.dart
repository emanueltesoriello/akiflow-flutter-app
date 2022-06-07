import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/tagbox.dart';
import 'package:mobile/components/task/plan_for_action.dart';
import 'package:mobile/features/create_task/ui/create_task_duration.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/edit_task/ui/actions/plan_modal.dart';
import 'package:mobile/features/edit_task/ui/labels_list.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';

class CreateTaskModal extends StatefulWidget {
  const CreateTaskModal({Key? key}) : super(key: key);

  @override
  State<CreateTaskModal> createState() => _CreateTaskModalState();
}

class _CreateTaskModalState extends State<CreateTaskModal> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final FocusNode titleFocus = FocusNode();

  @override
  void initState() {
    titleFocus.requestFocus();
    EditTaskCubit editTaskCubit = context.read<EditTaskCubit>();
    titleController.text = editTaskCubit.state.originalTask.title ?? '';

    String descriptionHtml = editTaskCubit.state.originalTask.descriptionComputed(joinCharacter: '\n');
    descriptionController.text = descriptionHtml;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Wrap(
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
                      BlocBuilder<EditTaskCubit, EditTaskCubitState>(
                        builder: (context, state) {
                          if (state.showDuration) {
                            return const CreateTaskDurationItem();
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
                      BlocBuilder<EditTaskCubit, EditTaskCubitState>(
                        builder: (context, state) {
                          if (state.showLabelsList) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: LabelsList(
                                    showHeaders: false,
                                    onSelect: (Label selected) {
                                      context.read<EditTaskCubit>().setLabel(selected);
                                    },
                                    initialSelectedListId: state.updatedTask.listId,
                                  ),
                                ),
                                Container(
                                  color: Theme.of(context).dividerColor,
                                  width: double.infinity,
                                  height: 1,
                                ),
                              ],
                            );
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _title(context),
                            const SizedBox(height: 8),
                            _description(context),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(child: _actions(context)),
                                InkWell(
                                  onTap: () {
                                    context.read<EditTaskCubit>().create();

                                    Task taskUpdated = context.read<EditTaskCubit>().state.updatedTask;

                                    Navigator.pop(context, taskUpdated);
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Material(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      height: 36,
                                      width: 36,
                                      child: Center(
                                        child: SvgPicture.asset(
                                          "assets/images/icons/_common/paperplane_send.svg",
                                          width: 24,
                                          height: 24,
                                          color: Theme.of(context).backgroundColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
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

  Widget _actions(BuildContext context) {
    return Wrap(
      runSpacing: 8,
      children: [
        PlanForAction(
          task: context.watch<EditTaskCubit>().state.updatedTask,
          onTap: () {
            var editTaskCubit = context.read<EditTaskCubit>();

            editTaskCubit.planTap();

            showCupertinoModalBottomSheet(
              context: context,
              builder: (context) => PlanModal(
                initialDate: editTaskCubit.state.updatedTask.date != null
                    ? DateTime.parse(editTaskCubit.state.updatedTask.date!)
                    : DateTime.now(),
                initialDatetime: editTaskCubit.state.updatedTask.datetime != null
                    ? DateTime.parse(editTaskCubit.state.updatedTask.datetime!)
                    : null,
                taskStatusType: editTaskCubit.state.updatedTask.statusType ?? TaskStatusType.inbox,
                onSelectDate: (
                    {required DateTime? date, required DateTime? datetime, required TaskStatusType statusType}) {
                  editTaskCubit.planFor(date, dateTime: datetime, statusType: statusType);
                },
                setForInbox: () {
                  editTaskCubit.planFor(null, dateTime: null, statusType: TaskStatusType.inbox);
                },
                setForSomeday: () {
                  editTaskCubit.planFor(null, dateTime: null, statusType: TaskStatusType.someday);
                },
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        BlocBuilder<EditTaskCubit, EditTaskCubitState>(
          builder: (context, state) {
            Task task = state.updatedTask;

            String? text;

            if (task.duration != null && task.duration != 0) {
              int seconds = task.duration!;

              double hours = seconds / 3600;
              double minutes = (hours - hours.floor()) * 60;

              if (minutes.floor() == 0) {
                text = '${hours.floor()}h';
              } else if (hours.floor() == 0) {
                text = '${minutes.floor()}m';
              } else {
                text = '${hours.floor()}h ${minutes.floor()}m';
              }
            }

            return TagBox(
              icon: "assets/images/icons/_common/hourglass.svg",
              active: task.duration != null && task.duration != 0,
              backgroundColor:
                  task.duration != null && task.duration != 0 ? ColorsExt.grey6(context) : ColorsExt.grey7(context),
              isSquare: task.duration != null && task.duration != 0 ? false : true,
              isBig: true,
              text: text,
              onPressed: () {
                context.read<EditTaskCubit>().toggleDuration();
              },
            );
          },
        ),
        const SizedBox(width: 8),
        BlocBuilder<EditTaskCubit, EditTaskCubitState>(
          builder: (context, state) {
            Color? background;

            List<Label> labels = context.read<LabelsCubit>().state.labels;

            Label? label;

            try {
              label = labels.firstWhere((label) => state.updatedTask.listId!.contains(label.id!));
            } catch (_) {}

            if (label?.color != null) {
              background = ColorsExt.getFromName(label!.color!);
            }

            return TagBox(
              icon: "assets/images/icons/_common/number.svg",
              active: background != null,
              iconColor: background ?? ColorsExt.grey2(context),
              backgroundColor: background != null ? background.withOpacity(0.1) : ColorsExt.grey6(context),
              text: label?.title ?? t.addTask.label,
              isBig: true,
              onPressed: () {
                context.read<EditTaskCubit>().toggleLabels();
              },
            );
          },
        ),
      ],
    );
  }

  TextField _description(BuildContext context) {
    return TextField(
      controller: descriptionController,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(bottom: 16),
        isDense: true,
        hintText: t.addTask.descriptionHint,
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: ColorsExt.grey3(context),
          fontSize: 17,
        ),
      ),
      style: TextStyle(
        color: ColorsExt.grey2(context),
        fontSize: 17,
        fontWeight: FontWeight.w500,
      ),
      onChanged: (value) {
        context.read<EditTaskCubit>().updateDescription(value);
      },
    );
  }

  TextField _title(BuildContext context) {
    return TextField(
      controller: titleController,
      focusNode: titleFocus,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        isDense: true,
        hintText: t.addTask.titleHint,
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: ColorsExt.grey3(context),
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: TextStyle(
        color: ColorsExt.grey2(context),
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      onChanged: (value) {
        context.read<EditTaskCubit>().updateTitle(value);
      },
    );
  }
}

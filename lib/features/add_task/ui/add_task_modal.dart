import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/add_task/ui/add_task_action_item.dart';
import 'package:mobile/features/add_task/ui/add_task_duration.dart';
import 'package:mobile/features/add_task/ui/add_task_labels.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/plan_modal/ui/plan_modal.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AddTaskModal extends StatelessWidget {
  const AddTaskModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditTaskCubit(context.read<TasksCubit>()),
      child: const AddTaskModalView(),
    );
  }
}

class AddTaskModalView extends StatefulWidget {
  const AddTaskModalView({Key? key}) : super(key: key);

  @override
  State<AddTaskModalView> createState() => _AddTaskModalViewState();
}

class _AddTaskModalViewState extends State<AddTaskModalView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final FocusNode _titleFocus = FocusNode();

  @override
  void initState() {
    _titleFocus.requestFocus();
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
                          if (state.setDuration) {
                            return const AddTaskDurationItem();
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
                      BlocBuilder<EditTaskCubit, EditTaskCubitState>(
                        builder: (context, state) {
                          if (state.showLabelsList) {
                            return const AddTaskLabels();
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
                            _actions(context),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () {
                                  context
                                      .read<EditTaskCubit>()
                                      .create(title: _titleController.text, description: _descriptionController.text);

                                  Navigator.pop(context);
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
                            ),
                            const SizedBox(height: 8),
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
      children: [
        _plannedFor(context),
        const SizedBox(width: 8),
        AddTaskActionItem(
          leadingIconAsset: "assets/images/icons/_common/hourglass.svg",
          color: ColorsExt.grey6(context),
          active: context.watch<EditTaskCubit>().state.setDuration,
          onPressed: () {
            context.read<EditTaskCubit>().toggleDuration(update: false);
          },
        ),
        const SizedBox(width: 8),
        BlocBuilder<EditTaskCubit, EditTaskCubitState>(
          builder: (context, state) {
            Color? background;

            if (state.selectedLabel?.color != null) {
              background = ColorsExt.getFromName(state.selectedLabel!.color!);
            }

            return AddTaskActionItem(
              leadingIconAsset: "assets/images/icons/_common/number.svg",
              leadingIconColor: background ?? ColorsExt.grey2(context),
              color: background != null ? background.withOpacity(0.1) : ColorsExt.grey6(context),
              active: true,
              text: state.selectedLabel?.title ?? t.addTask.label,
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
      controller: _descriptionController,
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
    );
  }

  TextField _title(BuildContext context) {
    return TextField(
      controller: _titleController,
      focusNode: _titleFocus,
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
    );
  }

  Widget _plannedFor(BuildContext context) {
    return BlocBuilder<EditTaskCubit, EditTaskCubitState>(
      builder: (context, state) {
        String leadingIconAsset;
        String text;
        Color color;

        TaskStatusType? status = TaskStatusTypeExt.fromId(state.newTask.status) ?? TaskStatusType.inbox;

        if ((status == TaskStatusType.inbox || status == TaskStatusType.planned) && status != TaskStatusType.someday) {
          color = ColorsExt.cyan25(context);
          leadingIconAsset = "assets/images/icons/_common/calendar.svg";
        } else {
          color = ColorsExt.pink30(context);
          leadingIconAsset = "assets/images/icons/_common/clock.svg";
        }

        if (state.newTask.date != null) {
          DateTime parsed = DateTime.parse(state.newTask.date!);

          if (state.newTask.datetime != null) {
            if (state.newTask.isToday) {
              text = DateFormat("HH:mm").format(parsed.toLocal());
            } else if (state.newTask.isTomorrow) {
              text = t.addTask.tmw + DateFormat(" - HH:mm").format(parsed.toLocal());
            } else {
              text = DateFormat("EEE, d MMM").format(parsed.toLocal());
            }
          } else {
            if (state.newTask.isToday) {
              text = t.addTask.today;
            } else if (state.newTask.isTomorrow) {
              text = t.addTask.tmw;
            } else {
              text = DateFormat("EEE, d MMM").format(parsed.toLocal());
            }
          }
        } else if (state.newTask.status == TaskStatusType.someday.id) {
          text = t.task.someday;
        } else {
          text = t.bottomBar.inbox;
        }

        return AddTaskActionItem(
          text: text,
          color: color,
          leadingIconAsset: leadingIconAsset,
          active: true,
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();

            var editTaskCubit = context.read<EditTaskCubit>();

            showCupertinoModalBottomSheet(
              context: context,
              builder: (context) => PlanModal(
                onAddTimeClick: (DateTime? date, TaskStatusType statusType) {
                  editTaskCubit.planFor(date, statusType: statusType, update: false);
                },
                setForInbox: () {
                  editTaskCubit.planFor(null, statusType: TaskStatusType.inbox, update: false);
                },
                setForSomeday: () {
                  editTaskCubit.planFor(null, statusType: TaskStatusType.someday, update: false);
                },
              ),
            );
          },
        );
      },
    );
  }
}
